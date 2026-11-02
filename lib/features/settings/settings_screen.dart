import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../app/providers.dart';
import '../../core/data/data_reset.dart';
import '../../core/data/remote/remote_gateway.dart';
import '../../core/platform/app_lock.dart';
import '../../core/ui/app_logo.dart';
import '../../core/ui/app_snackbar.dart';
import '../../core/error/ui_guard.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).valueOrNull;
    return ListView(
      children: [
        const _BrandHeader(),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: Text(
            profile?.displayName?.isNotEmpty == true
                ? profile!.displayName!
                : 'Your name',
          ),
          subtitle: Text(
            '${profile?.currency ?? 'BDT'} · ${profile?.timezone ?? 'Asia/Dhaka'}',
          ),
          onTap: () => _editProfile(context, ref),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.people_outline),
          title: const Text('People transfers'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/people'),
        ),
        ListTile(
          leading: const Icon(Icons.account_balance_wallet_outlined),
          title: const Text('Accounts'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/accounts'),
        ),
        ListTile(
          leading: const Icon(Icons.category_outlined),
          title: const Text('Categories'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/categories'),
        ),
        ListTile(
          leading: const Icon(Icons.notifications_outlined),
          title: const Text('Reminders & alerts'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/reminders'),
        ),
        ListTile(
          leading: const Icon(Icons.sync),
          title: const Text('Sync & diagnostics'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/diagnostics'),
        ),
        const Divider(height: 1),
        const _PrivacySection(),
        const Divider(height: 1),
        ListTile(
          leading: Icon(
            Icons.delete_sweep_outlined,
            color: Theme.of(context).colorScheme.error,
          ),
          title: const Text('Delete my transactions & plans'),
          subtitle: const Text('Needs an internet connection'),
          onTap: () => _danger(context, ref, account: false),
        ),
        ListTile(
          leading: Icon(
            Icons.person_remove_outlined,
            color: Theme.of(context).colorScheme.error,
          ),
          title: const Text('Delete account'),
          subtitle: const Text('Needs an internet connection'),
          onTap: () => _danger(context, ref, account: true),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(
            Icons.logout,
            color: Theme.of(context).colorScheme.error,
          ),
          title: const Text('Sign out'),
          onTap: () => _signOut(context, ref),
        ),
      ],
    );
  }

  Future<void> _editProfile(BuildContext context, WidgetRef ref) async {
    final p = ref.read(profileProvider).valueOrNull;
    final name = TextEditingController(text: p?.displayName ?? '');
    final currency = ValueNotifier<String>(p?.currency ?? 'BDT');
    var zone = p?.timezone ?? 'Asia/Dhaka';
    final zones = tz.timeZoneDatabase.locations.keys.toList()..sort();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Display name'),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<String>(
              valueListenable: currency,
              builder: (_, value, _) => DropdownButtonFormField<String>(
                initialValue: value,
                decoration: const InputDecoration(labelText: 'Currency'),
                items: const [
                  DropdownMenuItem(value: 'BDT', child: Text('BDT ৳')),
                  DropdownMenuItem(value: 'USD', child: Text('USD')),
                  DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                  DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                  DropdownMenuItem(value: 'INR', child: Text('INR')),
                ],
                onChanged: (v) => currency.value = v ?? currency.value,
              ),
            ),
            const SizedBox(height: 12),
            Autocomplete<String>(
              initialValue: TextEditingValue(text: zone),
              optionsBuilder: (v) => zones
                  .where((z) => z.toLowerCase().contains(v.text.toLowerCase()))
                  .take(8),
              onSelected: (v) => zone = v,
              fieldViewBuilder: (c, ctl, fn, _) => TextField(
                controller: ctl,
                focusNode: fn,
                decoration: const InputDecoration(labelText: 'Timezone'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await runGuarded(
                ctx,
                () => ref
                    .read(ledgerProvider)
                    .saveProfile(
                      displayName: name.text.trim(),
                      currency: currency.value,
                      timezone: zones.contains(zone) ? zone : 'Asia/Dhaka',
                    ),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    name.dispose();
    currency.dispose();
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final db = ref.read(dbProvider);
    final pending = (await db.select(db.outbox).get()).length;
    if (!context.mounted) return;
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: Text(
          pending == 0
              ? 'Everything is synced. Local data stays on this device until another account signs in.'
              : '$pending change(s) have not synced yet. Signing out and discarding them cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          if (pending > 0)
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'sync'),
              child: const Text('Sync now'),
            ),
          if (pending > 0)
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'export'),
              child: const Text('Export pending'),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'out'),
            child: Text(pending > 0 ? 'Sign out & discard' : 'Sign out'),
          ),
        ],
      ),
    );
    if (choice == 'sync') {
      await ref.read(syncEngineProvider).syncNow();
    } else if (choice == 'export') {
      final json = await exportOutboxJson(db);
      if (context.mounted) {
        showDialog<void>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Pending changes (JSON)'),
            content: SingleChildScrollView(child: SelectableText(json)),
          ),
        );
      }
    } else if (choice == 'out') {
      await db.delete(db.outbox).go();
      await Supabase.instance.client.auth.signOut();
    }
  }
}

class _PrivacySection extends ConsumerWidget {
  const _PrivacySection();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lock = ref.watch(lockSettingsProvider);
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.fingerprint),
          title: const Text('App lock'),
          subtitle: const Text('Require biometrics or device passcode'),
          value: lock.enabled,
          onChanged: (v) async {
            if (v && !await deviceCanAuthenticate()) {
              if (context.mounted) {
                AppSnack.error(
                  context,
                  'Set up a screen lock or biometrics on this device first.',
                );
              }
              return;
            }
            final notifier = ref.read(lockSettingsProvider.notifier);
            if (!v &&
                !await notifier.authenticate('Confirm to turn off app lock')) {
              if (context.mounted) {
                AppSnack.error(
                  context,
                  'Authentication failed — app lock stays on.',
                );
              }
              return;
            }
            await notifier.set(enabled: v);
          },
        ),
        if (lock.enabled)
          ListTile(
            contentPadding: const EdgeInsets.only(left: 72, right: 16),
            title: const Text('Lock after'),
            trailing: DropdownButton<int>(
              value: lock.timeoutMinutes,
              items: const [
                DropdownMenuItem(value: 0, child: Text('Immediately')),
                DropdownMenuItem(value: 1, child: Text('1 minute')),
                DropdownMenuItem(value: 5, child: Text('5 minutes')),
                DropdownMenuItem(value: 15, child: Text('15 minutes')),
              ],
              onChanged: (v) => ref
                  .read(lockSettingsProvider.notifier)
                  .set(timeoutMinutes: v),
            ),
          ),
      ],
    );
  }
}

Future<void> _danger(
  BuildContext context,
  WidgetRef ref, {
  required bool account,
}) async {
  final engine = ref.read(syncEngineProvider);
  if (!await engine.remote.isReachable()) {
    if (context.mounted) {
      AppSnack.error(context, 'You need an internet connection for this.');
    }
    return;
  }
  if (!context.mounted) return;
  final ok = await showDialog<bool>(
    context: context,
    builder: (d) => AlertDialog(
      title: Text(
        account ? 'Delete your account?' : 'Delete all transactions & plans?',
      ),
      content: Text(
        account
            ? 'This permanently deletes your account and all data on every device. It cannot be undone.'
            : 'This permanently deletes every transaction and plan on every device. Accounts and categories are kept.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(d, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(d, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (ok != true) return;
  // Push anything pending first so we don't delete around unsent changes.
  await engine.syncNow();
  final reset = DataReset(ref.read(dbProvider), ref.read(supabaseProvider));
  try {
    if (account) {
      await reset.deleteAccount();
    } else {
      await reset.deleteTransactionsAndPlans();
      if (context.mounted) {
        AppSnack.success(context, 'Transactions and plans deleted.');
      }
    }
  } catch (_) {
    if (context.mounted) {
      AppSnack.error(context, 'Could not complete that. Please try again.');
    }
  }
}

/// Logo, app name and version at the top of Settings.
class _BrandHeader extends ConsumerWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final version = ref.watch(packageInfoProvider).valueOrNull?.version;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          const AppLogo(size: 52, shadow: true),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLogo.name, style: theme.textTheme.titleLarge),
                if (version != null)
                  Text(
                    'Version $version',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
