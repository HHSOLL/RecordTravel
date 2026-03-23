# mobile_app

Flutter app shell for Travel Atlas.

## What Lives Here

- app entrypoint and startup loading UI
- Riverpod bootstrap overrides
- platform-specific photo ingestion adapters
- Supabase runtime wiring
- mobile shell that composes the shared feature packages

## Run

Run these commands from `apps/mobile_app`:

```bash
flutter pub get
flutter run
```

The repository root also provides convenience commands:

```bash
make mobile-run
make mobile-run-ios
```

## Optional Supabase Runtime

The app runs without backend credentials, but remote auth/sync is enabled only when both Dart defines are present:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Without those values the app boots into the local-first runtime.

## Optional Google Maps Runtime

The migrated `record` planner and trip detail screens already use `google_maps_flutter`.
To render real Google Maps tiles, provide the same Google Maps key that the web app expected as `VITE_GOOGLE_MAPS_API_KEY`.

Android:

Add this line to `android/local.properties`:

```properties
GOOGLE_MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY
```

Or export it before running:

```bash
export GOOGLE_MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY
flutter run
```

iOS:

```bash
cp ios/Flutter/Secrets.xcconfig.example ios/Flutter/Secrets.xcconfig
```

Then edit `ios/Flutter/Secrets.xcconfig`:

```xcconfig
GOOGLE_MAPS_API_KEY = YOUR_GOOGLE_MAPS_API_KEY
```

The current Flutter migration already supports map rendering, markers, and trip route polylines.
Places autocomplete from the web planner has not been ported yet.

## Main Entry Files

- `lib/main.dart`
- `lib/bootstrap/mobile_app_bootstrap.dart`
- `lib/bootstrap/mobile_app_runtime_loader.dart`
- `lib/shell/mobile_app_shell.dart`

## Test

```bash
flutter test
```
