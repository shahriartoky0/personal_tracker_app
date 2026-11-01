import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/domain/entities.dart';
import '../../../core/domain/local_date.dart';
import '../../../core/domain/reports.dart';

class ReportRange {
  const ReportRange({this.preset = RangePreset.thisMonth, this.custom});
  final RangePreset preset;
  final DateRange? custom;
}

class ReportRangeNotifier extends Notifier<ReportRange> {
  @override
  ReportRange build() => const ReportRange();

  void setPreset(RangePreset p) => state = ReportRange(preset: p);
  void setCustom(DateRange r) => state = ReportRange(preset: state.preset, custom: r);
}

final reportRangeProvider = NotifierProvider<ReportRangeNotifier, ReportRange>(ReportRangeNotifier.new);

class ReportView {
  const ReportView({required this.range, required this.report, required this.categoryNames, required this.accountNames});
  final DateRange range;
  final PeriodReport report;
  final Map<String, String> categoryNames;
  final Map<String, String> accountNames;
}

/// The period report, memoised: rebuilt only when the range or the underlying
/// data change, and disposed when the Reports tab is left.
final reportProvider = Provider.autoDispose<AsyncValue<ReportView>>((ref) {
  final tz = ref.watch(timezoneProvider);
  final sel = ref.watch(reportRangeProvider);
  final txAsync = ref.watch(transactionsProvider);
  final accounts = ref.watch(allAccountsProvider).valueOrNull ?? const <Account>[];
  final cats = ref.watch(allCategoriesProvider).valueOrNull ?? const <Category>[];
  final budgets = ref.watch(budgetsProvider).valueOrNull ?? const <DailyBudget>[];

  return txAsync.whenData((txs) {
    final range = sel.custom ?? rangeForPreset(sel.preset, todayIn(tz));
    return ReportView(
      range: range,
      report: PeriodReportBuilder.build(range: range, tz: tz, accounts: accounts, allTxs: txs, budgets: budgets),
      categoryNames: {for (final c in cats) c.id: c.name},
      accountNames: {for (final a in accounts) a.id: a.name},
    );
  });
});
