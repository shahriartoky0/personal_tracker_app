import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/domain/calculators.dart';
import '../../../core/domain/entities.dart';
import '../../../core/domain/local_date.dart';
import '../../../core/domain/money.dart';
import '../../../core/error/app_error.dart';

class PlanState {
  const PlanState({this.date, this.error, this.saving = false});
  final LocalDate? date; // null = today in the profile timezone
  final String? error;
  final bool saving;

  PlanState copyWith({
    Object? date = _keep,
    Object? error = _keep,
    bool? saving,
  }) => PlanState(
    date: identical(date, _keep) ? this.date : date as LocalDate?,
    error: identical(error, _keep) ? this.error : error as String?,
    saving: saving ?? this.saving,
  );
}

const _keep = Object();

/// The daily plan editor. Seeds the text fields from the database when the
/// day or the stored plan changes, validates, saves, and publishes live
/// "allocated / not allocated" totals — all outside the widget tree.
class PlanController extends AutoDisposeNotifier<PlanState> {
  final limit = TextEditingController();
  final _alloc = <String, TextEditingController>{};
  final totals = ValueNotifier<({int limit, int allocated})>((
    limit: 0,
    allocated: 0,
  ));
  String? _seedKey;

  TextEditingController alloc(String categoryId) =>
      _alloc.putIfAbsent(categoryId, () {
        final c = TextEditingController()..addListener(_recompute);
        return c;
      });

  List<Category> get _expenseCats =>
      (ref.read(categoriesProvider).valueOrNull ?? const <Category>[])
          .where((c) => c.type == 'expense')
          .toList();

  LocalDate get currentDate =>
      state.date ?? todayIn(ref.read(timezoneProvider));

  @override
  PlanState build() {
    limit.addListener(_recompute);
    ref.onDispose(() {
      limit.dispose();
      for (final c in _alloc.values) {
        c.dispose();
      }
      totals.dispose();
    });
    // Re-seed whenever the stored plan or the category list changes.
    ref.listen(budgetsProvider, (_, _) => _reseed());
    ref.listen(categoriesProvider, (_, _) => _reseed());
    Future.microtask(_reseed);
    return const PlanState();
  }

  /// Save plan needs something to save: a limit or at least one amount.
  bool get canSavePlan =>
      !state.saving && (totals.value.limit > 0 || totals.value.allocated > 0);

  /// A template needs a positive limit and allocations within it.
  bool get canSaveTemplate =>
      !state.saving &&
      totals.value.limit > 0 &&
      totals.value.allocated <= totals.value.limit;

  void _recompute() {
    final l = parseMoney(limit.text.isEmpty ? '0' : limit.text) ?? 0;
    var a = 0;
    for (final cat in _expenseCats) {
      final t = _alloc[cat.id]?.text ?? '';
      a += parseMoney(t.isEmpty ? '0' : t) ?? 0;
    }
    totals.value = (limit: l, allocated: a);
  }

  void _reseed() {
    final date = currentDate;
    final budgets =
        ref.read(budgetsProvider).valueOrNull ?? const <DailyBudget>[];
    final b = budgets.where((x) => x.date == date.value).firstOrNull;
    final cats = _expenseCats;
    final key =
        '${date.value}|${b?.id}|${b?.totalLimit}|${b?.allocations.length}|${cats.length}';
    if (key == _seedKey) return;
    _seedKey = key;
    limit.text = b == null ? '' : toDecimalString(b.totalLimit);
    for (final c in cats) {
      final a = b?.allocations.where((x) => x.categoryId == c.id).firstOrNull;
      alloc(c.id).text = a == null ? '' : toDecimalString(a.plannedAmount);
    }
    _recompute();
  }

  void shiftDay(int days) {
    state = state.copyWith(date: currentDate.addDays(days), error: null);
    _seedKey = null;
    _reseed();
  }

  /// Parses and validates the form. On a problem, publishes the message and
  /// returns null.
  ({int limit, Map<String, int> allocs})? _readForm() {
    final l = parseMoney(limit.text.isEmpty ? '0' : limit.text);
    if (l == null) {
      state = state.copyWith(error: 'Enter a valid daily limit.');
      return null;
    }
    final allocs = <String, int>{};
    for (final c in _expenseCats) {
      final t = alloc(c.id).text.trim();
      if (t.isEmpty) continue;
      final v = parseMoney(t);
      if (v == null) {
        state = state.copyWith(error: 'Check the amount for ${c.name}.');
        return null;
      }
      allocs[c.id] = v;
    }
    final msg = BudgetCalculator.validateAllocations(l, allocs.values);
    if (msg != null) {
      state = state.copyWith(error: msg);
      return null;
    }
    return (limit: l, allocs: allocs);
  }

  /// Validates and saves. Returns true when saved.
  Future<bool> save() async {
    if (state.saving) return false;
    final form = _readForm();
    if (form == null) return false;
    state = state.copyWith(saving: true, error: null);
    final r = await guard(
      () => ref
          .read(ledgerProvider)
          .savePlan(
            date: currentDate,
            totalLimit: form.limit,
            allocations: form.allocs,
          ),
    );
    state = state.copyWith(saving: false, error: r.failureOrNull?.message);
    if (r.isOk) _seedKey = null;
    return r.isOk;
  }

  /// Saves the form as the user's single template (overwrites it). Does not
  /// touch the day's saved plan.
  Future<bool> saveAsTemplate() async {
    if (state.saving) return false;
    final form = _readForm();
    if (form == null) return false;
    state = state.copyWith(saving: true, error: null);
    final r = await guard(
      () => ref
          .read(ledgerProvider)
          .saveTemplate(totalLimit: form.limit, allocations: form.allocs),
    );
    state = state.copyWith(saving: false, error: r.failureOrNull?.message);
    return r.isOk;
  }

  /// Fills the form from the template. Does not save: the user still presses
  /// Save plan. Categories that no longer exist are ignored. Returns false
  /// when there is no template.
  bool useTemplate() {
    final t = ref.read(budgetTemplateProvider).valueOrNull;
    if (t == null) return false;
    limit.text = toDecimalString(t.totalLimit);
    for (final c in _expenseCats) {
      final a = t.allocations[c.id];
      alloc(c.id).text = a == null || a == 0 ? '' : toDecimalString(a);
    }
    state = state.copyWith(error: null);
    _recompute();
    return true;
  }

  Future<String?> copyYesterday() async {
    final r = await guard(
      () => ref.read(ledgerProvider).copyPreviousPlan(currentDate),
    );
    _seedKey = null;
    return r.failureOrNull?.message;
  }

  Future<void> setClosed(String budgetId, bool closed) =>
      ref.read(ledgerProvider).setDayClosed(budgetId, closed);
}

final planControllerProvider =
    NotifierProvider.autoDispose<PlanController, PlanState>(PlanController.new);
