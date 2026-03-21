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

## Main Entry Files

- `lib/main.dart`
- `lib/bootstrap/mobile_app_bootstrap.dart`
- `lib/bootstrap/mobile_app_runtime_loader.dart`
- `lib/shell/mobile_app_shell.dart`

## Test

```bash
flutter test
```
