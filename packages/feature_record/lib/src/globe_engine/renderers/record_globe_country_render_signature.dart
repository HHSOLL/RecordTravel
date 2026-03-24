import '../../globe/domain/entities/record_globe_country.dart';

bool hasSameCountryRenderState(
  List<RecordGlobeCountry>? previous,
  List<RecordGlobeCountry>? next,
) {
  if (identical(previous, next)) {
    return true;
  }
  if (previous == null || next == null || previous.length != next.length) {
    return false;
  }

  for (var index = 0; index < previous.length; index += 1) {
    final prev = previous[index];
    final current = next[index];
    if (prev.code != current.code ||
        prev.visitCount != current.visitCount ||
        prev.anchorLatitude != current.anchorLatitude ||
        prev.anchorLongitude != current.anchorLongitude ||
        prev.activityLevel != current.activityLevel ||
        prev.signal != current.signal ||
        prev.hasRecentVisit != current.hasRecentVisit ||
        prev.hasUpcomingTrip != current.hasUpcomingTrip) {
      return false;
    }
  }

  return true;
}
