/// Returns an error message, or null when valid (Flutter's FormField contract).
typedef FieldValidator = String? Function(String? value);

class Validate {
  Validate._();

  static FieldValidator required([String message = 'This field is required']) =>
      (v) => (v == null || v.trim().isEmpty) ? message : null;

  static FieldValidator email([String message = 'Enter a valid email address']) => (v) {
        final t = v?.trim() ?? '';
        if (t.isEmpty) return null; // pair with required()
        return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$').hasMatch(t) ? null : message;
      };

  static FieldValidator minLength(int n, [String? message]) => (v) {
        final t = v ?? '';
        if (t.isEmpty) return null;
        return t.length >= n ? null : (message ?? 'Use at least $n characters');
      };

  static FieldValidator maxLength(int n, [String? message]) =>
      (v) => (v ?? '').length <= n ? null : (message ?? 'Use at most $n characters');

  /// Runs validators in order; the first message wins.
  static FieldValidator combine(List<FieldValidator> validators) => (v) {
        for (final f in validators) {
          final m = f(v);
          if (m != null) return m;
        }
        return null;
      };

  static final FieldValidator emailRequired = combine([required('Enter your email'), email()]);
  static final FieldValidator passwordRequired =
      combine([required('Enter your password'), minLength(6, 'Password must be at least 6 characters')]);
}
