# Record Travel Graph Projection

## Product framing

`feature_record` is no longer modeled as a set of disconnected screens.
It treats the product as one travel graph rendered through multiple projections:

- `Home globe`: 3D country-level preview and entry point
- `Country detail`: 2D map, timeline, and album projections for one country
- `Trip / planner / archive`: filtered slices of the same trip graph

## Source of truth inside `feature_record`

`recordTravelGraphProvider` is the feature-facing read model boundary.
It builds a single `RecordTravelGraph` from:

- `TripSummary`
- `JournalEntry`
- `PhotoAsset`

The graph then exposes:

- `RecordTrip`
- `RecordCountryProjection`
- timeline moments grouped by day
- album moments grouped by photo-backed memory
- country activity score, signal, and map bounds

This keeps the 3D globe, 2D map, and timeline/album views aligned without
re-aggregating country metrics in each screen.

## Globe interaction state machine

The home globe now follows one explicit progression:

`Idle -> CountryFocused -> CountryPinned -> CountryEntered`

Rules:

1. Initial scene hydration may focus the camera on a default country, but it does not auto-select a country.
2. First country tap previews and pins the country sheet.
3. Second tap on the same country enters the country detail screen.
4. Background tap or close clears selection.

## Country detail projections

`RecordCountryDetailScreen` renders one `RecordCountryProjection` through three tabs:

- `Map`: Google Maps markers + route overlays + country-level metrics
- `Timeline`: day-grouped moments derived from journal entries
- `Album`: photo-backed moments derived from the same timeline data

All three tabs read the same projection object. No tab owns a separate data model.

## Design constraints

- 3D home interaction stays on the native Flutter renderer path.
- 2D country detail uses a dedicated map SDK surface.
- `RecordCountrySignal` separates `neutral`, `planned`, and `visited` states.
- Activity score is based on trip count, city count, visit count, notes, photos, days, recent activity, and upcoming travel.

## Follow-up

The next architectural lift should move the travel graph projector below
`feature_record` so other features can consume the same graph without rebuilding
their own aggregates.
