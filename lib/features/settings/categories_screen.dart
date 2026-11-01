import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/domain/entities.dart';
import '../common/widgets.dart';
import '../../core/error/ui_guard.dart';
import '../../core/error/app_error.dart';
import '../../core/ui/app_tabs.dart';
import '../../core/ui/async_value_view.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catsAsync = ref.watch(allCategoriesProvider);
    if (catsAsync.hasError && !catsAsync.hasValue) {
      return Scaffold(
        appBar: AppBar(title: const Text('Categories')),
        body: ErrorState(message: friendlyMessage(catsAsync.error!), onRetry: () => ref.invalidate(allCategoriesProvider)),
      );
    }
    final cats = catsAsync.valueOrNull ?? const <Category>[];
    final repo = ref.read(ledgerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add category',
        onPressed: () => _edit(context, ref),
        child: const Icon(Icons.add),
      ),
      body: cats.isEmpty
          ? EmptyState(
              'Categories group your spending and income. Start with a common set — you can rename or archive them anytime.',
              title: 'No categories yet',
              icon: Icons.category_outlined,
              actionLabel: 'Add starter categories',
              onAction: () => runGuarded(context, () async {
                const expense = [
                  'Food',
                  'Transport',
                  'Bills',
                  'Shopping',
                  'Health',
                  'Entertainment',
                  'Other',
                ];
                const income = ['Salary', 'Other income'];
                for (final n in expense) {
                  await repo.saveCategory(name: n, type: 'expense');
                }
                for (final n in income) {
                  await repo.saveCategory(name: n, type: 'income');
                }
              }),
            )
          : ListView(
              children: [
                for (final type in const ['expense', 'income']) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Text(
                      type == 'expense' ? 'Expense' : 'Income',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  for (final c in cats.where((c) => c.type == type))
                    ListTile(
                      title: Text(c.name + (c.isArchived ? ' (archived)' : '')),
                      onTap: () => _edit(context, ref, category: c),
                      trailing: IconButton(
                        tooltip: c.isArchived ? 'Restore' : 'Archive',
                        icon: Icon(
                          c.isArchived
                              ? Icons.unarchive_outlined
                              : Icons.archive_outlined,
                        ),
                        onPressed: () => runGuarded(
                          context,
                          () => repo.setCategoryArchived(c.id, !c.isArchived),
                        ),
                      ),
                    ),
                ],
              ],
            ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, {
    Category? category,
  }) async {
    final name = TextEditingController(text: category?.name ?? '');
    final type = ValueNotifier<String>(category?.type ?? 'expense');
    final error = ValueNotifier<String?>(null);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(category == null ? 'New category' : 'Edit category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            if (category == null)
              ValueListenableBuilder<String>(
                valueListenable: type,
                builder: (_, value, _) => AppTabs<String>(
                  compact: true,
                  tabs: const [
                    AppTab('expense', 'Expense'),
                    AppTab('income', 'Income'),
                  ],
                  value: value,
                  onChanged: (v) => type.value = v,
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
              final r = await guard(
                () => ref
                    .read(ledgerProvider)
                    .saveCategory(
                      id: category?.id,
                      name: name.text,
                      type: type.value,
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
    type.dispose();
    error.dispose();
  }
}
