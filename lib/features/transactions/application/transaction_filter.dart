import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/domain/calculators.dart';
import '../../../core/domain/entities.dart';
import '../../../core/domain/local_date.dart';

class TxFilter {
  const TxFilter({this.query = '', this.categoryId, this.accountId, this.planned, this.range});
  final String query;
  final String? categoryId;
  final String? accountId;
  final String? planned; // null = all | 'planned' | 'unplanned'
  final DateRange? range;

  bool get isActive => query.isNotEmpty || categoryId != null || accountId != null || planned != null || range != null;

  TxFilter copyWith({
    String? query,
    Object? categoryId = _keep,
    Object? accountId = _keep,
    Object? planned = _keep,
    Object? range = _keep,
  }) =>
      TxFilter(
        query: query ?? this.query,
        categoryId: identical(categoryId, _keep) ? this.categoryId : categoryId as String?,
        accountId: identical(accountId, _keep) ? this.accountId : accountId as String?,
        planned: identical(planned, _keep) ? this.planned : planned as String?,
        range: identical(range, _keep) ? this.range : range as DateRange?,
      );
}

const _keep = Object();

class TxFilterNotifier extends Notifier<TxFilter> {
  @override
  TxFilter build() => const TxFilter();

  void setQuery(String q) => state = state.copyWith(query: q);
  void setCategory(String? id) => state = state.copyWith(categoryId: id);
  void setAccount(String? id) => state = state.copyWith(accountId: id);
  void setPlanned(String? v) => state = state.copyWith(planned: v);
  void setRange(DateRange? r) => state = state.copyWith(range: r);
  void clear() => state = const TxFilter();
}

final txFilterProvider = NotifierProvider<TxFilterNotifier, TxFilter>(TxFilterNotifier.new);

class DayGroup {
  const DayGroup(this.day, this.items, this.spent);
  final LocalDate day;
  final List<Tx> items;
  final int spent;
}

/// What the list loads: a newest-first page normally, everything while a
/// filter is active (so a search can reach old rows).
final visibleTransactionsProvider = StreamProvider.autoDispose<List<Tx>>((ref) {
  final active = ref.watch(txFilterProvider.select((f) => f.isActive));
  final limit = ref.watch(txLimitProvider);
  return ref.watch(ledgerProvider).watchTransactionsLimited(active ? null : limit);
});

/// True when an unfiltered page came back full — there are probably older rows.
final txHasMoreProvider = Provider.autoDispose<bool>((ref) {
  final active = ref.watch(txFilterProvider.select((f) => f.isActive));
  final limit = ref.watch(txLimitProvider);
  final n = ref.watch(visibleTransactionsProvider.select((a) => a.valueOrNull?.length ?? 0));
  return !active && n >= limit;
});

/// Filtered transactions grouped by local day, newest first. Memoised: it
/// only recomputes when transactions, categories, the filter or the timezone
/// change — not on unrelated rebuilds.
final groupedTransactionsProvider = Provider.autoDispose<AsyncValue<List<DayGroup>>>((ref) {
  final txAsync = ref.watch(visibleTransactionsProvider);
  final filter = ref.watch(txFilterProvider);
  final tz = ref.watch(timezoneProvider);
  final catNames = ref.watch(allCategoriesProvider.select((a) => {for (final c in a.valueOrNull ?? const <Category>[]) c.id: c.name}));

  return txAsync.whenData((txs) {
    final ir = filter.range == null ? null : instantRange(filter.range!.from, filter.range!.to, tz);
    final q = filter.query.trim().toLowerCase();
    final groups = <LocalDate, List<Tx>>{};
    for (final t in txs) {
      if (filter.categoryId != null && t.categoryId != filter.categoryId) continue;
      if (filter.accountId != null && t.accountId != filter.accountId) continue;
      if (filter.planned == 'planned' && t.plannedStatus != 'planned') continue;
      if (filter.planned == 'unplanned' && (t.plannedStatus != 'unplanned' || t.type != TxType.expense)) continue;
      if (ir != null && !ir.contains(t.occurredAtMs)) continue;
      if (q.isNotEmpty) {
        final hay = '${t.merchant ?? ''} ${t.note ?? ''} ${catNames[t.categoryId] ?? ''}'.toLowerCase();
        if (!hay.contains(q)) continue;
      }
      groups.putIfAbsent(localDateOf(t.occurredAtMs, tz), () => []).add(t);
    }
    final days = groups.keys.toList()..sort((a, b) => b.compareTo(a));
    return [for (final d in days) DayGroup(d, groups[d]!, TransactionCalculator.totalExpenses(groups[d]!))];
  });
});
