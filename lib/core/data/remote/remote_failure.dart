import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

enum FailureKind { transient, auth, unique, permanent }

class RemoteFailure implements Exception {
  RemoteFailure(this.kind, this.message, {this.isOffline = false, this.code, this.details});
  final FailureKind kind;
  final String message;
  final bool isOffline;
  final String? code;
  final String? details;
  @override
  String toString() => 'RemoteFailure($kind, $code, $message)';
}

/// Classifies any thrown error per §8.3.
RemoteFailure classifyError(Object e) {
  if (e is RemoteFailure) return e;
  if (e is SocketException || e is TimeoutException || e is HttpException) {
    return RemoteFailure(FailureKind.transient, 'Network unavailable', isOffline: true);
  }
  if (e is AuthRetryableFetchException) {
    return RemoteFailure(FailureKind.transient, 'Network unavailable', isOffline: true);
  }
  if (e is AuthException) {
    final status = int.tryParse(e.statusCode ?? '');
    if (status == 401 || status == 400 || status == 403) {
      return RemoteFailure(FailureKind.auth, e.message, code: e.statusCode);
    }
    return RemoteFailure(FailureKind.transient, e.message);
  }
  if (e is PostgrestException) {
    final code = e.code ?? '';
    final status = int.tryParse(code);
    if (code == 'PGRST301' || code == 'PGRST303' || status == 401) {
      return RemoteFailure(FailureKind.auth, e.message, code: code);
    }
    if (code == '23505') {
      return RemoteFailure(FailureKind.unique, e.message, code: code, details: e.details?.toString());
    }
    if (status != null && (status >= 500 || status == 429 || status == 408)) {
      return RemoteFailure(FailureKind.transient, e.message, code: code);
    }
    return RemoteFailure(FailureKind.permanent, e.message, code: code);
  }
  if (e is StorageException) {
    final sc = int.tryParse(e.statusCode ?? '');
    if (sc == 409) return RemoteFailure(FailureKind.permanent, e.message, code: 'exists');
    if (sc != null && (sc >= 500 || sc == 429 || sc == 408)) {
      return RemoteFailure(FailureKind.transient, e.message);
    }
    return RemoteFailure(FailureKind.permanent, e.message, code: e.statusCode);
  }
  final text = e.toString();
  if (text.contains('SocketException') ||
      text.contains('ClientException') ||
      text.contains('Failed host lookup') ||
      text.contains('Connection')) {
    return RemoteFailure(FailureKind.transient, 'Network unavailable', isOffline: true);
  }
  return RemoteFailure(FailureKind.transient, text);
}
