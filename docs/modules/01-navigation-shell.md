# 01 — Navigation shell

## Business purpose
One predictable way to move around the app: four everyday destinations (Today, Plan, Transactions, Reports), a one-tap "add" action that is always reachable, and Settings one tap away. Works the same offline as online.

## Current state
- **Pages:** `lib/app/shell.dart` hosts a `PageView.builder`. Each page is created the first time it scrolls into view and then kept alive (`_KeepAlive`), so scroll position, filters and chart toggles survive tab switches. Swiping and tapping stay in sync.
- **Controller:** `lib/app/shell_controller.dart` (`shellTabProvider`) owns the selected index and the `PageController`. `goTo(i)` slides to an adjacent tab and jumps to a distant one (no flash through the tabs in between). Any screen may call `ref.read(shellTabProvider.notifier).goTo(n)`.
- **Bar:** `lib/core/ui/docked_nav_bar.dart` — a full-width liquid curved bar: the top edge dips in a smooth curve under the active tab and the active tab's icon is a plain filled icon in the brand colour (no circle or glow) that lifts into the dip. On a tab change the dip glides to the new tab with a springy overshoot and stretches while travelling. The add button (`DockedAddButton`, a 56 dp rounded square placed `centerDocked`, in a page-coloured cut-out ring, with a hand-painted round-capped plus) overlays the page and pops out above the bar's top edge in the centre gap, adding no bar height. The bar itself is compact: 56 dp plus the bottom inset, with nothing reserved above it. Every tab always shows its label (text scale capped at 1.2, scaled down to fit). Ongoing motion, static under reduced motion: only the add button's ring and breathing (3 s loop) and the attention badge's ping. A dot appears on History when synced changes need attention.
- **Tablet (≥ 600 dp):** same pages with a `NavigationRail`; the add action is a FAB in the rail.
- **Back button:** `_DoubleBackToExit` in `lib/app/shell.dart` wraps the shell in a `PopScope`. Back on another tab returns to Today; on Today the first press shows "Press back again to exit" and a second press within 2 s closes the app. Pushed routes pop normally.
- **App lock:** turning it off in Settings first requires a biometric/passcode prompt (`LockController.authenticate`, `lib/core/platform/app_lock.dart`). If the device has no screen lock at all the prompt is skipped so the user is never trapped.
- **Settings:** pushed route `/settings` from the app-bar gear (not a tab).
- **Pushed screens** (`/accounts`, `/categories`, `/reminders`, `/people`, `/diagnostics`, `/settings`) use `fadeRisePage` (200 ms fade plus 4% rise).

## Still needed
- Widget tests for tab sync (swipe ↔ tap) and the far-tab jump.
- Optional: remember the last tab across launches.

## Rules and constraints
- Exactly four destinations in `DockedNavBar` (two either side of the add button). A fifth belongs in Settings or a pushed route.
- Motion is minimal: one short motion per surface, ≤ 240 ms, nothing repeats except loading. Everything must stand still when the OS reduces motion (`Motion.reduced(context)`).
- No per-row animation inside long lists.
- Screens must not add their own bottom padding for the bar; the Scaffold reserves it.

## Related
- Feature docs: `../features/`
