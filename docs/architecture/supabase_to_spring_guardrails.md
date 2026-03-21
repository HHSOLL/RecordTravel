# Supabase-to-Spring Guardrails

These rules keep Travel Atlas easy to ship on Supabase today without coupling the product surface to one backend vendor.

## Boundary Rules

1. Feature packages must not import `supabase_flutter` or depend on backend SDK types.
2. Backend selection belongs only in `apps/mobile_app/lib/bootstrap` and the platform adapter layer.
3. The app must stay usable in local-first mode when remote auth or sync is unavailable.
4. Local persistence and remote sync are separate concerns behind shared contracts in `core_data`.
5. Session state is exposed through shared domain and repository interfaces, not backend response models.
6. Photo ingestion stays contract-driven, while EXIF decode and file access remain platform-specific.
7. Search, places, journal, and timeline snapshots are derived from shared app state rather than raw backend payloads.
8. Remote storage paths, auth payloads, and vendor-specific errors must not leak into reusable widgets.
9. Replacing Supabase with a Spring API should require changes in adapters and bootstrap wiring, not in feature packages.

## Current Runtime Shape

- `mobile_app_runtime_loader.dart` opens the local store first.
- If `SUPABASE_URL` and `SUPABASE_ANON_KEY` are present, the app wires Supabase-backed adapters.
- If those values are absent or startup fails, the app falls back to the local-first runtime.

## Practical Review Checklist

- New feature UI depends only on `core_domain`, `core_data`, `core_navigation`, or `core_ui`.
- Backend-specific packages are imported only under `apps/mobile_app/lib/platform` or `apps/mobile_app/lib/bootstrap`.
- New remote behavior is expressed through a shared contract before any backend-specific implementation is added.
- The app still renders and passes local widget/provider tests without network credentials.
