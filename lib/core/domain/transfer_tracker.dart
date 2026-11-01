import 'calculators.dart';
import 'entities.dart';
import 'local_date.dart';

class PersonTotals {
  const PersonTotals({
    required this.payeeId,
    required this.sent,
    required this.received,
    required this.count,
    required this.withProof,
  });
  final String payeeId;
  final int sent;
  final int received;
  final int count;
  final int withProof;
  int get netSent => sent - received;
}

class TransferTracker {
  const TransferTracker({
    required this.sent,
    required this.received,
    required this.count,
    required this.withProof,
    required this.periodByPerson,
    required this.allTimeByPerson,
    required this.history,
  });
  final int sent;
  final int received;
  final int count;
  final int withProof;
  final List<PersonTotals> periodByPerson;
  final List<PersonTotals> allTimeByPerson;
  final List<Tx> history; // newest first, period + person filter applied
  int get netSent => sent - received;
}

class TransferTrackerBuilder {
  static List<PersonTotals> _totals(Iterable<Tx> txs) {
    final m = <String, List<Tx>>{};
    for (final t in txs) {
      if (t.type != TxType.personTransfer || t.payeeId == null) continue;
      m.putIfAbsent(t.payeeId!, () => []).add(t);
    }
    final list = m.entries
        .map((e) => PersonTotals(
              payeeId: e.key,
              sent: TransactionCalculator.totalSentToPeople(e.value),
              received: TransactionCalculator.totalReceivedFromPeople(e.value),
              count: e.value.length,
              withProof: e.value.where((t) => t.receiptPath != null).length,
            ))
        .toList()
      ..sort((a, b) => (b.sent + b.received).compareTo(a.sent + a.received));
    return list;
  }

  /// [range] null = all time. [personId] null = everyone.
  static TransferTracker build({
    required List<Tx> allTxs,
    required String tz,
    DateRange? range,
    String? personId,
  }) {
    final people = allTxs.where((t) => t.type == TxType.personTransfer);
    InstantRange? ir = range == null ? null : instantRange(range.from, range.to, tz);
    final inPeriod =
        people.where((t) => ir == null || ir.contains(t.occurredAtMs)).toList();
    final filtered = inPeriod.where((t) => personId == null || t.payeeId == personId).toList()
      ..sort((a, b) => b.occurredAtMs.compareTo(a.occurredAtMs));
    return TransferTracker(
      sent: TransactionCalculator.totalSentToPeople(filtered),
      received: TransactionCalculator.totalReceivedFromPeople(filtered),
      count: filtered.length,
      withProof: filtered.where((t) => t.receiptPath != null).length,
      periodByPerson: _totals(inPeriod),
      allTimeByPerson: _totals(people),
      history: filtered,
    );
  }
}
