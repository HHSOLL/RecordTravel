import 'package:flutter/foundation.dart';

import 'record_globe_country.dart';

const _unsetSceneSpecValue = Object();

@immutable
class RecordGlobeSceneSpec {
  const RecordGlobeSceneSpec({
    required this.style,
    required this.countries,
    this.initialCountryCode,
    this.selectedCountryCode,
    this.focusedCountryCode,
  });

  final RecordGlobeStyle style;
  final List<RecordGlobeCountry> countries;
  final String? initialCountryCode;
  final String? selectedCountryCode;
  final String? focusedCountryCode;

  RecordGlobeSceneSpec copyWith({
    RecordGlobeStyle? style,
    List<RecordGlobeCountry>? countries,
    Object? initialCountryCode = _unsetSceneSpecValue,
    Object? selectedCountryCode = _unsetSceneSpecValue,
    Object? focusedCountryCode = _unsetSceneSpecValue,
  }) {
    return RecordGlobeSceneSpec(
      style: style ?? this.style,
      countries: countries ?? this.countries,
      initialCountryCode: identical(initialCountryCode, _unsetSceneSpecValue)
          ? this.initialCountryCode
          : initialCountryCode as String?,
      selectedCountryCode: identical(selectedCountryCode, _unsetSceneSpecValue)
          ? this.selectedCountryCode
          : selectedCountryCode as String?,
      focusedCountryCode: identical(focusedCountryCode, _unsetSceneSpecValue)
          ? this.focusedCountryCode
          : focusedCountryCode as String?,
    );
  }
}

enum RecordGlobeStyle {
  light,
  dark,
}
