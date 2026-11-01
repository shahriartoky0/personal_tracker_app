import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/app_error.dart';
import '../../../core/ui/validators.dart';

class AuthState {
  const AuthState({
    this.signUp = false,
    this.busy = false,
    this.obscure = true,
    this.error,
    this.info,
    this.emailError,
    this.passwordError,
  });
  final bool signUp;
  final bool busy;
  final bool obscure;
  final String? error;
  final String? info;
  final String? emailError;
  final String? passwordError;

  AuthState copyWith({
    bool? signUp,
    bool? busy,
    bool? obscure,
    Object? error = _keep,
    Object? info = _keep,
    Object? emailError = _keep,
    Object? passwordError = _keep,
  }) =>
      AuthState(
        signUp: signUp ?? this.signUp,
        busy: busy ?? this.busy,
        obscure: obscure ?? this.obscure,
        error: identical(error, _keep) ? this.error : error as String?,
        info: identical(info, _keep) ? this.info : info as String?,
        emailError: identical(emailError, _keep) ? this.emailError : emailError as String?,
        passwordError: identical(passwordError, _keep) ? this.passwordError : passwordError as String?,
      );
}

const _keep = Object();

/// Sign-in / sign-up / password reset. Owns the form state and the text
/// controllers; the screen only renders. Needs a connection.
class AuthController extends AutoDisposeNotifier<AuthState> {
  late final TextEditingController email;
  late final TextEditingController password;

  /// Must match the redirect URL registered in Supabase Auth → URL Configuration.
  static const redirect = 'io.yourorg.taka://auth-callback';

  @override
  AuthState build() {
    email = TextEditingController();
    password = TextEditingController();
    ref.onDispose(() {
      email.dispose();
      password.dispose();
    });
    return const AuthState();
  }

  void toggleMode() => state = AuthState(signUp: !state.signUp, obscure: state.obscure);
  void toggleObscure() => state = state.copyWith(obscure: !state.obscure);

  bool _validate() {
    final e = Validate.emailRequired(email.text);
    final p = state.signUp ? Validate.passwordRequired(password.text) : Validate.required('Enter your password')(password.text);
    state = state.copyWith(emailError: e, passwordError: p, error: null, info: null);
    return e == null && p == null;
  }

  Future<void> submit() async {
    if (state.busy || !_validate()) return;
    state = state.copyWith(busy: true);
    final auth = Supabase.instance.client.auth;
    try {
      if (state.signUp) {
        final res = await auth.signUp(email: email.text.trim(), password: password.text, emailRedirectTo: redirect);
        if (res.session == null) {
          state = state.copyWith(busy: false, info: 'Check your email to confirm your account, then sign in.');
          return;
        }
      } else {
        await auth.signInWithPassword(email: email.text.trim(), password: password.text);
      }
      state = state.copyWith(busy: false); // the session gate takes over
    } catch (e, st) {
      state = state.copyWith(busy: false, error: toFailure(e, st).message);
    }
  }

  Future<void> resetPassword() async {
    final e = Validate.emailRequired(email.text);
    if (e != null) {
      state = state.copyWith(emailError: e, error: null, info: null);
      return;
    }
    state = state.copyWith(busy: true, error: null, info: null, emailError: null);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email.text.trim(), redirectTo: redirect);
      state = state.copyWith(busy: false, info: 'Password reset email sent.');
    } catch (err, st) {
      state = state.copyWith(busy: false, error: toFailure(err, st).message);
    }
  }
}

final authControllerProvider = NotifierProvider.autoDispose<AuthController, AuthState>(AuthController.new);
