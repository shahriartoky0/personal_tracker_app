import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The main tabs, in page order.
enum ShellTab { today, plan, transactions, reports }

/// Owns the selected tab and the [PageController] behind the shell's
/// PageView, so tapping the bar, swiping the pages and jumping from another
/// screen all go through one place.
class ShellController extends Notifier<int> {
  late final PageController pages;

  @override
  int build() {
    pages = PageController();
    ref.onDispose(pages.dispose);
    return 0;
  }

  /// Called by the bar and by in-app shortcuts ("Plan today", "See all").
  /// Adjacent tabs slide; distant tabs jump, so the pages in between never
  /// flash past.
  void goTo(int index) {
    if (index == state) return;
    final current = pages.hasClients ? (pages.page?.round() ?? state) : state;
    state = index;
    if (!pages.hasClients) return;
    if ((index - current).abs() > 1) {
      pages.jumpToPage(index);
    } else {
      pages.animateToPage(
        index,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// Called by the PageView when a swipe settles on a new page.
  void onPageChanged(int index) {
    if (index != state) state = index;
  }
}

final shellTabProvider = NotifierProvider<ShellController, int>(ShellController.new);
