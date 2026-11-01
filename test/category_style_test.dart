import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_tracker/core/domain/entities.dart';
import 'package:personal_expense_tracker/core/ui/category_style.dart';

void main() {
  test('falls back to a name-derived icon', () {
    const c = Category(id: 'a', name: 'Food', type: 'expense');
    expect(resolveCategoryStyle(c).iconKey, 'restaurant');
    expect(defaultIconKeyForName('Zzz'), 'other');
  });

  test('stored icon and colour win', () {
    const c = Category(id: 'a', name: 'Food', type: 'expense', icon: 'travel', color: '#0091FF');
    final s = resolveCategoryStyle(c);
    expect(s.iconKey, 'travel');
    expect(s.color, const Color(0xFF0091FF));
  });

  test('unknown icon key falls back; colour is deterministic', () {
    const c = Category(id: 'x1', name: 'Bills', type: 'expense', icon: 'nope', color: 'bad');
    final a = resolveCategoryStyle(c);
    final b = resolveCategoryStyle(c);
    expect(a.iconKey, 'bills');
    expect(a.color, b.color);
  });
}
