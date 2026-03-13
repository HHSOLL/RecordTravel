## 0.0.22

### Fixed
- **BREAKING FIX**: Fixed `platformViewRegistry` deprecation for Flutter 3.32.4+
  - Updated web implementation to use `dart:ui_web` instead of deprecated `dart:ui` 
  - Replaced `ui.platformViewRegistry` with `ui_web.platformViewRegistry`
  - This resolves the "platformViewRegistry getter is deprecated" warning
- Updated package name to `flutter_gl_flutterflow` for FlutterFlow compatibility
- Updated repository links to evt-app-eng organization

### Technical Details
- Web platform now imports `dart:ui_web` for proper platformViewRegistry access
- Maintains backward compatibility for all other platforms
- Fixed for Flutter SDK 3.32.4 and later versions

## 0.0.21

* Initial release based on original flutter_gl package
