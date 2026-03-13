import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseTravelRemoteDataSource implements TravelRemoteDataSource {
  SupabaseTravelRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const _tripsTable = 'trips';
  static const _entriesTable = 'journal_entries';
  static const _photosTable = 'photo_assets';

  @override
  Future<List<TripSummary>> fetchTrips() async {
    final rows = await _client
        .from(_tripsTable)
        .select()
        .order('start_date', ascending: false);
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(_tripFromRow)
        .toList(growable: false);
  }

  @override
  Future<List<JournalEntry>> fetchEntries() async {
    final rows = await _client
        .from(_entriesTable)
        .select()
        .order('recorded_at', ascending: false);
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(_entryFromRow)
        .toList(growable: false);
  }

  @override
  Future<List<PhotoAsset>> fetchPhotos() async {
    final rows = await _client
        .from(_photosTable)
        .select()
        .order('taken_at', ascending: false);
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(_photoFromRow)
        .toList(growable: false);
  }

  @override
  Future<void> upsertTrip(TripSummary trip) async {
    await _client.from(_tripsTable).upsert(_tripToRow(trip), onConflict: 'id');
  }

  @override
  Future<void> upsertEntry(JournalEntry entry) async {
    await _client
        .from(_entriesTable)
        .upsert(_entryToRow(entry), onConflict: 'id');
  }

  @override
  Future<void> upsertPhoto(PhotoAsset photo) async {
    await _client
        .from(_photosTable)
        .upsert(_photoToRow(photo), onConflict: 'id');
  }

  TripSummary _tripFromRow(Map<String, dynamic> row) {
    return TripSummary(
      id: row['id'] as String,
      title: row['title'] as String? ?? 'Untitled trip',
      subtitle: row['subtitle'] as String? ?? '',
      startDate: DateTime.parse(row['start_date'] as String),
      endDate: DateTime.parse(row['end_date'] as String),
      heroPlace: _placeFromJson(_jsonMap(row['hero_place'])),
      coverHint: row['cover_hint'] as String? ?? '',
      memoryCount: (row['memory_count'] as num?)?.toInt() ?? 0,
      photoCount: (row['photo_count'] as num?)?.toInt() ?? 0,
      countryCount: (row['country_count'] as num?)?.toInt() ?? 0,
    );
  }

  JournalEntry _entryFromRow(Map<String, dynamic> row) {
    return JournalEntry(
      id: row['id'] as String,
      tripId: row['trip_id'] as String,
      title: row['title'] as String? ?? 'Untitled memory',
      body: row['body'] as String? ?? '',
      recordedAt: DateTime.parse(row['recorded_at'] as String),
      place: _placeFromJson(_jsonMap(row['place'])),
      type: (row['type'] as String? ?? 'note') == 'photo'
          ? MemoryType.photo
          : MemoryType.note,
      photoAssetIds: ((row['photo_asset_ids'] as List?) ?? const [])
          .map((value) => value.toString())
          .toList(growable: false),
      hasPendingUpload: row['has_pending_upload'] as bool? ?? false,
    );
  }

  PhotoAsset _photoFromRow(Map<String, dynamic> row) {
    return PhotoAsset(
      id: row['id'] as String,
      fileName: row['file_name'] as String? ?? 'asset',
      previewLabel: row['preview_label'] as String? ?? 'PH',
      format: row['format'] as String? ?? 'JPEG',
      takenAt: DateTime.parse(row['taken_at'] as String),
      place: _placeFromJson(_jsonMap(row['place'])),
      uploadState: _uploadStateFromString(
        row['upload_state'] as String? ?? 'queued',
      ),
      localPath: null,
      storagePath: row['storage_path'] as String?,
      byteSize: (row['byte_size'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> _tripToRow(TripSummary trip) {
    final userId = _requireUserId();
    return {
      'id': trip.id,
      'user_id': userId,
      'title': trip.title,
      'subtitle': trip.subtitle,
      'start_date': trip.startDate.toIso8601String(),
      'end_date': trip.endDate.toIso8601String(),
      'hero_place': _placeToJson(trip.heroPlace),
      'cover_hint': trip.coverHint,
      'memory_count': trip.memoryCount,
      'photo_count': trip.photoCount,
      'country_count': trip.countryCount,
    };
  }

  Map<String, dynamic> _entryToRow(JournalEntry entry) {
    final userId = _requireUserId();
    return {
      'id': entry.id,
      'user_id': userId,
      'trip_id': entry.tripId,
      'title': entry.title,
      'body': entry.body,
      'recorded_at': entry.recordedAt.toIso8601String(),
      'place': _placeToJson(entry.place),
      'type': entry.type.name,
      'photo_asset_ids': entry.photoAssetIds,
      'has_pending_upload': entry.hasPendingUpload,
    };
  }

  Map<String, dynamic> _photoToRow(PhotoAsset photo) {
    final userId = _requireUserId();
    return {
      'id': photo.id,
      'user_id': userId,
      'file_name': photo.fileName,
      'preview_label': photo.previewLabel,
      'format': photo.format,
      'taken_at': photo.takenAt.toIso8601String(),
      'place': _placeToJson(photo.place),
      'upload_state': photo.uploadState.name,
      'storage_path': photo.storagePath,
      'byte_size': photo.byteSize,
    };
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('A Supabase session is required.');
    }
    return userId;
  }

  Map<String, dynamic> _jsonMap(Object? source) {
    if (source is Map<String, dynamic>) return source;
    if (source is Map) {
      return source.map((key, value) => MapEntry(key.toString(), value));
    }
    return const {};
  }

  PlaceRef _placeFromJson(Map<String, dynamic> json) {
    return PlaceRef(
      countryCode: json['country_code'] as String? ?? 'XX',
      countryName: json['country_name'] as String? ?? 'Unknown',
      cityName: json['city_name'] as String? ?? 'Unknown city',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> _placeToJson(PlaceRef place) => {
    'country_code': place.countryCode,
    'country_name': place.countryName,
    'city_name': place.cityName,
    'latitude': place.latitude,
    'longitude': place.longitude,
  };

  UploadState _uploadStateFromString(String value) {
    return UploadState.values.firstWhere(
      (state) => state.name == value,
      orElse: () => UploadState.localOnly,
    );
  }
}
