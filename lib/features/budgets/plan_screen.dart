import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/domain/calculators.dart';
import '../../core/domain/entities.dart';
import '../../core/domain/local_date.dart';
import '../../core/domain/money.dart';
import '../../core/ui/app_snackbar.dart';
import '../../core/ui/motion.dart';
import '../common/widgets.dart';
import 'application/plan_controller.dart';
import '../../core/error/ui_guard.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planControllerProvider);
    final c = ref.read(planControllerProvider.notifier);
    final tz = ref.watch(timezoneProvider);
    final today = todayIn(tz);
    final date = plan.date ?? today;
    final theme = Theme.of(context);

    final cats = (ref.watch(categoriesProvider).valueOrNull ?? const <Category>[]).where((x) => x.type == 'expense').toList();
    final budget = ref.watch(budgetsProvider.select((a) => a.valueOrNull?.where((b) => b.date == date.value).firstOrNull));
    final txs = ref.watch(transactionsProvider).valueOrNull ?? const <Tx>[];
    final planned = ref.watch(plannedExpensesProvider(date.value)).valueOrNull ?? const <PlannedExpense>[];
    final closed = budget?.isClosed ?? false;
    final summary = BudgetCalculator.summarizeDay(
      budget: budget,
      dayTxs: TransactionCalculator.onLocalDate(txs, date, tz).toList(),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(Tokens.s16, Tokens.s8, Tokens.s16, Tokens.s24),
      children: [
        Row(children: [
          IconButton(tooltip: 'Previous day', onPressed: () => c.shiftDay(-1), icon: const Icon(Icons.chevron_left)),
          Expanded(
            child: Center(
              child: Column(children: [
                Text(friendlyDay(date, today), style: theme.textTheme.titleMedium),
                Text(date.value, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ]),
            ),
          ),
          IconButton(tooltip: 'Next day', onPressed: () => c.shiftDay(1), icon: const Icon(Icons.chevron_right)),
        ]),
        const SizedBox(height: Tokens.s8),
        SectionCard(
          title: 'Daily limit',
          trailing: closed ? const Chip(label: Text('Closed'), avatar: Icon(Icons.lock_outline, size: 16)) : null,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextField(
              controller: c.limit,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(prefixText: '৳ ', labelText: 'Total for the day'),
            ),
            if (budget != null && budget.originalLimit != budget.totalLimit)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('was ${formatMoney(budget.originalLimit)}', style: theme.textTheme.bodySmall),
              ),
            const SizedBox(height: Tokens.s12),
            ValueListenableBuilder<({int limit, int allocated})>(
              valueListenable: c.totals,
              builder: (context, t, _) => Row(children: [
                if (t.allocated > t.limit) Icon(Icons.error_outline, size: 16, color: theme.colorScheme.error),
                if (t.allocated > t.limit) const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Allocated ${formatMoney(t.allocated)} · Not allocated ${formatMoney(t.limit - t.allocated)}',
                    style: TextStyle(color: t.allocated > t.limit ? theme.colorScheme.error : null),
                  ),
                ),
              ]),
            ),
          ]),
        ).enter(context),
        const SizedBox(height: Tokens.s12),
        SectionCard(
          title: 'By category',
          child: cats.isEmpty
              ? const Text('Add expense categories in Settings first.')
              : Column(children: [
                  for (final cat in cats)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: TextField(
                        controller: c.alloc(cat.id),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: cat.name, prefixText: '৳ '),
                      ),
                    ),
                ]),
        ).enter(context, index: 1),
        if (plan.error != null)
          Padding(
            padding: const EdgeInsets.only(top: Tokens.s12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.error_outline, size: 18, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              Expanded(child: Text(plan.error!, style: TextStyle(color: theme.colorScheme.error))),
            ]),
          ),
        const SizedBox(height: Tokens.s12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          FilledButton.icon(
            onPressed: plan.saving
                ? null
                : () async {
                    final ok = await c.save();
                    if (ok && context.mounted) AppSnack.success(context, 'Plan saved');
                  },
            icon: plan.saving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check),
            label: const Text('Save plan'),
          ),
          OutlinedButton(
            onPressed: () async {
              final err = await c.copyYesterday();
              if (err != null && context.mounted) AppSnack.error(context, err);
            },
            child: const Text('Copy yesterday'),
          ),
          if (budget != null)
            OutlinedButton(
              onPressed: () => c.setClosed(budget.id, !closed),
              child: Text(closed ? 'Reopen day' : 'Close day'),
            ),
        ]),
        const SizedBox(height: Tokens.s16),
        if (budget != null)
          SectionCard(
            title: 'Day review',
            child: Column(children: [
              _kv(context, 'Planned limit', formatMoney(summary.limit)),
              _kv(context, 'Spent', formatMoney(summary.spent)),
              _kv(context, 'Unplanned', formatMoney(summary.unplanned)),
              _kv(context, 'Left', formatMoney(summary.remaining), bold: true),
            ]),
          ).enter(context, index: 2),
        const SizedBox(height: Tokens.s12),
        SectionCard(
          title: 'Planned expenses',
          trailing: IconButton(
            tooltip: 'Add planned expense',
            icon: const Icon(Icons.add),
            onPressed: () => _addPlanned(context, ref, date, cats),
          ),
          child: planned.isEmpty
              ? const Text('Nothing planned for this day.')
              : Column(children: [
                  for (final p in planned)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(p.title),
                      subtitle: Text('${formatMoney(p.expectedAmount)} · ${p.status}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) async {
                          final repo = ref.read(ledgerProvider);
                          if (v == 'delete') {
                            await runGuarded(context, () => repo.deletePlannedExpense(p.id));
                          } else {
                            await runGuarded(context, () => repo.setPlannedExpenseStatus(p.id, v));
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'completed', child: Text('Mark completed')),
                          PopupMenuItem(value: 'skipped', child: Text('Skip')),
                          PopupMenuItem(value: 'planned', child: Text('Mark planned')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ),
                ]),
        ),
      ],
    );
  }

  Widget _kv(BuildContext context, String k, String v, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Expanded(child: Text(k)),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(v, style: moneyStyle(context, weight: bold ? FontWeight.w700 : FontWeight.w500)),
            ),
          ),
        ]),
      );

  Future<void> _addPlanned(BuildContext context, WidgetRef ref, LocalDate date, List<Category> cats) async {
    final title = TextEditingController();
    final amount = TextEditingController();
    final cat = ValueNotifier<String?>(cats.isNotEmpty ? cats.first.id : null);
    final repo = ref.read(ledgerProvider);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Planned expense'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 8),
          TextField(
            controller: amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Expected amount', prefixText: '৳ '),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<String?>(
            valueListenable: cat,
            builder: (_, value, _) => DropdownButtonFormField<String>(
              initialValue: value,
              isExpanded: true,
              items: [
                for (final x in cats)
                  DropdownMenuItem(value: x.id, child: Text(x.name, overflow: TextOverflow.ellipsis)),
              ],
              onChanged: (v) => cat.value = v,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
          ),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final amt = parseMoney(amount.text);
              if (amt == null || amt <= 0 || title.text.trim().isEmpty || cat.value == null) return;
              await runGuarded(ctx, () => repo.addPlannedExpense(date: date, categoryId: cat.value!, title: title.text, expectedAmount: amt));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    title.dispose();
    amount.dispose();
    cat.dispose();
  }
}
