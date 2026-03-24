# Travel Atlas Mobile App

This repository now contains the Flutter mobile app for Travel Atlas and the shared packages that support it.

## Workspace

- `apps/mobile_app`
  - App shell, platform adapters, and runtime bootstrap.
- `packages/core_domain`
  - Shared domain models and backend profile definitions.
- `packages/core_data`
  - Local store, repositories, Riverpod providers, and sync boundaries.
- `packages/core_navigation`
  - Shared tabs and route identifiers.
- `packages/core_ui`
  - Theme, reusable widgets, and formatting helpers.
- `packages/feature_atlas_home`
  - Home globe and entry surface.
- `packages/feature_timeline`
  - Chronological trip and memory playback.
- `packages/feature_journal`
  - Journal list and compose/import sheets.
- `packages/feature_places`
  - Country and city detail surfaces.
- `packages/feature_search`
  - Unified search across trips, places, and memories.
- `packages/feature_account`
  - Account, session, and sync status UI.
- `supabase/`
  - Optional backend schema and migrations.
- `docs/architecture/`
  - Architecture constraints and integration notes.

## Product Scope

The current app is built around:

- local-first travel history
- trip, city, and country exploration
- journal note capture
- photo import with metadata-based place inference
- optional Supabase-backed auth and sync

This repository no longer includes the earlier rendering candidate experiments.

## Prerequisites

- Flutter `3.32.0`
- Dart `3.8.0`

## Run The App

This repository uses a monorepo layout, so the Flutter app itself lives in `apps/mobile_app`. That structure is normal when one app shares multiple packages.

Local-first mode works without backend credentials:

```bash
cd apps/mobile_app
flutter pub get
flutter run
```

If you want to run from the repository root instead of changing directories:

```bash
make mobile-run
make mobile-run-ios
```

To enable the Supabase-backed runtime, pass Dart defines:

```bash
cd apps/mobile_app
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

If those values are missing, the app falls back to the local-first demo/runtime path.

## Google Maps

The original `record` web app used a Google Maps key via `VITE_GOOGLE_MAPS_API_KEY`.
The Flutter migration already contains native Google Maps surfaces in the planner and trip detail flows, but the native iOS and Android apps need the key wired separately.

Android:

Add this to `apps/mobile_app/android/local.properties`:

```properties
GOOGLE_MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY
```

iOS:

```bash
cp apps/mobile_app/ios/Flutter/Secrets.xcconfig.example apps/mobile_app/ios/Flutter/Secrets.xcconfig
```

Then set:

```xcconfig
GOOGLE_MAPS_API_KEY = YOUR_GOOGLE_MAPS_API_KEY
```

Once that key is present, the migrated Flutter planner and trip detail screens can render real Google Maps tiles.

## Native Globe

The mobile home globe now renders inside Flutter through the native `three_js`
path owned by `packages/feature_record`.

The runtime no longer depends on a bundled web embed or `WebView` composition.
Globe state flows through the new `globe` and `globe_engine` modules so the
home screen, selection UI, and renderer stay separated.

## Test

Run package tests from the package directory you are working in. Common entry points:

```bash
cd apps/mobile_app && flutter test
cd packages/core_data && flutter test
cd packages/feature_atlas_home && flutter test
```

From the repository root:

```bash
make mobile-test
```

## Architecture Notes

- Feature packages do not talk to Supabase directly.
- Backend selection happens only in the app bootstrap layer.
- The app should remain useful without remote auth or sync.

See `docs/architecture/supabase_to_spring_guardrails.md` for the backend boundary rules.
