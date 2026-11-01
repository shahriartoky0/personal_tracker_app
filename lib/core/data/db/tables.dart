import 'package:drift/drift.dart';

mixin SyncColumns on Table {
  TextColumn get id => text()();
  TextColumn get remoteUpdatedAt => text().nullable()();
  BoolColumn get pending => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AccountRow')
class Accounts extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get type => text()();
  IntColumn get openingBalance => integer().withDefault(const Constant(0))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

@DataClassName('CategoryRow')
class Categories extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get type => text()(); // income|expense
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

@DataClassName('PayeeRow')
class Payees extends Table with SyncColumns {
  TextColumn get name => text()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

@DataClassName('DailyBudgetRow')
@TableIndex(name: 'daily_budgets_date_idx', columns: {#budgetDate}, unique: true)
class DailyBudgets extends Table with SyncColumns {
  TextColumn get budgetDate => text()();
  IntColumn get totalLimit => integer()();
  IntColumn get originalLimit => integer()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isClosed => boolean().withDefault(const Constant(false))();
  TextColumn get closedAt => text().nullable()();
}

@DataClassName('BudgetAllocationRow')
class BudgetAllocations extends Table with SyncColumns {
  TextColumn get dailyBudgetId => text()();
  TextColumn get categoryId => text()();
  IntColumn get plannedAmount => integer()();
  IntColumn get originalAmount => integer()();
}

@DataClassName('BudgetTemplateRow')
class BudgetTemplates extends Table with SyncColumns {
  IntColumn get totalLimit => integer()();
  TextColumn get allocationsJson => text().withDefault(const Constant('[]'))();
}

@DataClassName('PlannedExpenseRow')
class PlannedExpenses extends Table with SyncColumns {
  TextColumn get plannedDate => text()();
  TextColumn get categoryId => text()();
  TextColumn get title => text()();
  IntColumn get expectedAmount => integer()();
  TextColumn get status => text().withDefault(const Constant('planned'))();
}

@DataClassName('TransactionRow')
@TableIndex(name: 'tx_occurred_idx', columns: {#occurredAtMs})
@TableIndex(name: 'tx_account_idx', columns: {#accountId})
@TableIndex(name: 'tx_category_idx', columns: {#categoryId})
@TableIndex(name: 'tx_payee_idx', columns: {#payeeId})
@TableIndex(name: 'tx_type_idx', columns: {#type})
class Transactions extends Table with SyncColumns {
  TextColumn get accountId => text()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get payeeId => text().nullable()();
  TextColumn get type => text()();
  TextColumn get transferDirection => text().nullable()();
  TextColumn get transferGroupId => text().nullable()();
  IntColumn get amount => integer()();
  IntColumn get occurredAtMs => integer()();
  TextColumn get merchant => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get plannedStatus => text().withDefault(const Constant('unplanned'))();
  TextColumn get receiptPath => text().nullable()();
  TextColumn get receiptLocalFile => text().nullable()();
}

@DataClassName('ReminderPrefRow')
class ReminderPreferences extends Table with SyncColumns {
  TextColumn get reminderType => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  TextColumn get reminderTime => text().nullable()(); // HH:mm
  IntColumn get thresholdPercent => integer().nullable()();
}

/// Single-row profile (id = auth uid).
@DataClassName('ProfileRow')
class Profiles extends Table with SyncColumns {
  TextColumn get displayName => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('BDT'))();
  TextColumn get timezone => text().withDefault(const Constant('Asia/Dhaka'))();
  TextColumn get preferencesJson => text().withDefault(const Constant('{}'))();
}

@DataClassName('OutboxRow')
@TableIndex(name: 'outbox_status_idx', columns: {#status, #nextAttemptAtMs, #seq})
class Outbox extends Table {
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get op => text()(); // upsert | delete | upload_proof | delete_proof
  TextColumn get payload => text()();
  TextColumn get baseUpdatedAt => text().nullable()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get nextAttemptAtMs => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get lastError => text().nullable()();
  IntColumn get createdAtMs => integer()();
}

@DataClassName('SyncCursorRow')
class SyncCursors extends Table {
  TextColumn get entity => text()();
  TextColumn get updatedAt => text().nullable()();
  TextColumn get lastId => text().nullable()();
  IntColumn get lastSuccessMs => integer().nullable()();
  @override
  Set<Column> get primaryKey => {entity};
}

@DataClassName('ConflictLogRow')
class ConflictLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get serverVersionJson => text()();
  TextColumn get resolution => text()();
  IntColumn get atMs => integer()();
}

/// Small key/value store for local-only state (e.g. last tombstone cursor).
@DataClassName('KvRow')
class LocalKv extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}
