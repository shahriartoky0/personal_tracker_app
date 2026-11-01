# Category illustration

Categories are shown as a coloured icon avatar plus name, not text chips.

- **Storage:** `Category.icon` holds a key from `categoryIcons`; `Category.color` holds `#RRGGBB` from `categoryPalette`
  (both in `lib/core/ui/category_style.dart`). Both are optional and sync with the category row.
- **Fallbacks:** `resolveCategoryStyle` uses stored values; otherwise the icon is guessed from the name
  (`defaultIconKeyForName`, else `other`) and the colour is a stable palette pick from the category id.
- **Add sheet:** `_CategoryTile` grid in `lib/features/transactions/add_sheet.dart`; selected tile gets a coloured ring and check.
- **Categories screen:** avatar in the list; edit dialog has icon grid and colour swatches (`lib/features/settings/categories_screen.dart`).
- Unknown icon keys or malformed colours never crash; they fall back as above.
