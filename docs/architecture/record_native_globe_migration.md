# Record Native Globe Migration

## Decision

Record home globe moves to a native in-app 3D path built around `three_js`, with `flutter_gl` and `vector_math` as the supporting runtime stack.

The WebView embed and the current `CustomPainter` globe are treated as prototypes only. They are not the primary product path.

## Why

The home globe is the product's signature interaction, not a static illustration. A native renderer keeps the interaction loop inside Flutter, avoids WebView composition trade-offs, and gives us one rendering model for mobile and desktop.

The direct goals are:

- stable drag / pinch / tap interaction
- country selection from the globe surface
- a clean path for highlight, label, search, and focus transitions
- no dependency on embedded web bundles for the main experience

## Target Shape

The implementation is split into four layers.

### Presentation

Owns screen state and navigation only.

- `GlobePage`
- `GlobeHud`
- `CountryBottomSheet`
- `SearchCountryPage`
- `GlobeViewModel`

Presentation should only know about selected country, focus state, and UI events.

### Domain

Owns use cases and selection rules.

- `SelectCountryUseCase`
- `FocusCountryUseCase`
- `SearchCountryUseCase`
- `BuildGlobeSceneUseCase`

Domain turns trip and country data into a globe scene model. It does not know about rendering widgets or platform views.

### Data

Owns repositories, asset loading, and offline globe inputs.

- `CountryRepository`
- `GlobeAssetRepository`
- `CountryMetadataService`
- `LocalCacheService`

Data should provide country metadata, anchors, textures, and any preprocessed border or ID-map assets.

### GlobeEngine

Owns rendering and interaction.

- `GlobeRenderer`
- `CameraController`
- `GestureController`
- `PickingController`
- `HighlightController`
- `AtmosphereController`

GlobeEngine is responsible for the 3D scene, not for app navigation or business logic.

## MVP Scope

The first native release should only ship the minimum that proves the architecture:

- sphere render with light/dark texture
- orbit rotation with drag and pinch zoom
- tap-to-select country
- selected-country highlight
- bottom sheet with country summary
- search that focuses a country

Non-goals for MVP:

- per-country mesh objects
- WebView fallback as the primary path
- full geopolitical boundary fidelity
- labels, arcs, clusters, or AR
- live topology parsing at runtime

## Asset Contract

Runtime assets should be preprocessed before the app sees them.

- base Earth textures for light and dark modes
- country ID texture for selection
- simplified border overlay
- country metadata JSON with anchor and display data

The app should not parse raw GeoJSON or shapefiles at runtime.

## Cleanup Plan

The migration should end in three cleanup passes.

1. Route home screen traffic to the native globe viewport and view model.
2. Move selection, scene assembly, and country metadata access behind domain/data boundaries.
3. Remove the WebView bundle path and retire the `CustomPainter` globe once the native path is stable on device.

After cleanup, the web embed toolchain becomes optional or removable, not part of the product runtime.

## Migration Rule

If a change touches globe interaction, it belongs in `GlobeEngine` or a domain use case, not in the screen widget.

If a change touches country data, it belongs in `Data`, not in the renderer.

If a change affects navigation or sheet state, it belongs in `Presentation`.

## Outcome

This gives the app one clear rendering path:

`Presentation -> Domain -> Data -> GlobeEngine`

That keeps the home globe maintainable while leaving room for future label, route, and focus features without reintroducing WebView coupling.
