import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Debug-only console logging. Everything here is a no-op in release builds,
/// so nothing sensitive can reach a production device log.
class AppLog {
  AppLog._();

  static const _maxBody = 6000;
  static const _redactHeaders = {'authorization', 'apikey', 'x-client-info', 'cookie', 'set-cookie'};
  static const _redactJsonKeys = {
    'password', 'access_token', 'refresh_token', 'token', 'provider_token', 'provider_refresh_token'
  };

  static void line(String tag, String message) {
    if (!kDebugMode) return;
    debugPrint('[$tag] $message', wrapWidth: 1000);
  }

  /// A framed block, used for HTTP exchanges.
  static void block(String title, List<String> lines) {
    if (!kDebugMode) return;
    final b = StringBuffer()
      ..writeln('┌── $title')
      ..writeAll(lines.expand((l) => l.split('\n')).map((l) => '│ $l'), '\n')
      ..writeln()
      ..write('└──────────────────────────────');
    debugPrint(b.toString(), wrapWidth: 1000);
  }

  static String headers(Map<String, String> h) {
    if (h.isEmpty) return '(none)';
    return h.entries
        .map((e) => '${e.key}: ${_redactHeaders.contains(e.key.toLowerCase()) ? '<redacted>' : e.value}')
        .join('\n');
  }

  /// Pretty-prints JSON (redacting secrets) and truncates long bodies.
  static String body(List<int> bytes, String? contentType) {
    if (bytes.isEmpty) return '(empty)';
    final isText = contentType == null ||
        contentType.contains('json') ||
        contentType.contains('text') ||
        contentType.contains('x-www-form-urlencoded');
    if (!isText) return '<${bytes.length} bytes, $contentType>';
    String text;
    try {
      text = utf8.decode(bytes);
    } catch (_) {
      return '<${bytes.length} bytes, not UTF-8>';
    }
    try {
      final decoded = _redact(jsonDecode(text));
      text = const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {}
    if (text.length > _maxBody) {
      text = '${text.substring(0, _maxBody)}\n… (${text.length - _maxBody} more characters)';
    }
    return text;
  }

  static Object? _redact(Object? v) {
    if (v is Map) {
      return {
        for (final e in v.entries)
          e.key: _redactJsonKeys.contains(e.key.toString().toLowerCase()) ? '<redacted>' : _redact(e.value),
      };
    }
    if (v is List) return v.map(_redact).toList();
    return v;
  }
}

/// Wraps an [http.Client] and logs each request with its response (status,
/// timing, headers, bodies) or its error. Only installed in debug builds.
class LoggingHttpClient extends http.BaseClient {
  LoggingHttpClient([http.Client? inner]) : _inner = inner ?? http.Client();
  final http.Client _inner;
  int _seq = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final id = ++_seq;
    final sw = Stopwatch()..start();

    // Buffer the request body for logging, then re-send an identical request.
    http.BaseRequest toSend = request;
    String reqBody;
    if (request is http.Request) {
      reqBody = AppLog.body(request.bodyBytes, request.headers['content-type']);
    } else if (request is http.MultipartRequest) {
      reqBody = '<multipart: ${request.files.length} file(s), ${request.fields.length} field(s)>';
    } else {
      reqBody = '<streamed body, ${request.contentLength ?? 'unknown'} bytes>';
    }

    final uri = request.url;
    final head = '#$id ${request.method} ${uri.scheme}://${uri.host}${uri.path}';
    final query = uri.hasQuery ? 'query: ${Uri.decodeComponent(uri.query)}' : null;

    http.StreamedResponse res;
    try {
      res = await _inner.send(toSend);
    } catch (e) {
      AppLog.block('✗ $head  FAILED after ${sw.elapsedMilliseconds} ms', [
        ?query,
        'request headers:\n${AppLog.headers(request.headers)}',
        'request body:\n$reqBody',
        'error: $e',
      ]);
      rethrow;
    }

    final bytes = await res.stream.toBytes();
    sw.stop();
    final ok = res.statusCode < 400;
    AppLog.block('${ok ? '✓' : '✗'} $head  →  ${res.statusCode} ${res.reasonPhrase ?? ''}  (${sw.elapsedMilliseconds} ms)', [
      ?query,
      'request headers:\n${AppLog.headers(request.headers)}',
      'request body:\n$reqBody',
      'response headers:\n${AppLog.headers(res.headers)}',
      'response body (${bytes.length} bytes):\n${AppLog.body(bytes, res.headers['content-type'])}',
    ]);

    return http.StreamedResponse(
      Stream<List<int>>.value(bytes),
      res.statusCode,
      contentLength: bytes.length,
      request: res.request,
      headers: res.headers,
      isRedirect: res.isRedirect,
      persistentConnection: res.persistentConnection,
      reasonPhrase: res.reasonPhrase,
    );
  }

  @override
  void close() => _inner.close();
}
