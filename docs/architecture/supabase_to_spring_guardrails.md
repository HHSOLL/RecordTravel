# Supabase-to-Spring Guardrails

These rules keep the mobile app cheap to launch on Supabase without painting the product into a backend-specific corner.

1. Flutter feature modules do not import Supabase packages directly.
2. Backend selection happens only in app bootstrap overrides.
3. The shipped mobile app reads from a local-first store; remote sync is a separate gateway.
4. Photo ingestion contracts stay shared, but file decode / EXIF extraction remains platform-specific.
5. Session/auth state is exposed through shared contracts, not provider-specific backend models.
6. Search, timeline, places, and home snapshots are derived from shared app state, not backend response shapes.
7. Remote storage paths and auth payloads must not leak into product widgets.
8. A later Spring API should be able to replace the remote sync gateway while reusing the same local store contracts.
