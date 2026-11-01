# 01 — Navigation shell

## Business purpose
One predictable way to move around the app: four everyday destinations (Today, Plan, Transactions, Reports), a one-tap "add" action that is always reachable, and Settings one tap away. Works the same offline as online.

## Current state
- **Pages:** `lib/app/shell.dart` hosts a `PageView.builder`. Each page is created the first time it scrolls into view and then kept alive (`_KeepAlive`), so scroll position, filters and chart toggles survive tab switches. Swiping and tapping stay in sync.
- **Controller:** `lib/app/shell_controller.dart` (`shellTabProvider`) owns the selected index and the `PageController`. `goTo(i)` slides to an adjacent tab and jumps to a distant one (no flash through the tabs in between). Any screen may call `ref.read(shellTabProvider.notifier).goTo(n)`.
- **Bar:** `lib/core/ui/docked_nav_bar.dart` — a full-width docked `BottomAppBar` with rounded top corners and a circular notch for the add button (`DockedAddButton`, a 64 dp FAB placed `centerDocked` with a hand-painted round-capped plus; a soft halo ring pulses outward every 3 s and the plus breathes slightly — static under reduced motion). Four equal-width tabs, each always showing icon and label; the active tab gets a filled icon, the brand colour and a small indicator line. Label text scale is capped at 1.2 and scaled down to fit, so "Transactions" is never cut off. A dot appears on Transactions when synced changes need attention.
- **Tablet (≥ 600 dp):** same pages with a `NavigationRail`; the add action is a FAB in the rail.
- **Settings:** pushed route `/settings` from the app-bar gear (not a tab).
- **Pushed screens** (`/accounts`, `/categories`, `/reminders`, `/people`, `/diagnostics`, `/settings`) use `fadeRisePage` (200 ms fade plus 4% rise).

## Still needed
- Widget tests for tab sync (swipe ↔ tap) and the far-tab jump.
- Optional: remember the last tab across launches.

## Rules and constraints
- Exactly four destinations in `DockedNavBar` (two either side of the notch). A fifth belongs in Settings or a pushed route.
- Motion is minimal: one short motion per surface, ≤ 240 ms, nothing repeats except loading. Everything must stand still when the OS reduces motion (`Motion.reduced(context)`).
- No per-row animation inside long lists.
- Screens must not add their own bottom padding for the bar; the Scaffold reserves it.

## Related
- Feature docs: `../features/`
