import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/domain/entities.dart';
import '../../core/domain/local_date.dart';
import '../../core/domain/money.dart';
import '../../core/domain/reports.dart';
import '../../core/domain/transfer_tracker.dart';
import '../common/widgets.dart';
import '../common/entry/add_sheet.dart';
import '../common/entry/add_form.dart';
import 'proof_viewer.dart';
import '../../core/error/ui_guard.dart';

/// Transfers to/from people: tracker with period + all-time totals.
class PeopleFilter {
  const PeopleFilter({this.preset = RangePreset.thisMonth, this.personId});
  final RangePreset? preset; // null = all time
  final String? personId;
}

class PeopleFilterNotifier extends AutoDisposeNotifier<PeopleFilter> {
  @override
  PeopleFilter build() => const PeopleFilter();
  void setPreset(RangePreset? p) => state = PeopleFilter(preset: p, personId: state.personId);
  void setPerson(String? id) => state = PeopleFilter(preset: state.preset, personId: id);
}

final peopleFilterProvider = NotifierProvider.autoDispose<PeopleFilterNotifier, PeopleFilter>(PeopleFilterNotifier.new);

class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key});

  static const _labels = <RangePreset?, String>{
    null: 'All time',
    RangePreset.today: 'Today',
    RangePreset.thisWeek: 'This week',
    RangePreset.thisMonth: 'This month',
    RangePreset.lastMonth: 'Last month',
    RangePreset.last30: 'Last 30 days',
    RangePreset.thisYear: 'This year',
  };

  Future<void> _export(List<Tx> rows, String tz, Map<String, String> payees, Map<String, String> accounts) async {
    final csv = TransactionCsv.build(
      txs: rows,
      tz: tz,
      categoryNames: const {},
      accountNames: accounts,
      payeeNames: payees,
    );
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/taka-people-transfers.csv');
    await file.writeAsString('${TransactionCsv.bom}$csv');
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'SpendWise people transfers'));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(peopleFilterProvider);
    final n = ref.read(peopleFilterProvider.notifier);
    final tz = ref.watch(timezoneProvider);
    final txs = ref.watch(transactionsProvider).valueOrNull ?? const <Tx>[];
    final payees = ref.watch(payeesProvider).valueOrNull ?? const <Payee>[];
    final accs = ref.watch(allAccountsProvider).valueOrNull ?? const <Account>[];
    final names = {for (final p in payees) p.id: p.name};
    final accNames = {for (final a in accs) a.id: a.name};
    final range = f.preset == null ? null : rangeForPreset(f.preset!, todayIn(tz));
    final t = TransferTrackerBuilder.build(allTxs: txs, tz: tz, range: range, personId: f.personId);
    final allTime = {for (final p in t.allTimeByPerson) p.payeeId: p};

    return Scaffold(
      appBar: AppBar(
        title: const Text('People'),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          IconButton(
            tooltip: 'Export CSV',
            icon: const Icon(Icons.ios_share),
            onPressed: t.history.isEmpty ? null : () => _export(t.history, tz, names, accNames),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddSheet(context, mode: AddMode.person, presetPerson: f.personId == null ? null : names[f.personId]),
        icon: const Icon(Icons.swap_horiz),
        label: const Text('Send / receive'),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        SizedBox(
          height: 48,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final e in _labels.entries)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(e.value),
                  selected: f.preset == e.key,
                  onSelected: (_) => n.setPreset(e.key),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String?>(
          initialValue: f.personId,
          decoration: const InputDecoration(labelText: 'Person'),
          isExpanded: true,
          items: [
            const DropdownMenuItem<String?>(value: null, child: Text('Everyone')),
            for (final p in payees)
              DropdownMenuItem<String?>(value: p.id, child: Text(p.name, overflow: TextOverflow.ellipsis)),
          ],
          onChanged: n.setPerson,
        ),
        const SizedBox(height: 12),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 76 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0),
          ),
          children: [
            _stat(context, 'Sent', formatMoney(t.sent)),
            _stat(context, 'Received', formatMoney(t.received)),
            _stat(context, 'Net sent', formatMoney(t.netSent)),
            _stat(context, 'Transfers', '${t.count} (${t.withProof} with proof)'),
          ],
        ),
        const SizedBox(height: 16),
        Text('By person', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (t.periodByPerson.isEmpty)
          const Text('No transfers in this period.')
        else
          for (final pt in t.periodByPerson)
            Card(
              child: ListTile(
                onTap: () => n.setPerson(pt.payeeId),
                title: Text(names[pt.payeeId] ?? 'Unknown'),
                subtitle: Text(
                  'This period: sent ${formatMoney(pt.sent)} · received ${formatMoney(pt.received)}\n'
                  'All time: sent ${formatMoney(allTime[pt.payeeId]?.sent ?? 0)} · received ${formatMoney(allTime[pt.payeeId]?.received ?? 0)}',
                ),
                trailing: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 110),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(formatMoney(pt.netSent), style: moneyStyleOf(context)),
                  ),
                ),
              ),
            ),
        const SizedBox(height: 16),
        Text('History', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (t.history.isEmpty)
          const Text('Nothing to show.')
        else
          for (final tx in t.history)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(tx.direction == TransferDirection.outbound ? Icons.north_east : Icons.south_west),
              title: Row(children: [
                Flexible(child: Text(names[tx.payeeId] ?? 'Unknown', overflow: TextOverflow.ellipsis)),
                if (tx.receiptPath != null)
                  const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.attach_file, size: 16)),
                if (tx.pending)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Icon(Icons.circle, size: 8, color: Theme.of(context).colorScheme.tertiary),
                  ),
              ]),
              subtitle: Text(formatDateTimeLocal(tx.occurredAtMs, tz) +
                  ((tx.note ?? '').isEmpty ? '' : ' · ${tx.note}')),
              trailing: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 110),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    formatMoney(tx.direction == TransferDirection.outbound ? -tx.amount : tx.amount, showSign: true),
                    style: moneyStyleOf(context),
                  ),
                ),
              ),
              onTap: () => _actions(context, ref, tx),
            ),
        const SizedBox(height: Tokens.fabClearance),
      ]),
    );
  }

  TextStyle moneyStyleOf(BuildContext c) =>
      const TextStyle(fontWeight: FontWeight.w600, fontFeatures: [FontFeature.tabularFigures()]);

  Widget _stat(BuildContext context, String label, String value) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: moneyStyleOf(context)),
            ),
          ]),
        ),
      );

  Future<void> _actions(BuildContext context, WidgetRef ref, Tx tx) async {
    final repo = ref.read(ledgerProvider);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (tx.receiptPath != null)
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('View proof'),
              onTap: () {
                Navigator.pop(ctx);
                showProofViewer(context, ref, tx);
              },
            ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(ctx);
              showAddSheet(context, editing: tx);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
            title: const Text('Delete'),
            onTap: () async {
              Navigator.pop(ctx);
              final ok = await showDialog<bool>(
                context: context,
                builder: (d) => AlertDialog(
                  title: const Text('Delete this transfer?'),
                  content: const Text('Its proof image is removed too. This cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
                    FilledButton(onPressed: () => Navigator.pop(d, true), child: const Text('Delete')),
                  ],
                ),
              );
              if (ok == true && context.mounted) await runGuarded(context, () => repo.deleteTransaction(tx.id), success: 'Deleted');
            },
          ),
        ]),
      ),
    );
  }
}
