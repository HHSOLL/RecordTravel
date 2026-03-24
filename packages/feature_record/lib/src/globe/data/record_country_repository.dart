import 'package:flutter/foundation.dart';

import '../domain/entities/record_globe_country.dart';

abstract class RecordCountryRepository {
  Future<List<RecordGlobeCountry>> loadCountries();

  Future<RecordGlobeCountry?> findByCode(String code);
}

class InMemoryRecordCountryRepository implements RecordCountryRepository {
  InMemoryRecordCountryRepository(this._countries);

  final List<RecordGlobeCountry> _countries;

  @override
  Future<RecordGlobeCountry?> findByCode(String code) async {
    for (final country in _countries) {
      if (country.code == code) {
        return country;
      }
    }
    return null;
  }

  @override
  Future<List<RecordGlobeCountry>> loadCountries() async {
    return List<RecordGlobeCountry>.unmodifiable(_countries);
  }
}

@immutable
class RecordCountryRepositoryError implements Exception {
  const RecordCountryRepositoryError(this.message);

  final String message;

  @override
  String toString() => 'RecordCountryRepositoryError($message)';
}
