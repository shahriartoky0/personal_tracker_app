import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/data/db/database.dart';
import '../core/data/ledger_repository.dart';
import '../core/data/remote/remote_gateway.dart';
import '../core/data/sync/outbox_service.dart';
import '../core/data/sync/sync_engine.dart';
import '../core/data/sync/sync_status.dart';
import '../core/domain/entities.dart';
import '../features/transfers/proof_service.dart';
import '../core/domain/local_date.dart';

/// Overridden in main() with the opened (encrypted) database.
final dbProvider = Provider<AppDatabase>((ref) => throw UnimplementedError('dbProvider not overridden'));

/// Last-known user id; keeps the app usable offline after token expiry.
final cachedUserIdProvider = StateProvider<String?>((ref) => null);

final supabaseProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

String currentUserId(Ref ref) {
  final live = Supabase.instance.client.auth.currentUser?.id;
  return live ?? ref.read(cachedUserIdProvider) ?? '';
}

final outboxProvider = Provider<OutboxService>((ref) => OutboxService(ref.watch(dbProvider)));

final packageInfoProvider = FutureProvider<PackageInfo>((ref) => PackageInfo.fromPlatform());

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final engine = SyncEngine(
    db: ref.watch(dbProvider),
    remote: SupabaseGateway(ref.watch(supabaseProvider)),
    outbox: ref.watch(outboxProvider),
    clientVersion: ref.watch(packageInfoProvider).valueOrNull?.version ?? '0.0.0',
  );
  ref.onDispose(engine.dispose);
  return engine;
});

final ledgerProvider = Provider<LedgerRepository>((ref) {
  final engine = ref.read(syncEngineProvider);
  return LedgerRepository(
    db: ref.watch(dbProvider),
    outbox: ref.watch(outboxProvider),
    userId: () => currentUserId(ref),
    onLocalWrite: () => engine.kick(),
  );
});

final syncStatusProvider = StreamProvider<SyncStatus>((ref) => ref.watch(syncEngineProvider).status);

// ── Drift-backed streams: the UI's only data source ───────────────────────
final accountsProvider = StreamProvider<List<Account>>((ref) => ref.watch(ledgerProvider).watchAccounts());
final allAccountsProvider =
    StreamProvider<List<Account>>((ref) => ref.watch(ledgerProvider).watchAccounts(includeArchived: true));
final categoriesProvider =
    StreamProvider<List<Category>>((ref) => ref.watch(ledgerProvider).watchCategories());
final allCategoriesProvider =
    StreamProvider<List<Category>>((ref) => ref.watch(ledgerProvider).watchCategories(includeArchived: true));
final transactionsProvider = StreamProvider<List<Tx>>((ref) => ref.watch(ledgerProvider).watchTransactions());
final budgetsProvider = StreamProvider<List<DailyBudget>>((ref) => ref.watch(ledgerProvider).watchBudgets());
/// Account balances = opening balance + SQL-computed net movement.
final accountNetProvider = StreamProvider<Map<String, int>>((ref) => ref.watch(ledgerProvider).watchAccountNet());

final totalBalanceProvider = Provider<int>((ref) {
  final accounts = ref.watch(accountsProvider).valueOrNull ?? const <Account>[];
  final net = ref.watch(accountNetProvider).valueOrNull ?? const <String, int>{};
  return accounts.fold<int>(0, (s, a) => s + a.openingBalance + (net[a.id] ?? 0));
});

/// Dashboard window: this month and the last 7 days, whichever reaches further back.
final dashboardTxProvider = StreamProvider.autoDispose<List<Tx>>((ref) {
  final tz = ref.watch(timezoneProvider);
  final today = todayIn(tz);
  final from = today.startOfMonth.isBefore(today.addDays(-6)) ? today.startOfMonth : today.addDays(-6);
  return ref.watch(ledgerProvider).watchTransactionsSince(startOfDayInstant(from, tz));
});

final recentTxProvider = StreamProvider.autoDispose<List<Tx>>((ref) => ref.watch(ledgerProvider).watchRecent(5));

/// How many transactions the list loads when no filter is active.
class TxLimitNotifier extends Notifier<int> {
  static const page = 300;
  @override
  int build() => page;
  void more() => state += page;
}

final txLimitProvider = NotifierProvider<TxLimitNotifier, int>(TxLimitNotifier.new);

final profileProvider = StreamProvider<Profile?>((ref) => ref.watch(ledgerProvider).watchProfile());

/// Profile timezone with a safe default so screens never wait on the network.
final timezoneProvider = Provider<String>((ref) => ref.watch(profileProvider).valueOrNull?.timezone ?? 'Asia/Dhaka');

final plannedExpensesProvider = StreamProvider.family<List<PlannedExpense>, String>(
    (ref, date) => ref.watch(ledgerProvider).watchPlannedExpenses(date));

final payeesProvider = StreamProvider<List<Payee>>((ref) => ref.watch(ledgerProvider).watchPayees());

final proofServiceProvider = Provider<ProofService>((ref) => ProofService());

