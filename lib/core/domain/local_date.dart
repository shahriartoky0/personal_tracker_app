import 'package:timezone/timezone.dart' as tz;

/// A timezone-free calendar date, `YYYY-MM-DD`.
class LocalDate implements Comparable<LocalDate> {
  const LocalDate._(this.value);
  final String value;

  factory LocalDate(int y, int m, int d) {
    // Normalise via DateTime.utc (handles overflow, leap years).
    final dt = DateTime.utc(y, m, d);
    return LocalDate._(_fmt(dt));
  }

  factory LocalDate.parse(String s) {
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(s);
    if (m == null) throw FormatException('Invalid date: $s');
    return LocalDate(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
  }

  static String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DateTime get _utc {
    final p = value.split('-').map(int.parse).toList();
    return DateTime.utc(p[0], p[1], p[2]);
  }

  int get year => _utc.year;
  int get month => _utc.month;
  int get day => _utc.day;

  /// 1 = Monday … 7 = Sunday
  int get weekday => _utc.weekday;

  LocalDate addDays(int n) => LocalDate._(_fmt(_utc.add(Duration(days: n))));

  LocalDate addMonths(int n) {
    final total = year * 12 + (month - 1) + n;
    final y = total ~/ 12;
    final m = total % 12 + 1;
    final last = endOfMonthOf(y, m);
    return LocalDate(y, m, day > last ? last : day);
  }

  LocalDate get startOfMonth => LocalDate(year, month, 1);
  LocalDate get endOfMonth => LocalDate(year, month, endOfMonthOf(year, month));

  /// Monday-start week.
  LocalDate get startOfWeek => addDays(-(weekday - 1));

  static int endOfMonthOf(int y, int m) => DateTime.utc(y, m + 1, 0).day;

  int daysUntil(LocalDate other) => other._utc.difference(_utc).inDays;

  bool isBefore(LocalDate o) => compareTo(o) < 0;
  bool isAfter(LocalDate o) => compareTo(o) > 0;

  @override
  int compareTo(LocalDate other) => value.compareTo(other.value);

  @override
  bool operator ==(Object other) => other is LocalDate && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Half-open instant range [start, end) in UTC epoch milliseconds.
class InstantRange {
  const InstantRange(this.startMs, this.endMs);
  final int startMs;
  final int endMs;
  bool contains(int ms) => ms >= startMs && ms < endMs;
}

/// Inclusive date range.
class DateRange {
  const DateRange(this.from, this.to);
  final LocalDate from;
  final LocalDate to;
  int get days => from.daysUntil(to) + 1;
}

tz.Location locationOf(String zone) {
  try {
    return tz.getLocation(zone);
  } catch (_) {
    return tz.getLocation('Asia/Dhaka');
  }
}

/// Which calendar day an instant falls on in [zone].
LocalDate localDateOf(int instantMs, String zone) {
  final t = tz.TZDateTime.fromMillisecondsSinceEpoch(locationOf(zone), instantMs);
  return LocalDate(t.year, t.month, t.day);
}

/// UTC epoch ms of local midnight at the start of [date] in [zone] (DST-safe).
int startOfDayInstant(LocalDate date, String zone) {
  final loc = locationOf(zone);
  return tz.TZDateTime(loc, date.year, date.month, date.day).millisecondsSinceEpoch;
}

/// Half-open instant range covering inclusive dates [from, to].
InstantRange instantRange(LocalDate from, LocalDate to, String zone) =>
    InstantRange(startOfDayInstant(from, zone), startOfDayInstant(to.addDays(1), zone));

/// A wall-clock time in [zone] -> UTC instant (for date-time pickers).
int zonedLocalToInstant(
    int y, int mo, int d, int h, int mi, String zone) {
  return tz.TZDateTime(locationOf(zone), y, mo, d, h, mi).millisecondsSinceEpoch;
}

/// UTC instant -> wall-clock components in [zone].
({int year, int month, int day, int hour, int minute}) instantToZonedLocal(int ms, String zone) {
  final t = tz.TZDateTime.fromMillisecondsSinceEpoch(locationOf(zone), ms);
  return (year: t.year, month: t.month, day: t.day, hour: t.hour, minute: t.minute);
}

LocalDate todayIn(String zone, [int? nowMs]) =>
    localDateOf(nowMs ?? DateTime.now().millisecondsSinceEpoch, zone);

enum RangePreset { today, yesterday, thisWeek, lastWeek, thisMonth, lastMonth, last7, last30, thisYear }

DateRange rangeForPreset(RangePreset p, LocalDate today) {
  switch (p) {
    case RangePreset.today:
      return DateRange(today, today);
    case RangePreset.yesterday:
      final y = today.addDays(-1);
      return DateRange(y, y);
    case RangePreset.thisWeek:
      return DateRange(today.startOfWeek, today.startOfWeek.addDays(6));
    case RangePreset.lastWeek:
      final s = today.startOfWeek.addDays(-7);
      return DateRange(s, s.addDays(6));
    case RangePreset.thisMonth:
      return DateRange(today.startOfMonth, today.endOfMonth);
    case RangePreset.lastMonth:
      final lm = today.startOfMonth.addMonths(-1);
      return DateRange(lm, lm.endOfMonth);
    case RangePreset.last7:
      return DateRange(today.addDays(-6), today);
    case RangePreset.last30:
      return DateRange(today.addDays(-29), today);
    case RangePreset.thisYear:
      return DateRange(LocalDate(today.year, 1, 1), LocalDate(today.year, 12, 31));
  }
}

/// The equally-long range immediately before [r].
DateRange previousRange(DateRange r) {
  final n = r.days;
  return DateRange(r.from.addDays(-n), r.from.addDays(-1));
}
