import 'package:flutter/foundation.dart';

@immutable
class RecordGlobeCountry {
  const RecordGlobeCountry({
    required this.code,
    required this.name,
    required this.anchorLatitude,
    required this.anchorLongitude,
    required this.continent,
    this.visitCount = 0,
    this.isSelectable = true,
  });

  final String code;
  final String name;
  final double anchorLatitude;
  final double anchorLongitude;
  final String continent;
  final int visitCount;
  final bool isSelectable;

  RecordGlobeCountry copyWith({
    String? code,
    String? name,
    double? anchorLatitude,
    double? anchorLongitude,
    String? continent,
    int? visitCount,
    bool? isSelectable,
  }) {
    return RecordGlobeCountry(
      code: code ?? this.code,
      name: name ?? this.name,
      anchorLatitude: anchorLatitude ?? this.anchorLatitude,
      anchorLongitude: anchorLongitude ?? this.anchorLongitude,
      continent: continent ?? this.continent,
      visitCount: visitCount ?? this.visitCount,
      isSelectable: isSelectable ?? this.isSelectable,
    );
  }
}
