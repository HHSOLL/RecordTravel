# Travel Globe Rendering PoC

This repository implements a rendering PoC workspace for a Flutter-based travel globe.

## Workspace

- `packages/globe_poc_core`
  - Shared fixture data, camera math, interaction logic, benchmark state, validation logic, and the engine-agnostic shell.
- `apps/candidate_a_three_js`
  - Candidate A runner using `three_js`.
- `apps/candidate_b_three_dart`
  - Candidate B runner using `three_dart`.
- `apps/candidate_c_low_level`
  - Candidate C runner using `flutter_gl` with a custom low-level renderer path.
- `reports/`
  - Comparison and gate review templates for PoC results.

## Current Scope

This workspace is limited to:

- Rendering PoC implementation
- Candidate A/B/C comparison
- Shared benchmark and validation harness

This workspace does not include:

- Final engine selection
- Full application feature development
- Persistence, sync, media upload, or 2D drill-down integration

## Run

Each candidate is intentionally isolated because `three_js` and `three_dart` have incompatible transitive dependencies and cannot be resolved in a single Flutter app.

```bash
cd apps/candidate_a_three_js && flutter run
cd apps/candidate_b_three_dart && flutter run
cd apps/candidate_c_low_level && flutter run
```

## Validation

The shared shell includes:

- deterministic globe fixture generation
- drag orbit and pinch zoom input
- tap-to-country lookup using shared projection math
- validation buttons for correctness checks
- benchmark scenario controls
