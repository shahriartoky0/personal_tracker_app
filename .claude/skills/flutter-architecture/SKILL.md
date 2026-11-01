---
name: flutter-architecture
description: Layering, dependency rule and module boundaries for the Flutter app (domain, data, application, UI). Use when deciding where new code goes, adding a feature module, reviewing imports, or untangling a dependency between features, core and UI.
---

# Flutter architecture

## Layers (inner → outer)
1. **Domain** (`lib/core/domain/`) — pure Dart: entities, `Money`, calculators, `Result`/`Failure`, validation. No Flutter, drift, Supabase or IO imports.
2. **Data** (`lib/core/data/`) — drift DB, remote gateway, sync engines, `LedgerRepository`. Depends on domain only.
3. **Application** (`lib/features/<f>/application/`, `lib/app/providers.dart`) — Riverpod providers/controllers that orchestrate repositories. Depends on domain + data.
4. **UI** (screens/widgets, `lib/core/ui/`) — depends on application and domain; never on drift/Supabase directly.

## Dependency rule
Imports point inward only. Domain knows nothing about the others. UI never reaches data internals.

## Module boundaries
- A feature may use `core/` but must **not import another feature's internals**. Share via `core/` or `features/common/`.
- Cross-feature needs go through a provider exposed in `lib/app/providers.dart`.
- New cross-cutting capability → `core/`, with a module doc in `docs/modules/`.

## Adding a feature
Create `features/<name>/` with screen(s) and `application/`; add a BRD in `docs/modules/`; register routes in the app shell/router.
