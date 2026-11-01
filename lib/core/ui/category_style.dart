import 'package:flutter/material.dart';

import '../domain/entities.dart';

/// Curated icon set. Keys are what gets stored in `Category.icon`.
const Map<String, IconData> categoryIcons = {
  'restaurant': Icons.restaurant,
  'groceries': Icons.local_grocery_store,
  'coffee': Icons.local_cafe,
  'transport': Icons.directions_bus,
  'car': Icons.directions_car,
  'fuel': Icons.local_gas_station,
  'bills': Icons.receipt_long,
  'home': Icons.home,
  'electricity': Icons.bolt,
  'phone': Icons.smartphone,
  'shopping': Icons.shopping_bag,
  'clothes': Icons.checkroom,
  'health': Icons.favorite,
  'fitness': Icons.fitness_center,
  'entertainment': Icons.movie,
  'games': Icons.sports_esports,
  'travel': Icons.flight,
  'education': Icons.school,
  'gift': Icons.card_giftcard,
  'pets': Icons.pets,
  'kids': Icons.child_care,
  'salary': Icons.payments,
  'business': Icons.work,
  'savings': Icons.savings,
  'investment': Icons.trending_up,
  'bonus': Icons.emoji_events,
  'other': Icons.category,
};

/// Curated palette (hex `#RRGGBB`), stored in `Category.color`.
const List<String> categoryPalette = [
  '#E5484D',
  '#F76B15',
  '#E5A000',
  '#46A758',
  '#12A594',
  '#0091FF',
  '#3E63DD',
  '#8E4EC6',
  '#D6409F',
  '#6E56CF',
  '#8B8D98',
  '#A18072',
];

const _keywords = <String, List<String>>{
  'restaurant': ['food', 'dining', 'restaurant', 'meal', 'lunch', 'dinner'],
  'groceries': ['grocer', 'market', 'bazar'],
  'coffee': ['coffee', 'tea', 'snack'],
  'transport': ['transport', 'bus', 'rickshaw', 'commute', 'ride'],
  'car': ['car', 'taxi', 'uber', 'pathao'],
  'fuel': ['fuel', 'petrol', 'gas'],
  'bills': ['bill', 'utilit', 'rent'],
  'home': ['home', 'house', 'furniture'],
  'electricity': ['electric', 'power'],
  'phone': ['phone', 'mobile', 'internet', 'recharge'],
  'shopping': ['shop'],
  'clothes': ['cloth', 'fashion'],
  'health': ['health', 'medic', 'doctor', 'pharm'],
  'fitness': ['fitness', 'gym', 'sport'],
  'entertainment': ['entertain', 'movie', 'fun', 'subscription'],
  'games': ['game'],
  'travel': ['travel', 'trip', 'vacation', 'flight'],
  'education': ['educat', 'school', 'course', 'book', 'tuition'],
  'gift': ['gift', 'donat', 'charity'],
  'pets': ['pet'],
  'kids': ['kid', 'child', 'baby'],
  'salary': ['salary', 'wage', 'income', 'pay'],
  'business': ['business', 'freelance', 'client'],
  'savings': ['saving'],
  'investment': ['invest', 'dividend', 'interest'],
  'bonus': ['bonus', 'reward'],
};

@immutable
class CategoryStyle {
  const CategoryStyle(this.iconKey, this.icon, this.color);
  final String iconKey;
  final IconData icon;
  final Color color;
}

/// Icon key guessed from a category name; `other` when nothing matches.
String defaultIconKeyForName(String name) {
  final n = name.toLowerCase();
  for (final e in _keywords.entries) {
    if (e.value.any(n.contains)) return e.key;
  }
  return 'other';
}

/// Palette hex that is stable for a given key (id, or name for new ones).
String defaultColorHexFor(String key) {
  var h = 0;
  for (final u in key.codeUnits) {
    h = (h * 31 + u) & 0x7fffffff;
  }
  return categoryPalette[h % categoryPalette.length];
}

Color? parseHexColor(String? hex) {
  if (hex == null) return null;
  final m = RegExp(r'^#?([0-9a-fA-F]{6})$').firstMatch(hex.trim());
  if (m == null) return null;
  return Color(0xFF000000 | int.parse(m.group(1)!, radix: 16));
}

/// Stored values win; otherwise derive from the name / id.
CategoryStyle resolveCategoryStyle(Category c) {
  final key = categoryIcons.containsKey(c.icon) ? c.icon! : defaultIconKeyForName(c.name);
  final color = parseHexColor(c.color) ?? parseHexColor(defaultColorHexFor(c.id))!;
  return CategoryStyle(key, categoryIcons[key]!, color);
}

/// Round tinted avatar: coloured icon on a soft tint of the same colour.
class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({super.key, required this.icon, required this.color, this.size = 44});

  CategoryAvatar.of(Category c, {Key? key, double size = 44})
      : this(key: key, icon: resolveCategoryStyle(c).icon, color: resolveCategoryStyle(c).color, size: size);

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: dark ? 0.28 : 0.16),
      ),
      child: Icon(icon, size: size * 0.5, color: dark ? Color.lerp(color, Colors.white, 0.35) : color),
    );
  }
}
