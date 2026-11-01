import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// The app's one bottom-sheet frame: title row, keyboard-safe scrolling body
/// and an optional sticky footer. Sheets swap content inside this frame
/// instead of popping and opening another sheet.
class AppSheetFrame extends StatelessWidget {
  const AppSheetFrame({super.key, required this.title, required this.body, this.footer, this.header});
  final String title;
  final Widget? header;
  final Widget body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      padding: EdgeInsets.only(bottom: inset),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Tokens.s16, 0, Tokens.s8, Tokens.s8),
          child: Row(children: [
            Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
            IconButton(
              tooltip: 'Close',
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ]),
        ),
        if (header != null) Padding(padding: const EdgeInsets.fromLTRB(Tokens.s16, 0, Tokens.s16, Tokens.s12), child: header),
        Flexible(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(Tokens.s16, 0, Tokens.s16, Tokens.s16),
            child: body,
          ),
        ),
        if (footer != null)
          DecoratedBox(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant))),
            child: Padding(
              padding: const EdgeInsets.all(Tokens.s16),
              child: SizedBox(width: double.infinity, child: footer),
            ),
          ),
      ]),
    );
  }
}
