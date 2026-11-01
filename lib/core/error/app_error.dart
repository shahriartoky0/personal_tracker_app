import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show DriftWrappedException;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/remote/remote_failure.dart';
import '../domain/result.dart';
import '../logging/app_log.dart';

/// Turns any thrown object into a [Failure] whose message is safe to show.
/// The technical detail goes to the debug log, never to the user.
Failure toFailure(Object error, [StackTrace? stack]) {
  AppLog.line('error', '$error${stack != null ? '\n$stack' : ''}');

  if (error is Failure) return error;
  if (error is RemoteFailure) return _fromRemote(error);

  if (error is AuthException) return Failure(FailureCode.forbidden, _authMessage(error));
  if (error is PostgrestException) {
    final code = error.code ?? '';
    if (code == '23505') return Failure(FailureCode.conflict, 'That already exists.');
    if (code == '42501') return Failure(FailureCode.forbidden, "You don't have permission to do that.");
    return Failure(FailureCode.unexpected, 'The server could not complete that. Please try again.');
  }
  if (error is SocketException || error is TimeoutException || error is HttpException) {
    return Failure(FailureCode.unexpected, "You're offline or the connection is poor. Your changes are saved on this device.");
  }
  if (error is DriftWrappedException) {
    return Failure(FailureCode.unexpected, 'Could not save on this device. Free up some space and try again.');
  }
  if (error is FormatException) {
    return Failure(FailureCode.validation, 'Something in that input looks wrong.');
  }
  return Failure.unexpected();
}

Failure _fromRemote(RemoteFailure f) {
  switch (f.kind) {
    case FailureKind.transient:
      return Failure(FailureCode.unexpected,
          f.isOffline ? "You're offline. Your changes are saved on this device." : 'The server is busy. Try again shortly.');
    case FailureKind.auth:
      return Failure(FailureCode.forbidden, 'Please sign in again.');
    case FailureKind.unique:
      return Failure(FailureCode.conflict, 'That already exists.');
    case FailureKind.permanent:
      return Failure(FailureCode.unexpected, 'The server rejected that change.');
  }
}

String _authMessage(AuthException e) {
  final m = e.message.toLowerCase();
  if (m.contains('invalid login')) return 'Wrong email or password.';
  if (m.contains('email not confirmed')) return 'Please confirm your email first, then sign in.';
  if (m.contains('already registered') || m.contains('already been registered')) {
    return 'An account with that email already exists. Try signing in.';
  }
  if (m.contains('rate limit') || m.contains('too many')) return 'Too many attempts. Wait a minute and try again.';
  if (m.contains('weak') || m.contains('password should')) return 'Choose a stronger password (at least 6 characters).';
  if (e is AuthRetryableFetchException) return 'You need an internet connection to do that.';
  return 'Could not sign you in. Please try again.';
}

/// Runs [body] and converts any exception into an [Err]; callers never throw
/// into the UI.
Future<Result<T>> guard<T>(Future<Result<T>> Function() body) async {
  try {
    return await body();
  } catch (e, st) {
    return Err(toFailure(e, st));
  }
}

/// Message for an arbitrary error object (used by AsyncValue error views).
String friendlyMessage(Object error) => toFailure(error).message;
