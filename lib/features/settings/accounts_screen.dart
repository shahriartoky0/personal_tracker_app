import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/domain/entities.dart';
import '../../core/domain/money.dart';
import '../common/widgets.dart';
import '../../core/error/ui_guard.dart';
import '../../core/error/app_error.dart';
import '../../core/ui/async_value_view.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(allAccountsProvider);
    if (accountsAsync.hasError && !accountsAsync.hasValue) {
      return Scaffold(
        appBar: AppBar(title: const Text('Accounts')),
        body: ErrorState(message: friendlyMessage(accountsAsync.error!), onRetry: () => ref.invalidate(allAccountsProvider)),
      );
    }
    final accounts = accountsAsync.valueOrNull ?? const <Account>[];
    final net = ref.watch(accountNetProvider).valueOrNull ?? const <String, int>{};
    final repo = ref.read(ledgerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add account',
        onPressed: () => _edit(context, ref),
        child: const Icon(Icons.add),
      ),
      body: accounts.isEmpty
          ? EmptyState(
              'An account is where your money lives — cash, a bank, a card or a mobile wallet.',
              title: 'No accounts yet',
              icon: Icons.account_balance_wallet_outlined,
              actionLabel: 'Add an account',
              onAction: () => _edit(context, ref),
            )
          : ListView(
              children: [
                for (final a in accounts)
                  ListTile(
                    title: Text(a.name + (a.isArchived ? ' (archived)' : '')),
                    subtitle: Text(a.type),
                    trailing: MoneyText(
                      a.openingBalance + (net[a.id] ?? 0),
                    ),
                    onTap: () => _edit(context, ref, account: a),
                    onLongPress: () => runGuarded(
                      context,
                      () => repo.setAccountArchived(a.id, !a.isArchived),
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Long-press an account to archive or restore it.',
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, {
    Account? account,
  }) async {
    final name = TextEditingController(text: account?.name ?? '');
    final opening = TextEditingController(
      text: account == null ? '' : toDecimalString(account.openingBalance),
    );
    final type = ValueNotifier<String>(account?.type ?? 'cash');
    final error = ValueNotifier<String?>(null);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(account == null ? 'New account' : 'Edit account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<String>(
              valueListenable: type,
              builder: (_, value, _) => DropdownButtonFormField<String>(
                initialValue: value,
                decoration: const InputDecoration(labelText: 'Type'),
                items: [
                  for (final t in const [
                    'cash',
                    'bank',
                    'card',
                    'mobile',
                    'other',
                  ])
                    DropdownMenuItem(value: t, child: Text(t)),
                ],
                onChanged: (v) => type.value = v ?? type.value,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: opening,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Opening balance',
                prefixText: '৳ ',
              ),
            ),
            ValueListenableBuilder<String?>(
              valueListenable: error,
              builder: (_, e, _) => e == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        e,
                        style: TextStyle(
                          color: Theme.of(ctx).colorScheme.error,
                        ),
                      ),
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
              final txt = opening.text.trim();
              final neg = txt.startsWith('-');
              final parsed = txt.isEmpty
                  ? 0
                  : parseMoney(neg ? txt.substring(1) : txt);
              if (parsed == null) {
                error.value = 'Enter a valid opening balance.';
                return;
              }
              final r = await guard(
                () => ref
                    .read(ledgerProvider)
                    .saveAccount(
                      id: account?.id,
                      name: name.text,
                      type: type.value,
                      openingBalance: neg ? -parsed : parsed,
                    ),
              );
              if (r.isOk) {
                if (ctx.mounted) Navigator.pop(ctx);
              } else {
                error.value = r.failureOrNull!.message;
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    name.dispose();
    opening.dispose();
    type.dispose();
    error.dispose();
  }
}
