import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/platform/app_lock.dart';
import '../core/ui/app_snackbar.dart';
import '../core/ui/motion.dart';
import '../features/auth/auth_screen.dart';
import '../features/auth/bootstrap_screen.dart';
import '../features/settings/accounts_screen.dart';
import '../features/settings/categories_screen.dart';
import '../features/settings/diagnostics_screen.dart';
import '../features/settings/reminders_screen.dart';
import '../features/transfers/people_screen.dart';
import 'session_controller.dart';
import 'shell.dart';
import 'theme.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (c, s) => const _Gate()),
    GoRoute(path: '/accounts', builder: (c, s) => const AccountsScreen()),
    GoRoute(path: '/categories', builder: (c, s) => const CategoriesScreen()),
    GoRoute(path: '/reminders', builder: (c, s) => const RemindersScreen()),
    GoRoute(path: '/people', builder: (c, s) => const PeopleScreen()),
    GoRoute(path: '/diagnostics', builder: (c, s) => const DiagnosticsScreen()),
  ],
);

class TakaTrackerApp extends ConsumerWidget {
  const TakaTrackerApp({super.key, required this.missingConfig, this.deviceZone});
  final bool missingConfig;
  final String? deviceZone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (missingConfig) {
      return MaterialApp(
        theme: buildTheme(Brightness.light),
        home: const Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Missing configuration.\n\nCreate a .env file (see .env.example) with\nSUPABASE_URL and SUPABASE_ANON_KEY, then restart.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }
    ref.watch(resumeSyncProvider); // keeps the foreground-sync observer alive
    return MaterialApp.router(
      title: 'Taka Tracker',
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      routerConfig: _router,
    );
  }
}

/// Auth → first sync → app, driven by [sessionProvider].
class _Gate extends ConsumerWidget {
  const _Gate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(sessionProvider);
    ref.listen(sessionProvider.select((x) => x.notice), (_, notice) {
      if (notice != null) {
        AppSnack.error(context, notice);
        ref.read(sessionProvider.notifier).clearNotice();
      }
    });

    final Widget page = switch (s.phase) {
      SessionPhase.checking => const Scaffold(body: Center(child: LottieView(LottieAsset.loading, size: 96))),
      SessionPhase.signedOut => const AuthScreen(),
      SessionPhase.bootstrapping => const BootstrapScreen(),
      SessionPhase.ready => const LockGate(child: AppShell()),
    };
    return AnimatedSwitcher(
      duration: Motion.reduced(context) ? Duration.zero : Motion.normal,
      switchInCurve: Motion.curve,
      child: KeyedSubtree(key: ValueKey(s.phase), child: page),
    );
  }
}
