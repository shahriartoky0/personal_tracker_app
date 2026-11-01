import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/ui/motion.dart';
import 'application/auth_controller.dart';
import '../../core/ui/app_logo.dart';

/// Email/password auth. Needs a connection (first sign-in only).
class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(authControllerProvider);
    final c = ref.read(authControllerProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(Tokens.s24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AutofillGroup(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: AppLogo(size: 72, shadow: true),
                  ).pop(context),
                  const SizedBox(height: Tokens.s16),
                  Text('SpendWise', style: theme.textTheme.headlineMedium).enter(context),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: Motion.fast,
                    child: Text(
                      s.signUp ? 'Create your account' : 'Sign in to plan today and track every taka.',
                      key: ValueKey(s.signUp),
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(height: Tokens.s24),
                  TextField(
                    controller: c.email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(labelText: 'Email', errorText: s.emailError),
                  ).enter(context, index: 1),
                  const SizedBox(height: Tokens.s12),
                  TextField(
                    controller: c.password,
                    obscureText: s.obscure,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => c.submit(),
                    autofillHints: [s.signUp ? AutofillHints.newPassword : AutofillHints.password],
                    inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: s.passwordError,
                      suffixIcon: IconButton(
                        tooltip: s.obscure ? 'Show password' : 'Hide password',
                        icon: Icon(s.obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: c.toggleObscure,
                      ),
                    ),
                  ).enter(context, index: 2),
                  AnimatedSize(
                    duration: Motion.fast,
                    alignment: Alignment.topCenter,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      if (s.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: Tokens.s12),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Icon(Icons.error_outline, size: 18, color: theme.colorScheme.error),
                            const SizedBox(width: 8),
                            Expanded(child: Text(s.error!, style: TextStyle(color: theme.colorScheme.error))),
                          ]),
                        ),
                      if (s.info != null)
                        Padding(
                          padding: const EdgeInsets.only(top: Tokens.s12),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Icon(Icons.mark_email_read_outlined, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(s.info!)),
                          ]),
                        ),
                    ]),
                  ),
                  const SizedBox(height: Tokens.s20),
                  FilledButton(
                    onPressed: s.busy ? null : c.submit,
                    child: s.busy
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(s.signUp ? 'Sign up' : 'Sign in'),
                  ).enter(context, index: 3),
                  TextButton(
                    onPressed: s.busy ? null : c.toggleMode,
                    child: Text(s.signUp ? 'I already have an account' : 'Create an account'),
                  ),
                  if (!s.signUp) TextButton(onPressed: s.busy ? null : c.resetPassword, child: const Text('Forgot password?')),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
