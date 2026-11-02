# Motion

All animation goes through `lib/core/ui/motion.dart` so timing is consistent and the app is static when the OS
asks for reduced motion (`Motion.reduced(context)`).

| Piece | Where | What it does |
| --- | --- | --- |
| `Motion.*` tokens | `motion.dart` | `fast` 180 ms, `normal` 320, `emphasized` 420, `slow` 520; `curve` easeOutCubic, `spring` gentle overshoot |
| `AnimatedMoney` | stat cards (dashboard, reports), hero | Tweens integer minor units old to new; ends exactly on the value |
| `sharedAxisPage` | routes in `lib/app/app.dart` | Short horizontal slide + fade for settings sub-pages |
| `_PageParallax` | `lib/app/shell.dart` | Drift/fade/scale of tab pages while swiping |
| App bar title switch | `shell.dart` | Fade + rise between tab titles |
| Add button pulse | `docked_nav_bar.dart` | Calm 3 s loop: ring expands and fades while the button breathes 1.0 to 1.05, then rests; off when motion is reduced |
| Nav tab change | `docked_nav_bar.dart` | Liquid dip glides to the new tab (springy overshoot, stretches mid-travel); the icon cross-fades to filled, lifts and grows 10% |
| Nav ambient loop | `docked_nav_bar.dart` | 3 s loop: the attention badge pings (the add button has its own pulse above); off when motion is reduced |
| `DailyBars` grow | `features/common/charts.dart` | Staggered bar growth on first build, animated on data change |
| Chart/table swap | `ChartCard` | Fade + 0.98 to 1 scale |
| Progress colour | dashboard hero | Colour cross-fade as status changes |
| `ShakeOnError` | add sheet amount field | One shake when an error first appears (keeps focus) |
| Add-sheet mode switch | `common/entry/add_sheet.dart` | `AnimatedSize` + fade/slide between forms |
| `_SuccessRing` | saved view | Expanding ring behind the success check |
| `PressableScale` | `TxTile` | Press feedback on transaction rows |
| Pull to refresh | `core/ui/pull_refresh.dart` (`RefreshableList`) | Binance-style: pulling opens a band above the content; a painted gold coin with a teal ring — the coin grows and the ring draws with the pull, haptic tick at the threshold, then the coin flips and the ring spins while syncing; no text; stays visible at least 700 ms; under reduced motion it stays a still coin |

Rules: use `RefreshableList` (never `RefreshIndicator`) for any top-level scrolling screen that has something to refresh, with `refreshAndNotify` from `lib/app/refresh_actions.dart`; never animate rows that scroll in long lists; use `Motion.*` instead of literals; animate money on integer
minor units only.
