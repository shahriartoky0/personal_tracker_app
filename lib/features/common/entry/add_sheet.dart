import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/providers.dart';
import '../../../app/theme.dart';
import '../../../core/domain/entities.dart';
import '../../../core/ui/app_sheet.dart';
import '../../../core/ui/app_tabs.dart';
import '../../../core/ui/category_style.dart';
import '../../../core/ui/motion.dart';
import '../widgets.dart';
import 'add_form.dart';

/// Opens the add/edit sheet. One frame for every kind of entry (expense,
/// income, own-account transfer, person transfer): switching kinds swaps the
/// content inside the same sheet, never pops and reopens another one.
Future<void> showAddSheet(
  BuildContext context, {
  Tx? editing,
  AddMode? mode,
  String? presetPerson,
}) {
  final args = AddArgs(
    editing: editing,
    initialMode: mode,
    presetPerson: presetPerson,
  );
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (_) => AddSheetContent(args: args),
  );
}

class AddSheetContent extends ConsumerWidget {
  const AddSheetContent({super.key, required this.args});
  final AddArgs args;

  String _title(AddFormState s) {
    if (args.editing != null) {
      return s.mode == AddMode.person ? 'Edit transfer' : 'Edit transaction';
    }
    return switch (s.mode) {
      AddMode.expense => 'New expense',
      AddMode.income => 'New income',
      AddMode.transfer => 'Transfer between accounts',
      AddMode.person => 'Transfer with a person',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(addFormProvider(args));
    final c = ref.read(addFormProvider(args).notifier);
    final accountsAsync = ref.watch(accountsProvider);

    if (s.saved) {
      return _SavedView(onDone: () => Navigator.of(context).maybePop());
    }

    final accounts = accountsAsync.valueOrNull;
    final noAccounts = accounts != null && accounts.isEmpty;
    final editing = args.editing != null;

    return AppSheetFrame(
      title: _title(s),
      header: (editing || noAccounts) ? null : _ModeTabs(args: args),
      body: noAccounts
          ? EmptyState(
              'Add an account first so we know where this money comes from.',
              title: 'No account yet',
              icon: Icons.account_balance_wallet_outlined,
              actionLabel: 'Add an account',
              onAction: () {
                final router = GoRouter.of(context);
                Navigator.of(context).pop();
                router.push('/accounts');
              },
            )
          : AnimatedSize(
              duration: Motion.reduced(context) ? Duration.zero : Motion.normal,
              curve: Motion.curve,
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: Motion.reduced(context)
                    ? Duration.zero
                    : Motion.normal,
                switchInCurve: Motion.curve,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.03),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(s.mode),
                  child: _Form(args: args),
                ),
              ),
            ),
      footer: noAccounts
          ? null
          : FilledButton.icon(
              onPressed: s.saving
                  ? null
                  : () async {
                      final ok = await c.submit();
                      if (ok) HapticFeedback.mediumImpact();
                    },
              icon: s.saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(editing ? 'Save changes' : 'Save'),
            ),
    );
  }
}

/// Success state: Lottie check, then the sheet closes itself.
class _SavedView extends StatefulWidget {
  const _SavedView({required this.onDone});
  final VoidCallback onDone;
  @override
  State<_SavedView> createState() => _SavedViewState();
}

class _SavedViewState extends State<_SavedView> {
  Timer? _t;
  @override
  void initState() {
    super.initState();
    _t = Timer(const Duration(milliseconds: 1100), widget.onDone);
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SuccessRing(
          child: const LottieView(
            LottieAsset.success,
            size: 120,
            fallback: Icons.check_circle,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Saved',
          style: Theme.of(context).textTheme.titleMedium,
        ).enter(context, index: 3),
        const SizedBox(height: 4),
        Text(
          'Synced when you are online',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ).enter(context, index: 5),
      ],
    ),
  );
}

class _ModeTabs extends ConsumerWidget {
  const _ModeTabs({required this.args});
  final AddArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(addFormProvider(args).select((s) => s.mode));
    final c = ref.read(addFormProvider(args).notifier);
    final isTransfer = mode == AddMode.transfer || mode == AddMode.person;
    final primary = isTransfer ? AddMode.transfer : mode;
    return Column(
      children: [
        AppTabs<AddMode>(
          tabs: const [
            AppTab(AddMode.expense, 'Expense', Icons.north_east),
            AppTab(AddMode.income, 'Income', Icons.south_west),
            AppTab(AddMode.transfer, 'Transfer', Icons.swap_horiz),
          ],
          value: primary,
          onChanged: (v) {
            // Tapping Transfer while already in a transfer kind keeps the sub-choice.
            if (v == AddMode.transfer && isTransfer) return;
            c.setMode(v);
          },
        ),
        if (isTransfer) ...[
          const SizedBox(height: Tokens.s8),
          AppTabs<AddMode>(
            compact: true,
            tabs: const [
              AppTab(AddMode.transfer, 'My accounts'),
              AppTab(AddMode.person, 'Person'),
            ],
            value: mode,
            onChanged: c.setMode,
          ),
        ],
      ],
    );
  }
}

class _Form extends ConsumerWidget {
  const _Form({required this.args});
  final AddArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(addFormProvider(args));
    final c = ref.read(addFormProvider(args).notifier);
    final tz = ref.watch(timezoneProvider);
    final accounts =
        ref.watch(accountsProvider).valueOrNull ?? const <Account>[];
    final accountId =
        s.accountId ?? (accounts.isNotEmpty ? accounts.first.id : null);
    final whenMs = s.whenMs ?? DateTime.now().millisecondsSinceEpoch;
    final isCat = s.mode == AddMode.expense || s.mode == AddMode.income;
    final theme = Theme.of(context);

    Widget gap([double h = Tokens.s12]) => SizedBox(height: h);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (s.mode == AddMode.person) ...[
          AppTabs<TransferDirection>(
            compact: true,
            tabs: const [
              AppTab(TransferDirection.outbound, 'I sent', Icons.north_east),
              AppTab(TransferDirection.inbound, 'I received', Icons.south_west),
            ],
            value: s.direction,
            onChanged: c.setDirection,
          ),
          gap(Tokens.s8),
          Text(
            'Moves your balance but is not counted as spending or income.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          gap(),
        ],
        ShakeOnError(
          error: s.errors['amount'],
          child: TextField(
            controller: c.amount,
            autofocus: args.editing == null,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            style: moneyStyle(
              context,
              size: 32,
              weight: FontWeight.w700,
              display: true,
              tabular: false,
            ),
            decoration: InputDecoration(
              prefixText: '৳ ',
              labelText: 'Amount',
              errorText: s.errors['amount'],
            ),
          ),
        ),
        gap(),
        if (isCat) _CategoryPicker(args: args),
        if (s.mode == AddMode.person) ...[
          TextField(
            controller: c.person,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Person',
              errorText: s.errors['personName'],
            ),
          ),
          _PersonSuggestions(args: args),
          gap(),
        ],
        DropdownButtonFormField<String>(
          key: ValueKey('acc-$accountId'),
          initialValue: accountId,
          decoration: InputDecoration(
            labelText: s.mode == AddMode.transfer ? 'From account' : 'Account',
            errorText: s.errors['accountId'] ?? s.errors['fromId'],
          ),
          isExpanded: true,
          items: [
            for (final a in accounts)
              DropdownMenuItem(
                value: a.id,
                child: Text(a.name, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: c.setAccount,
        ),
        if (s.mode == AddMode.transfer) ...[
          gap(),
          DropdownButtonFormField<String>(
            key: ValueKey('to-${s.toAccountId}'),
            initialValue: s.toAccountId,
            decoration: InputDecoration(
              labelText: 'To account',
              errorText: s.errors['toId'],
            ),
            isExpanded: true,
            items: [
              for (final a in accounts)
                DropdownMenuItem(
                  value: a.id,
                  child: Text(a.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: c.setToAccount,
          ),
        ],
        if (s.mode == AddMode.expense)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Planned expense'),
            subtitle: const Text('Off means unplanned'),
            value: s.planned,
            onChanged: c.setPlanned,
          ),
        gap(Tokens.s8),
        OutlinedButton.icon(
          icon: const Icon(Icons.schedule),
          label: Text(formatDateTimeLocal(whenMs, tz)),
          onPressed: () async {
            final picked = await pickDateTime(context, whenMs, tz);
            if (picked != null) c.setWhen(picked);
          },
        ),
        if (isCat) ...[
          gap(),
          TextField(
            controller: c.merchant,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Merchant (optional)',
              errorText: s.errors['merchant'],
            ),
          ),
        ],
        gap(),
        TextField(
          controller: c.note,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Note (optional)',
            errorText: s.errors['note'],
          ),
        ),
        if (s.mode == AddMode.person) ...[gap(), _ProofSection(args: args)],
        if (s.formError != null)
          Padding(
            padding: const EdgeInsets.only(top: Tokens.s12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 18,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.formError!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CategoryPicker extends ConsumerWidget {
  const _CategoryPicker({required this.args});
  final AddArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(addFormProvider(args).select((s) => s.mode));
    final selected = ref.watch(
      addFormProvider(args).select((s) => s.categoryId),
    );
    final error = ref.watch(
      addFormProvider(args).select((s) => s.errors['categoryId']),
    );
    final c = ref.read(addFormProvider(args).notifier);
    final type = mode == AddMode.income ? 'income' : 'expense';
    final cats =
        (ref.watch(categoriesProvider).valueOrNull ?? const <Category>[])
            .where((x) => x.type == type)
            .toList();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: Tokens.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          if (cats.isEmpty)
            TextButton.icon(
              onPressed: () {
                final router = GoRouter.of(context);
                Navigator.of(context).pop();
                router.push('/categories');
              },
              icon: const Icon(Icons.add),
              label: Text(
                'Add ${type == 'income' ? 'an income' : 'an expense'} category',
              ),
            )
          else
            LayoutBuilder(
              builder: (context, box) {
                const gap = 8.0;
                final cols = box.maxWidth >= 420 ? 5 : 4;
                final w = (box.maxWidth - gap * (cols - 1)) / cols;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final cat in cats)
                      SizedBox(
                        width: w,
                        child: _CategoryTile(
                          category: cat,
                          selected: selected == cat.id,
                          onTap: () => c.setCategory(cat.id),
                        ),
                      ),
                  ],
                );
              },
            ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                error,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });
  final Category category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = resolveCategoryStyle(category);
    return Semantics(
      button: true,
      selected: selected,
      label: category.name,
      child: InkWell(
        borderRadius: BorderRadius.circular(Tokens.radius),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Tokens.radius),
            color: selected ? style.color.withValues(alpha: 0.10) : null,
            border: Border.all(
              color: selected ? style.color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CategoryAvatar(icon: style.icon, color: style.color),
                  if (selected)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: style.color,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: const Icon(
                          Icons.check,
                          size: 11,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                category.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonSuggestions extends ConsumerWidget {
  const _PersonSuggestions({required this.args});
  final AddArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.read(addFormProvider(args).notifier);
    final payees = (ref.watch(payeesProvider).valueOrNull ?? const <Payee>[])
        .where((p) => !p.isArchived)
        .toList();
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: c.person,
      builder: (context, v, _) {
        final typed = v.text.trim().toLowerCase();
        final list = payees
            .where((p) => typed.isEmpty || p.name.toLowerCase().contains(typed))
            .where((p) => p.name.toLowerCase() != typed)
            .take(6)
            .toList();
        if (list.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final p in list)
                ActionChip(
                  label: Text(p.name),
                  onPressed: () => c.person.text = p.name,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ProofSection extends ConsumerWidget {
  const _ProofSection({required this.args});
  final AddArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(addFormProvider(args));
    final c = ref.read(addFormProvider(args).notifier);
    final hasExisting =
        args.editing?.receiptPath != null &&
        !s.removeProof &&
        s.newProof == null;

    if (s.newProof != null) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.file(
            File(s.newProof!.localFile),
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            cacheWidth: 96,
          ),
        ),
        title: const Text('Proof attached'),
        subtitle: const Text('Uploads when you are online'),
        trailing: IconButton(
          tooltip: 'Remove proof',
          icon: const Icon(Icons.close),
          onPressed: c.clearNewProof,
        ),
      );
    }
    if (hasExisting) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.receipt_long_outlined),
        title: const Text('Proof attached'),
        trailing: IconButton(
          tooltip: 'Remove proof',
          icon: const Icon(Icons.delete_outline),
          onPressed: c.removeExistingProof,
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.photo_camera_outlined),
            label: const Text('Camera'),
            onPressed: () => c.attachProof(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.photo_outlined),
            label: const Text('Gallery'),
            onPressed: () => c.attachProof(ImageSource.gallery),
          ),
        ),
      ],
    );
  }
}

/// Soft ring that expands and fades behind the success check.
class _SuccessRing extends StatelessWidget {
  const _SuccessRing({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Motion.slow + Motion.fast,
      curve: Motion.curve,
      child: child,
      builder: (_, t, child) => Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: (1 - t).clamp(0.0, 1.0) * 0.5,
            child: Container(
              width: 70 + 90 * t,
              height: 70 + 90 * t,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Tokens.statusGood,
                  width: 3 * (1 - t) + 0.5,
                ),
              ),
            ),
          ),
          child!,
        ],
      ),
    );
  }
}
