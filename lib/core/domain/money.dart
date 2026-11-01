/// Money is always an `int` of minor units (poisha). Never use double.
library;

const int maxMinor = 1000000000000; // 1e12
const String currencySymbolBdt = '৳';

/// Parses a user-entered decimal string into minor units using the digit
/// string only (no floating point). Returns null if invalid.
/// Max 13 integer digits and 2 decimals.
int? parseMoney(String input) {
  final s = input.trim().replaceAll(',', '');
  final m = RegExp(r'^(\d{1,13})(?:\.(\d{1,2}))?$').firstMatch(s);
  if (m == null) return null;
  final whole = int.parse(m.group(1)!);
  final frac = (m.group(2) ?? '').padRight(2, '0');
  final minor = whole * 100 + int.parse(frac.isEmpty ? '0' : frac);
  if (minor > maxMinor) return null;
  return minor;
}

String _group(String digits) {
  final b = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) b.write(',');
    b.write(digits[i]);
  }
  return b.toString();
}

/// `1250` minor-less display: ৳1,250 or ৳1,250.50. True minus sign (−).
String formatMoney(int minor, {String symbol = currencySymbolBdt, bool showSign = false}) {
  final neg = minor < 0;
  final abs = minor.abs();
  final whole = abs ~/ 100;
  final frac = abs % 100;
  final body = frac == 0
      ? _group(whole.toString())
      : '${_group(whole.toString())}.${frac.toString().padLeft(2, '0')}';
  final sign = neg ? '−' : (showSign && minor > 0 ? '+' : '');
  return '$sign$symbol$body';
}

/// Plain decimal string with 2 decimals, e.g. 125050 -> "1250.50".
String toDecimalString(int minor) {
  final neg = minor < 0;
  final abs = minor.abs();
  return '${neg ? '-' : ''}${abs ~/ 100}.${(abs % 100).toString().padLeft(2, '0')}';
}

/// Integer-rounded percentage of [part] in [total] (0 when total is 0).
int percentOf(int part, int total) {
  if (total == 0) return 0;
  return ((part * 100) / total).round();
}

/// Integer-rounded percent change from [previous] to [current].
/// Returns null when previous is 0.
int? percentChange(int current, int previous) {
  if (previous == 0) return null;
  return (((current - previous) * 100) / previous.abs()).round();
}

/// Compact axis label: ৳950, ৳1.2k, ৳3.4L (lakh), ৳1.1Cr (crore) — no decimals noise.
String formatCompact(int minor, {String symbol = currencySymbolBdt}) {
  final neg = minor < 0;
  final v = minor.abs() / 100;
  String n(double x) => x == x.roundToDouble() ? x.toStringAsFixed(0) : x.toStringAsFixed(1);
  String body;
  if (v >= 10000000) {
    body = '${n(v / 10000000)}Cr';
  } else if (v >= 100000) {
    body = '${n(v / 100000)}L';
  } else if (v >= 1000) {
    body = '${n(v / 1000)}k';
  } else {
    body = v.toStringAsFixed(0);
  }
  return '${neg ? '−' : ''}$symbol$body';
}
