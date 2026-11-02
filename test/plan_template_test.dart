import 'package:timezone/data/latest.dart' as tzdata;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_expense_tracker/app/providers.dart';
import 'package:personal_expense_tracker/core/domain/entities.dart';
import 'package:personal_expense_tracker/core/domain/money.dart';
import 'package:personal_expense_tracker/features/budgets/application/plan_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_tracker/core/data/db/database.dart';
import 'package:personal_expense_tracker/core/data/ledger_repository.dart';
import 'package:personal_expense_tracker/core/data/sync/outbox_service.dart';
import 'package:personal_expense_tracker/core/domain/local_date.dart';
import 'package:personal_expense_tracker/core/domain/result.dart';

void main() {
  setUpAll(tzdata.initializeTimeZones);
  group('controller', controllerTests);
  group('repository', repositoryTests);
}

void repositoryTests() {
  late AppDatabase db;
  late LedgerRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = LedgerRepository(
      db: db,
      outbox: OutboxService(db),
      userId: () => 'u1',
      onLocalWrite: () {},
    );
  });
  tearDown(() => db.close());

  test(
    'saveTemplate stores limit and allocations, and overwrites (one row)',
    () async {
      expect(await repo.watchTemplate().first, isNull);

      final a = await repo.saveTemplate(
        totalLimit: 100000,
        allocations: {'food': 40000, 'bus': 0},
      );
      expect(a, isA<Ok<void>>());
      var t = (await repo.watchTemplate().first)!;
      expect(t.totalLimit, 100000);
      expect(t.allocations, {'food': 40000}); // zero amounts are dropped

      final idBefore = (await db.select(db.budgetTemplates).get()).single.id;
      await repo.saveTemplate(totalLimit: 50000, allocations: {'rent': 50000});
      final rows = await db.select(db.budgetTemplates).get();
      expect(rows, hasLength(1));
      expect(rows.single.id, idBefore);
      t = (await repo.watchTemplate().first)!;
      expect(t.totalLimit, 50000);
      expect(t.allocations, {'rent': 50000});
    },
  );

  test('saveTemplate rejects negative or over-limit amounts', () async {
    expect(
      await repo.saveTemplate(totalLimit: -1, allocations: {}),
      isA<Err<void>>(),
    );
    expect(
      await repo.saveTemplate(totalLimit: 100, allocations: {'a': -5}),
      isA<Err<void>>(),
    );
    expect(
      await repo.saveTemplate(totalLimit: 100, allocations: {'a': 60, 'b': 50}),
      isA<Err<void>>(),
    );
    expect(await db.select(db.budgetTemplates).get(), isEmpty);
  });

  test('saveTemplate enqueues one upsert for budget_templates', () async {
    await repo.saveTemplate(totalLimit: 1000, allocations: {'a': 500});
    await repo.saveTemplate(totalLimit: 2000, allocations: {'a': 700});
    final ops = await db.select(db.outbox).get();
    final mine = ops.where((o) => o.entity == 'budget_templates').toList();
    expect(mine, hasLength(1)); // second save replaces the pending payload
    expect(mine.single.op, 'upsert');
    expect(mine.single.payload, contains('"total_limit":2000'));
  });

  test('template and day plans are independent', () async {
    final date = LocalDate.parse('2026-11-02');
    await repo.saveTemplate(totalLimit: 1000, allocations: {'a': 500});
    await repo.savePlan(date: date, totalLimit: 3000, allocations: {'a': 1000});

    // Editing the day does not change the template.
    await repo.savePlan(date: date, totalLimit: 4000, allocations: {'a': 2000});
    var t = (await repo.watchTemplate().first)!;
    expect(t.totalLimit, 1000);
    expect(t.allocations, {'a': 500});

    // Saving the template does not change the saved day.
    await repo.saveTemplate(totalLimit: 9000, allocations: {'a': 9000});
    final b = (await repo.watchBudgets().first).single;
    expect(b.totalLimit, 4000);
    expect(b.allocations.single.plannedAmount, 2000);
    t = (await repo.watchTemplate().first)!;
    expect(t.totalLimit, 9000);
  });
}

void controllerTests() {
  late AppDatabase db;
  late LedgerRepository repo;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = LedgerRepository(
      db: db,
      outbox: OutboxService(db),
      userId: () => 'u1',
      onLocalWrite: () {},
    );
    container = ProviderContainer(
      overrides: [ledgerProvider.overrideWithValue(repo)],
    );
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 50));

  test(
    'useTemplate fills the form only; unknown categories ignored; nothing saved',
    () async {
      final food =
          (await repo.saveCategory(name: 'Food', type: 'expense')
                  as Ok<Category>)
              .value;
      final bus =
          (await repo.saveCategory(name: 'Bus', type: 'expense')
                  as Ok<Category>)
              .value;
      await repo.saveTemplate(
        totalLimit: 100000,
        allocations: {food.id: 40000, 'deleted-cat': 10000},
      );

      container.listen(categoriesProvider, (_, _) {});
      container.listen(budgetTemplateProvider, (_, _) {});
      container.listen(planControllerProvider, (_, _) {});
      await settle();
      final c = container.read(planControllerProvider.notifier);
      c.alloc(bus.id).text = '123'; // stale value must be cleared

      expect(c.useTemplate(), isTrue);
      expect(c.limit.text, toDecimalString(100000));
      expect(c.alloc(food.id).text, toDecimalString(40000));
      expect(c.alloc(bus.id).text, '');
      expect(c.totals.value.allocated, 40000);
      expect(await db.select(db.dailyBudgets).get(), isEmpty); // not saved
    },
  );

  test('useTemplate returns false when there is no template', () async {
    container.listen(planControllerProvider, (_, _) {});
    await settle();
    expect(
      container.read(planControllerProvider.notifier).useTemplate(),
      isFalse,
    );
  });

  test('canSavePlan / canSaveTemplate follow the form', () async {
    final food =
        (await repo.saveCategory(name: 'Food', type: 'expense') as Ok<Category>)
            .value;
    container.listen(categoriesProvider, (_, _) {});
    container.listen(planControllerProvider, (_, _) {});
    await settle();
    final c = container.read(planControllerProvider.notifier);

    // Empty form: nothing to save.
    expect(c.canSavePlan, isFalse);
    expect(c.canSaveTemplate, isFalse);

    // Limit only.
    c.limit.text = '1000';
    expect(c.canSavePlan, isTrue);
    expect(c.canSaveTemplate, isTrue);

    // Within the limit.
    c.alloc(food.id).text = '400';
    expect(c.canSaveTemplate, isTrue);

    // Over the limit: template stays disabled.
    c.alloc(food.id).text = '1500';
    expect(c.canSaveTemplate, isFalse);

    // Allocation without a limit: a plan could be attempted, a template not.
    c.limit.text = '';
    c.alloc(food.id).text = '400';
    expect(c.canSavePlan, isTrue);
    expect(c.canSaveTemplate, isFalse);

    // Cleared again.
    c.alloc(food.id).text = '';
    expect(c.canSavePlan, isFalse);
  });
}
