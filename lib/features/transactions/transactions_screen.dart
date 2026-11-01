import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/domain/entities.dart';
import '../../core/domain/local_date.dart';
import '../../core/domain/money.dart';
import '../../core/ui/async_value_view.dart';
import '../../core/ui/skeleton.dart';
import '../common/widgets.dart';
import '../transfers/proof_viewer.dart';
import '../common/entry/add_sheet.dart';
import 'application/transaction_filter.dart';
import '../../core/error/ui_guard.dart';
import '../../app/refresh_actions.dart';
import '../../core/ui/pull_refresh.dart';

/// Transactions: search + filters over the local database (works offline).
class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = ref.watch(groupedTransactionsProvider);
    final hasAny = ref.watch(
      visibleTransactionsProvider.select(
        (a) => a.valueOrNull?.isNotEmpty ?? false,
      ),
    );
    final filterActive = ref.watch(txFilterProvider.select((f) => f.isActive));

    return Column(
      children: [
        const _SearchField(),
        const _FilterRow(),
        Expanded(
          child: AsyncValueView<List<DayGroup>>(
            value: grouped,
            loading: const SkeletonTxList(),
            onRetry: () => ref.invalidate(visibleTransactionsProvider),
            data: (groups) {
              if (groups.isEmpty) {
                return hasAny || filterActive
                    ? EmptyState(
                        'Try a different search or clear the filters.',
                        title: 'No matches',
                        icon: Icons.search_off,
                        actionLabel: 'Clear filters',
                        onAction: ref.read(txFilterProvider.notifier).clear,
                      )
                    : EmptyState(
                        'Tap Add to record your first expense or income. Everything is saved on your phone, even offline.',
                        title: 'No transactions yet',
                        icon: Icons.receipt_long_outlined,
                        actionLabel: 'Add a transaction',
                        onAction: () => showAddSheet(context),
                      );
              }
              return _GroupedList(groups: groups);
            },
          ),
        ),
      ],
    );
  }
}

/// Debounced search box; the controller is widget-local ephemeral state.
class _SearchField extends ConsumerStatefulWidget {
  const _SearchField();
  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  final _ctl = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filters cleared elsewhere (e.g. "Clear filters") empty the box too.
    ref.listen(txFilterProvider.select((f) => f.query), (_, q) {
      if (q.isEmpty && _ctl.text.isNotEmpty) _ctl.clear();
    });
    return Padding(
      padding: const EdgeInsets.fromLTRB(Tokens.s16, Tokens.s8, Tokens.s16, 0),
      child: TextField(
        controller: _ctl,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Search merchant, note, category',
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _ctl,
            builder: (_, v, _) => v.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _ctl.clear();
                      ref.read(txFilterProvider.notifier).setQuery('');
                    },
                  ),
          ),
        ),
        onChanged: (v) {
          _debounce?.cancel();
          _debounce = Timer(
            const Duration(milliseconds: 250),
            () => ref.read(txFilterProvider.notifier).setQuery(v),
          );
        },
      ),
    );
  }
}

class _FilterRow extends ConsumerWidget {
  const _FilterRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(txFilterProvider);
    final n = ref.read(txFilterProvider.notifier);
    final cats =
        ref.watch(allCategoriesProvider).valueOrNull ?? const <Category>[];
    final accs =
        ref.watch(allAccountsProvider).valueOrNull ?? const <Account>[];

    return SizedBox(
      height: 56 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _Menu(
            label: 'Category',
            value: f.categoryId,
            options: {for (final c in cats) c.id: c.name},
            onChanged: n.setCategory,
          ),
          _Menu(
            label: 'Account',
            value: f.accountId,
            options: {for (final a in accs) a.id: a.name},
            onChanged: n.setAccount,
          ),
          _Menu(
            label: 'Planned',
            value: f.planned,
            options: const {'planned': 'Planned', 'unplanned': 'Unplanned'},
            onChanged: n.setPlanned,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InputChip(
              avatar: const Icon(Icons.date_range, size: 18),
              label: Text(
                f.range == null ? 'Dates' : '${f.range!.from} → ${f.range!.to}',
              ),
              selected: f.range != null,
              onPressed: () async {
                final r = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDateRange: f.range == null
                      ? null
                      : DateTimeRange(
                          start: DateTime(
                            f.range!.from.year,
                            f.range!.from.month,
                            f.range!.from.day,
                          ),
                          end: DateTime(
                            f.range!.to.year,
                            f.range!.to.month,
                            f.range!.to.day,
                          ),
                        ),
                );
                if (r != null) {
                  n.setRange(
                    DateRange(
                      LocalDate(r.start.year, r.start.month, r.start.day),
                      LocalDate(r.end.year, r.end.month, r.end.day),
                    ),
                  );
                }
              },
              onDeleted: f.range == null ? null : () => n.setRange(null),
            ),
          ),
        ],
      ),
    );
  }
}

class _Menu extends StatelessWidget {
  const _Menu({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final String label;
  final String? value;
  final Map<String, String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: PopupMenuButton<String?>(
        tooltip: 'Filter by ${label.toLowerCase()}',
        onSelected: onChanged,
        itemBuilder: (_) => [
          PopupMenuItem<String?>(
            value: null,
            child: Text('All ${label.toLowerCase()}s'),
          ),
          for (final e in options.entries)
            PopupMenuItem<String?>(value: e.key, child: Text(e.value)),
        ],
        child: Chip(
          label: Text(value == null ? label : (options[value] ?? label)),
          deleteIcon: const Icon(Icons.arrow_drop_down, size: 18),
          onDeleted: null,
          backgroundColor: value == null
              ? null
              : theme.colorScheme.primaryContainer,
        ),
      ),
    );
  }
}

/// Day-grouped list built lazily: each row is created only when scrolled to.
class _GroupedList extends ConsumerWidget {
  const _GroupedList({required this.groups});
  final List<DayGroup> groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tz = ref.watch(timezoneProvider);
    final today = todayIn(tz);
    final catMap = ref.watch(
      allCategoriesProvider.select(
        (a) => {for (final c in a.valueOrNull ?? const <Category>[]) c.id: c},
      ),
    );
    final accMap = ref.watch(
      allAccountsProvider.select(
        (a) => {for (final x in a.valueOrNull ?? const <Account>[]) x.id: x},
      ),
    );
    final payeeNames = ref.watch(
      payeesProvider.select(
        (a) => {for (final p in a.valueOrNull ?? const <Payee>[]) p.id: p.name},
      ),
    );
    final theme = Theme.of(context);
    final hasMore = ref.watch(txHasMoreProvider);

    // Flatten to header + row entries so ListView.builder stays lazy.
    final entries = <Object>[];
    for (final g in groups) {
      entries.add(g);
      entries.addAll(g.items);
    }

    return RefreshableList.builder(
      onRefresh: () => refreshAndNotify(ref, context),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: entries.length + (hasMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == entries.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: OutlinedButton.icon(
                onPressed: ref.read(txLimitProvider.notifier).more,
                icon: const Icon(Icons.expand_more),
                label: const Text('Load older transactions'),
              ),
            ),
          );
        }
        final e = entries[i];
        if (e is DayGroup) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      friendlyDay(e.day, today),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                if (e.spent > 0)
                  Text(
                    'Spent ${formatMoney(e.spent)}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFeatures: moneyFeatures,
                    ),
                  ),
              ],
            ),
          );
        }
        final t = e as Tx;
        return TxTile(
          key: ValueKey(t.id),
          tx: t,
          categories: catMap,
          accounts: accMap,
          payeeNames: payeeNames,
          tz: tz,
          timeOnly: true,
          onTap: () => _showActions(context, ref, t),
        );
      },
    );
  }
}

Future<void> _showActions(BuildContext context, WidgetRef ref, Tx t) async {
  final repo = ref.read(ledgerProvider);
  final isTransfer =
      t.type == TxType.transfer || t.type == TxType.personTransfer;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (t.receiptPath != null)
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('View proof'),
              onTap: () {
                Navigator.pop(ctx);
                showProofViewer(context, ref, t);
              },
            ),
          if (t.type != TxType.transfer)
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(ctx);
                showAddSheet(context, editing: t);
              },
            ),
          if (!isTransfer)
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: const Text('Duplicate'),
              onTap: () async {
                Navigator.pop(ctx);
                await runGuarded(
                  context,
                  () => repo.duplicateTransaction(t.id),
                  success: 'Duplicated',
                );
              },
            ),
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              t.type == TxType.transfer
                  ? 'Delete transfer (both legs)'
                  : 'Delete',
            ),
            onTap: () async {
              Navigator.pop(ctx);
              final ok = await showDialog<bool>(
                context: context,
                builder: (d) => AlertDialog(
                  title: const Text('Delete this transaction?'),
                  content: const Text('This cannot be undone.'),
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
              if (ok == true && context.mounted) {
                await runGuarded(
                  context,
                  () => repo.deleteTransaction(t.id),
                  success: 'Deleted',
                );
              }
            },
          ),
        ],
      ),
    ),
  );
}
