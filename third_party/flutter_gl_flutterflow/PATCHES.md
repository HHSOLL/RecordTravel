# Repo-Local PoC Patches

This package is vendored for PoC reproducibility only.

Why it is vendored:
- Candidate B and Candidate C require `flutter_gl_flutterflow` for their current web/mobile validation path.
- Android validation required package-level compatibility edits.
- Keeping those edits only in pub-cache would make the PoC non-reproducible.

Android patches applied in this repo-local copy:
- Added `namespace 'com.futouapp.flutter_gl.flutter_gl'`
  - Required by the current AGP toolchain.
- Added explicit Java/Kotlin compatibility settings at Java 11
  - Required to avoid JVM target mismatch during Gradle compilation.
- Switched the plugin dependency declaration to:
  - `compileOnly files('libs/aars/threeegl.aar')`
  - This keeps compile-time access to `ThreeEgl` inside the plugin while allowing Candidate C to test app-layer packaging of the AAR.
- Candidate C app now adds:
  - `implementation(files("../../../../third_party/flutter_gl_flutterflow/android/libs/aars/threeegl.aar"))`
  - This is a targeted PoC feasibility experiment, not a production packaging decision.

Current expected Android result after these patches:
- Candidate B remains unvalidated under the app-layer packaging experiment.
- Candidate C is now used to test whether Android runtime feasibility can be recovered by packaging/distribution restructuring alone.

PoC rule:
- Do not treat this vendored package as a production dependency decision.
- Do not hide or suppress the remaining Android packaging blocker in reports.
