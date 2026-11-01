import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/domain/entities.dart';
import '../common/widgets.dart';
import '../../core/error/ui_guard.dart';
import '../../core/error/app_error.dart';
import '../../core/ui/app_tabs.dart';
import '../../core/ui/category_style.dart';
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
                for (final n in [...expense, ...income]) {
                  final type = income.contains(n) ? 'income' : 'expense';
                  await repo.saveCategory(
                    name: n,
                    type: type,
                    icon: defaultIconKeyForName(n),
                    color: defaultColorHexFor(n),
                  );
                }
              }),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 88),
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
                      leading: CategoryAvatar.of(c, size: 40),
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
    // null = not chosen yet: icon follows the name, colour is derived.
    final iconKey = ValueNotifier<String?>(
      category == null ? null : resolveCategoryStyle(category).iconKey,
    );
    final colorHex = ValueNotifier<String?>(
      category == null ? null : _hexOf(resolveCategoryStyle(category).color),
    );
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(category == null ? 'New category' : 'Edit category'),
        content: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([name, iconKey, colorHex]),
              builder: (_, _) {
                final key = iconKey.value ?? defaultIconKeyForName(name.text);
                final color = parseHexColor(colorHex.value) ??
                    parseHexColor(defaultColorHexFor(category?.id ?? name.text))!;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CategoryAvatar(icon: categoryIcons[key]!, color: color, size: 64),
                );
              },
            ),
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<String?>(
              valueListenable: colorHex,
              builder: (_, hex, _) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final h in categoryPalette)
                    Semantics(
                      button: true,
                      selected: hex == h,
                      label: 'Colour $h',
                      child: GestureDetector(
                        onTap: () => colorHex.value = h,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: parseHexColor(h),
                            border: Border.all(
                              color: hex == h ? Theme.of(ctx).colorScheme.onSurface : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: hex == h ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: Listenable.merge([name, iconKey, colorHex]),
              builder: (_, _) {
                final active = iconKey.value ?? defaultIconKeyForName(name.text);
                final color = parseHexColor(colorHex.value) ??
                    parseHexColor(defaultColorHexFor(category?.id ?? name.text))!;
                return Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final e in categoryIcons.entries)
                      Semantics(
                        button: true,
                        selected: active == e.key,
                        label: e.key,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => iconKey.value = e.key,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: active == e.key ? color.withValues(alpha: 0.18) : null,
                              border: Border.all(
                                color: active == e.key ? color : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(e.value, size: 20, color: active == e.key ? color : null),
                          ),
                        ),
                      ),
                  ],
                );
              },
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
                      icon: iconKey.value ?? defaultIconKeyForName(name.text),
                      color: colorHex.value ?? defaultColorHexFor(category?.id ?? name.text),
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
    iconKey.dispose();
    colorHex.dispose();
  }

  static String _hexOf(Color c) {
    final v = c.toARGB32() & 0xFFFFFF;
    return '#${v.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}
