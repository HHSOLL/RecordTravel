import 'dart:convert';
import 'dart:io';

import 'package:core_domain/core_domain.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'drift_database.g.dart';

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb);
    if (decoded is List) {
      return decoded.map((value) => value.toString()).toList(growable: false);
    }
    return const [];
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

@DataClassName('DbTrip')
class Trips extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get subtitle => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get heroCountryCode => text()();
  TextColumn get heroCountryName => text()();
  TextColumn get heroCityName => text()();
  RealColumn get heroLatitude => real().nullable()();
  RealColumn get heroLongitude => real().nullable()();
  TextColumn get coverHint => text()();
  IntColumn get memoryCount => integer()();
  IntColumn get photoCount => integer()();
  IntColumn get countryCount => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('DbJournalEntry')
class JournalEntries extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text().references(Trips, #id)();
  TextColumn get title => text()();
  TextColumn get body => text()();
  DateTimeColumn get recordedAt => dateTime()();
  TextColumn get placeCountryCode => text()();
  TextColumn get placeCountryName => text()();
  TextColumn get placeCityName => text()();
  RealColumn get placeLatitude => real().nullable()();
  RealColumn get placeLongitude => real().nullable()();
  TextColumn get type => text()();
  TextColumn get photoAssetIds => text().map(const StringListConverter())();
  BoolColumn get hasPendingUpload => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('DbPhotoAsset')
class PhotoAssets extends Table {
  TextColumn get id => text()();
  TextColumn get fileName => text()();
  TextColumn get previewLabel => text()();
  TextColumn get format => text()();
  DateTimeColumn get takenAt => dateTime()();
  TextColumn get placeCountryCode => text()();
  TextColumn get placeCountryName => text()();
  TextColumn get placeCityName => text()();
  RealColumn get placeLatitude => real().nullable()();
  RealColumn get placeLongitude => real().nullable()();
  TextColumn get uploadState => text()();
  TextColumn get localPath => text().nullable()();
  TextColumn get storagePath => text().nullable()();
  IntColumn get byteSize => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('DbOutboxMutation')
class OutboxMutations extends Table {
  TextColumn get id => text()();
  TextColumn get operation => text()();
  TextColumn get entityId => text()();
  TextColumn get status => text()();
  IntColumn get attemptCount => integer()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('DbPendingMediaUpload')
class PendingMediaUploads extends Table {
  TextColumn get id => text()();
  TextColumn get photoId => text().references(PhotoAssets, #id)();
  TextColumn get localPath => text()();
  TextColumn get fileName => text()();
  TextColumn get storageBucket => text()();
  TextColumn get storagePath => text()();
  TextColumn get status => text()();
  IntColumn get attemptCount => integer()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('DbSyncState')
class SyncStates extends Table {
  IntColumn get id => integer()();
  TextColumn get severity => text()();
  TextColumn get bannerTitle => text()();
  TextColumn get bannerMessage => text()();
  IntColumn get pendingChanges => integer()();
  IntColumn get pendingUploads => integer()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'travel_atlas_mobile.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(
  tables: [
    Trips,
    JournalEntries,
    PhotoAssets,
    OutboxMutations,
    PendingMediaUploads,
    SyncStates,
  ],
)
class TravelAtlasDatabase extends _$TravelAtlasDatabase {
  TravelAtlasDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;
}

PlaceRef placeFromDb({
  required String countryCode,
  required String countryName,
  required String cityName,
  double? latitude,
  double? longitude,
}) {
  return PlaceRef(
    countryCode: countryCode,
    countryName: countryName,
    cityName: cityName,
    latitude: latitude,
    longitude: longitude,
  );
}
