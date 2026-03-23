import 'package:flutter/foundation.dart';

@immutable
class PlaceRef {
  const PlaceRef({
    required this.countryCode,
    required this.countryName,
    required this.cityName,
    this.latitude,
    this.longitude,
  });

  final String countryCode;
  final String countryName;
  final String cityName;
  final double? latitude;
  final double? longitude;

  String get cityKey => '$countryCode:$cityName';
  String get shortLabel => '$cityName, $countryCode';
  String get fullLabel => '$cityName, $countryName';
}

enum MemoryType { note, photo }
enum PhotoIngestionScope { selection, library }

enum UploadState { localOnly, queued, uploading, uploaded, failed }

enum SyncSeverity { synced, syncing, pending, attention }

enum SearchResultType { trip, entry, country, city }

enum BackendFlavor { demo, supabase, spring }

enum OutboxOperation { upsertTrip, upsertJournalEntry, upsertPhotoMetadata }

enum QueueDeliveryStatus { pending, processing, failed }

@immutable
class TripSummary {
  const TripSummary({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.startDate,
    required this.endDate,
    required this.heroPlace,
    required this.coverHint,
    required this.memoryCount,
    required this.photoCount,
    required this.countryCount,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime startDate;
  final DateTime endDate;
  final PlaceRef heroPlace;
  final String coverHint;
  final int memoryCount;
  final int photoCount;
  final int countryCount;

  String get dateRangeLabel =>
      '${startDate.year}.${startDate.month}.${startDate.day} - ${endDate.year}.${endDate.month}.${endDate.day}';

  TripSummary copyWith({
    String? title,
    String? subtitle,
    DateTime? startDate,
    DateTime? endDate,
    PlaceRef? heroPlace,
    String? coverHint,
    int? memoryCount,
    int? photoCount,
    int? countryCount,
  }) {
    return TripSummary(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      heroPlace: heroPlace ?? this.heroPlace,
      coverHint: coverHint ?? this.coverHint,
      memoryCount: memoryCount ?? this.memoryCount,
      photoCount: photoCount ?? this.photoCount,
      countryCount: countryCount ?? this.countryCount,
    );
  }
}

@immutable
class PhotoAsset {
  const PhotoAsset({
    required this.id,
    required this.fileName,
    required this.previewLabel,
    required this.format,
    required this.takenAt,
    required this.place,
    required this.uploadState,
    this.localPath,
    this.byteSize,
    this.storagePath,
  });

  final String id;
  final String fileName;
  final String previewLabel;
  final String format;
  final DateTime takenAt;
  final PlaceRef place;
  final UploadState uploadState;
  final String? localPath;
  final int? byteSize;
  final String? storagePath;

  PhotoAsset copyWith({
    String? fileName,
    String? previewLabel,
    String? format,
    DateTime? takenAt,
    PlaceRef? place,
    UploadState? uploadState,
    String? localPath,
    int? byteSize,
    String? storagePath,
  }) {
    return PhotoAsset(
      id: id,
      fileName: fileName ?? this.fileName,
      previewLabel: previewLabel ?? this.previewLabel,
      format: format ?? this.format,
      takenAt: takenAt ?? this.takenAt,
      place: place ?? this.place,
      uploadState: uploadState ?? this.uploadState,
      localPath: localPath ?? this.localPath,
      byteSize: byteSize ?? this.byteSize,
      storagePath: storagePath ?? this.storagePath,
    );
  }
}

@immutable
class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.tripId,
    required this.title,
    required this.body,
    required this.recordedAt,
    required this.place,
    required this.type,
    required this.photoAssetIds,
    required this.hasPendingUpload,
  });

  final String id;
  final String tripId;
  final String title;
  final String body;
  final DateTime recordedAt;
  final PlaceRef place;
  final MemoryType type;
  final List<String> photoAssetIds;
  final bool hasPendingUpload;
}

@immutable
class CountrySummary {
  const CountrySummary({
    required this.countryCode,
    required this.countryName,
    required this.visitCount,
    required this.cityCount,
    required this.lastVisitedAt,
  });

  final String countryCode;
  final String countryName;
  final int visitCount;
  final int cityCount;
  final DateTime lastVisitedAt;
}

@immutable
class CitySummary {
  const CitySummary({
    required this.key,
    required this.countryCode,
    required this.countryName,
    required this.cityName,
    required this.visitCount,
    required this.lastVisitedAt,
  });

  final String key;
  final String countryCode;
  final String countryName;
  final String cityName;
  final int visitCount;
  final DateTime lastVisitedAt;
}

@immutable
class CountryDetailSnapshot {
  const CountryDetailSnapshot({
    required this.summary,
    required this.cities,
    required this.entries,
    required this.trips,
  });

  final CountrySummary summary;
  final List<CitySummary> cities;
  final List<JournalEntry> entries;
  final List<TripSummary> trips;
}

@immutable
class CityDetailSnapshot {
  const CityDetailSnapshot({
    required this.summary,
    required this.entries,
    required this.trips,
  });

  final CitySummary summary;
  final List<JournalEntry> entries;
  final List<TripSummary> trips;
}

@immutable
class TimelineDayGroup {
  const TimelineDayGroup({required this.date, required this.entries});

  final DateTime date;
  final List<JournalEntry> entries;
}

@immutable
class SyncSnapshot {
  const SyncSnapshot({
    required this.severity,
    required this.bannerTitle,
    required this.bannerMessage,
    required this.pendingChanges,
    required this.pendingUploads,
    this.lastSyncedAt,
  });

  final SyncSeverity severity;
  final String bannerTitle;
  final String bannerMessage;
  final int pendingChanges;
  final int pendingUploads;
  final DateTime? lastSyncedAt;

  bool get needsAttention =>
      severity == SyncSeverity.attention ||
      pendingUploads > 0 ||
      pendingChanges > 0;

  SyncSnapshot copyWith({
    SyncSeverity? severity,
    String? bannerTitle,
    String? bannerMessage,
    int? pendingChanges,
    int? pendingUploads,
    DateTime? lastSyncedAt,
  }) {
    return SyncSnapshot(
      severity: severity ?? this.severity,
      bannerTitle: bannerTitle ?? this.bannerTitle,
      bannerMessage: bannerMessage ?? this.bannerMessage,
      pendingChanges: pendingChanges ?? this.pendingChanges,
      pendingUploads: pendingUploads ?? this.pendingUploads,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}

@immutable
class AtlasHomeSnapshot {
  const AtlasHomeSnapshot({
    required this.visitedCountries,
    required this.visitedCities,
    required this.totalTrips,
    required this.pendingUploads,
    required this.syncSnapshot,
    required this.recentTrips,
    required this.recentEntries,
    required this.highlightCountries,
  });

  final int visitedCountries;
  final int visitedCities;
  final int totalTrips;
  final int pendingUploads;
  final SyncSnapshot syncSnapshot;
  final List<TripSummary> recentTrips;
  final List<JournalEntry> recentEntries;
  final List<CountrySummary> highlightCountries;
}

@immutable
class SearchResultItem {
  const SearchResultItem({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    this.place,
  });

  final SearchResultType type;
  final String id;
  final String title;
  final String subtitle;
  final PlaceRef? place;
}

@immutable
class PhotoIngestionRequest {
  const PhotoIngestionRequest({
    this.tripId,
    this.scope = PhotoIngestionScope.selection,
  });

  final String? tripId;
  final PhotoIngestionScope scope;
}

@immutable
class ExtractedPhotoMetadata {
  const ExtractedPhotoMetadata({
    required this.id,
    required this.fileName,
    required this.displayName,
    required this.format,
    required this.previewLabel,
    required this.takenAt,
    this.sourcePath,
    this.byteSize,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String fileName;
  final String displayName;
  final String format;
  final String previewLabel;
  final DateTime takenAt;
  final String? sourcePath;
  final int? byteSize;
  final double? latitude;
  final double? longitude;
}

@immutable
class PlaceSuggestion {
  const PlaceSuggestion({
    required this.place,
    required this.confidence,
    required this.reason,
  });

  final PlaceRef place;
  final double confidence;
  final String reason;
}

@immutable
class PhotoImportDraft {
  const PhotoImportDraft({
    required this.metadata,
    required this.suggestion,
    required this.selectedPlace,
  });

  final ExtractedPhotoMetadata metadata;
  final PlaceSuggestion suggestion;
  final PlaceRef selectedPlace;

  PhotoImportDraft copyWith({PlaceRef? selectedPlace}) {
    return PhotoImportDraft(
      metadata: metadata,
      suggestion: suggestion,
      selectedPlace: selectedPlace ?? this.selectedPlace,
    );
  }
}

@immutable
class TravelAppState {
  const TravelAppState({
    required this.trips,
    required this.entries,
    required this.photos,
    required this.syncSnapshot,
  });

  final List<TripSummary> trips;
  final List<JournalEntry> entries;
  final List<PhotoAsset> photos;
  final SyncSnapshot syncSnapshot;

  TravelAppState copyWith({
    List<TripSummary>? trips,
    List<JournalEntry>? entries,
    List<PhotoAsset>? photos,
    SyncSnapshot? syncSnapshot,
  }) {
    return TravelAppState(
      trips: trips ?? this.trips,
      entries: entries ?? this.entries,
      photos: photos ?? this.photos,
      syncSnapshot: syncSnapshot ?? this.syncSnapshot,
    );
  }
}

@immutable
class SyncOutboxItem {
  const SyncOutboxItem({
    required this.id,
    required this.operation,
    required this.entityId,
    required this.status,
    required this.attemptCount,
    required this.createdAt,
    required this.updatedAt,
    this.lastError,
  });

  final String id;
  final OutboxOperation operation;
  final String entityId;
  final QueueDeliveryStatus status;
  final int attemptCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastError;
}

@immutable
class PendingMediaUploadTask {
  const PendingMediaUploadTask({
    required this.id,
    required this.photoId,
    required this.localPath,
    required this.fileName,
    required this.storageBucket,
    required this.storagePath,
    required this.status,
    required this.attemptCount,
    required this.createdAt,
    required this.updatedAt,
    this.lastError,
  });

  final String id;
  final String photoId;
  final String localPath;
  final String fileName;
  final String storageBucket;
  final String storagePath;
  final QueueDeliveryStatus status;
  final int attemptCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastError;
}

@immutable
class BackendProfile {
  const BackendProfile({
    required this.flavor,
    required this.label,
    required this.remoteSyncEnabled,
    required this.remoteAuthEnabled,
    required this.mediaUploadEnabled,
    required this.notes,
  });

  final BackendFlavor flavor;
  final String label;
  final bool remoteSyncEnabled;
  final bool remoteAuthEnabled;
  final bool mediaUploadEnabled;
  final String notes;
}

@immutable
class AppUserSummary {
  const AppUserSummary({
    required this.id,
    required this.displayName,
    required this.email,
    required this.homeBase,
  });

  final String id;
  final String displayName;
  final String email;
  final String homeBase;
}

@immutable
class SessionSnapshot {
  const SessionSnapshot({
    required this.user,
    required this.isSignedIn,
    required this.backendProfile,
  });

  final AppUserSummary user;
  final bool isSignedIn;
  final BackendProfile backendProfile;
}

@immutable
class SessionActionResult {
  const SessionActionResult({required this.success, required this.message});

  final bool success;
  final String message;
}
