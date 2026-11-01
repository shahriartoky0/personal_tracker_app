import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/providers.dart';
import '../../../core/domain/entities.dart';
import '../../../core/domain/money.dart';
import '../../../core/domain/proof.dart';
import '../../../core/domain/result.dart';
import '../../../core/domain/validation.dart';
import '../../../core/error/app_error.dart';
import '../../transfers/proof_service.dart';

enum AddMode { expense, income, transfer, person }

/// Identity of one open sheet. Equality is by what the sheet was opened for,
/// so the family provider is stable across rebuilds.
class AddArgs {
  const AddArgs({this.editing, this.initialMode, this.presetPerson});
  final Tx? editing;
  final AddMode? initialMode;
  final String? presetPerson;

  @override
  bool operator ==(Object other) =>
      other is AddArgs &&
      other.editing?.id == editing?.id &&
      other.initialMode == initialMode &&
      other.presetPerson == presetPerson;

  @override
  int get hashCode => Object.hash(editing?.id, initialMode, presetPerson);
}

class AddFormState {
  const AddFormState({
    required this.mode,
    this.categoryId,
    this.accountId,
    this.toAccountId,
    this.planned = false,
    this.whenMs,
    this.direction = TransferDirection.outbound,
    this.newProof,
    this.removeProof = false,
    this.errors = const {},
    this.formError,
    this.saving = false,
    this.saved = false,
  });

  final AddMode mode;
  final String? categoryId;
  final String? accountId;
  final String? toAccountId;
  final bool planned;
  final int? whenMs;
  final TransferDirection direction;
  final PreparedProof? newProof;
  final bool removeProof;
  final Map<String, String> errors;
  final String? formError;
  final bool saving;
  final bool saved;

  AddFormState copyWith({
    AddMode? mode,
    Object? categoryId = _keep,
    Object? accountId = _keep,
    Object? toAccountId = _keep,
    bool? planned,
    Object? whenMs = _keep,
    TransferDirection? direction,
    Object? newProof = _keep,
    bool? removeProof,
    Map<String, String>? errors,
    Object? formError = _keep,
    bool? saving,
    bool? saved,
  }) =>
      AddFormState(
        mode: mode ?? this.mode,
        categoryId: identical(categoryId, _keep) ? this.categoryId : categoryId as String?,
        accountId: identical(accountId, _keep) ? this.accountId : accountId as String?,
        toAccountId: identical(toAccountId, _keep) ? this.toAccountId : toAccountId as String?,
        planned: planned ?? this.planned,
        whenMs: identical(whenMs, _keep) ? this.whenMs : whenMs as int?,
        direction: direction ?? this.direction,
        newProof: identical(newProof, _keep) ? this.newProof : newProof as PreparedProof?,
        removeProof: removeProof ?? this.removeProof,
        errors: errors ?? this.errors,
        formError: identical(formError, _keep) ? this.formError : formError as String?,
        saving: saving ?? this.saving,
        saved: saved ?? this.saved,
      );
}

const _keep = Object();

/// Owns the form's state and its text controllers (disposed with the
/// provider), so every widget of the sheet — body and sticky footer — reads
/// the same source of truth and no widget needs setState.
class AddFormController extends AutoDisposeFamilyNotifier<AddFormState, AddArgs> {
  late final TextEditingController amount;
  late final TextEditingController merchant;
  late final TextEditingController note;
  late final TextEditingController person;

  bool get isEditing => arg.editing != null;

  @override
  AddFormState build(AddArgs arg) {
    amount = TextEditingController();
    merchant = TextEditingController();
    note = TextEditingController();
    person = TextEditingController(text: arg.presetPerson ?? '');
    ref.onDispose(() {
      amount.dispose();
      merchant.dispose();
      note.dispose();
      person.dispose();
    });

    final e = arg.editing;
    if (e == null) return AddFormState(mode: arg.initialMode ?? AddMode.expense);

    amount.text = toDecimalString(e.amount);
    note.text = e.note ?? '';
    if (e.type == TxType.personTransfer) {
      final payees = ref.read(payeesProvider).valueOrNull ?? const <Payee>[];
      person.text = payees.where((p) => p.id == e.payeeId).firstOrNull?.name ?? '';
      return AddFormState(
        mode: AddMode.person,
        accountId: e.accountId,
        whenMs: e.occurredAtMs,
        direction: e.direction ?? TransferDirection.outbound,
      );
    }
    merchant.text = e.merchant ?? '';
    return AddFormState(
      mode: e.type == TxType.income ? AddMode.income : AddMode.expense,
      categoryId: e.categoryId,
      accountId: e.accountId,
      planned: e.plannedStatus == 'planned',
      whenMs: e.occurredAtMs,
    );
  }

  void setMode(AddMode m) {
    if (m == state.mode) return;
    // Category belongs to expense/income only; clear when leaving them.
    final keepCategory = (m == AddMode.expense || m == AddMode.income) && m == state.mode;
    state = state.copyWith(mode: m, categoryId: keepCategory ? state.categoryId : null, errors: const {}, formError: null);
  }

  void setCategory(String id) => state = state.copyWith(categoryId: id, errors: _without('categoryId'));
  void setAccount(String? id) => state = state.copyWith(accountId: id, errors: _without('accountId'));
  void setToAccount(String? id) => state = state.copyWith(toAccountId: id, errors: _without('toId'));
  void setPlanned(bool v) => state = state.copyWith(planned: v);
  void setWhen(int ms) => state = state.copyWith(whenMs: ms);
  void setDirection(TransferDirection d) => state = state.copyWith(direction: d);
  void removeExistingProof() => state = state.copyWith(removeProof: true, newProof: null);
  void clearNewProof() => state = state.copyWith(newProof: null);

  Map<String, String> _without(String key) => {...state.errors}..remove(key);

  /// Picks, compresses and stores a proof; failures become a form message.
  Future<void> attachProof(ImageSource source) async {
    final svc = ref.read(proofServiceProvider);
    try {
      final picked = await svc.pick(source);
      if (picked == null) return;
      final prepared = await svc.prepare(ref.read(ledgerProvider).userId(), picked);
      state = state.copyWith(newProof: prepared, removeProof: false, formError: null);
    } on ProofException catch (e) {
      state = state.copyWith(formError: e.message);
    } catch (e, st) {
      state = state.copyWith(formError: toFailure(e, st).message);
    }
  }

  /// Validates and writes locally (one Drift txn + outbox). Returns true on success.
  Future<bool> submit() async {
    if (state.saving) return false;
    final accounts = ref.read(accountsProvider).valueOrNull ?? const <Account>[];
    final accountId = state.accountId ?? (accounts.isNotEmpty ? accounts.first.id : '');
    final amountMinor = parseMoney(amount.text);
    if (amountMinor == null) {
      state = state.copyWith(errors: {'amount': 'Enter a valid amount (up to 2 decimals).'}, formError: null);
      return false;
    }
    state = state.copyWith(saving: true, errors: const {}, formError: null);

    final repo = ref.read(ledgerProvider);
    final when = state.whenMs ?? DateTime.now().millisecondsSinceEpoch;
    final Result<Object?> result = await guard<Object?>(() async {
      switch (state.mode) {
        case AddMode.expense:
        case AddMode.income:
          final input = TxInput(
            type: state.mode == AddMode.expense ? TxType.expense : TxType.income,
            amount: amountMinor,
            accountId: accountId,
            categoryId: state.categoryId,
            occurredAtMs: when,
            merchant: merchant.text,
            note: note.text,
            plannedStatus: state.planned ? 'planned' : 'unplanned',
          );
          final r = arg.editing == null
              ? await repo.createTransaction(input)
              : await repo.updateTransaction(arg.editing!.id, input);
          return r.isOk ? const Ok<Object?>(null) : Err<Object?>(r.failureOrNull!);
        case AddMode.transfer:
          final r = await repo.createTransfer(
            fromId: accountId,
            toId: state.toAccountId ?? '',
            amount: amountMinor,
            occurredAtMs: when,
            note: note.text,
          );
          return r.isOk ? const Ok<Object?>(null) : Err<Object?>(r.failureOrNull!);
        case AddMode.person:
          final input = PersonTransferInput(
            personName: person.text,
            direction: state.direction,
            amount: amountMinor,
            accountId: accountId,
            occurredAtMs: when,
            note: note.text,
          );
          final r = arg.editing == null
              ? await repo.recordPersonTransfer(input, proof: state.newProof)
              : await repo.updatePersonTransfer(arg.editing!.id, input,
                  newProof: state.newProof, removeProof: state.removeProof);
          return r.isOk ? const Ok<Object?>(null) : Err<Object?>(r.failureOrNull!);
      }
    });

    final f = result.failureOrNull;
    if (f != null) {
      state = state.copyWith(
        saving: false,
        errors: f.fields,
        formError: f.fields.isEmpty ? f.message : null,
      );
      return false;
    }
    state = state.copyWith(saving: false, saved: true);
    return true;
  }
}

final addFormProvider = NotifierProvider.autoDispose.family<AddFormController, AddFormState, AddArgs>(
  AddFormController.new,
);
