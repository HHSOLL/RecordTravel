// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_database.dart';

// ignore_for_file: type=lint
class $TripsTable extends Trips with TableInfo<$TripsTable, DbTrip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtitleMeta = const VerificationMeta(
    'subtitle',
  );
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
    'subtitle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heroCountryCodeMeta = const VerificationMeta(
    'heroCountryCode',
  );
  @override
  late final GeneratedColumn<String> heroCountryCode = GeneratedColumn<String>(
    'hero_country_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heroCountryNameMeta = const VerificationMeta(
    'heroCountryName',
  );
  @override
  late final GeneratedColumn<String> heroCountryName = GeneratedColumn<String>(
    'hero_country_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heroCityNameMeta = const VerificationMeta(
    'heroCityName',
  );
  @override
  late final GeneratedColumn<String> heroCityName = GeneratedColumn<String>(
    'hero_city_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heroLatitudeMeta = const VerificationMeta(
    'heroLatitude',
  );
  @override
  late final GeneratedColumn<double> heroLatitude = GeneratedColumn<double>(
    'hero_latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heroLongitudeMeta = const VerificationMeta(
    'heroLongitude',
  );
  @override
  late final GeneratedColumn<double> heroLongitude = GeneratedColumn<double>(
    'hero_longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverHintMeta = const VerificationMeta(
    'coverHint',
  );
  @override
  late final GeneratedColumn<String> coverHint = GeneratedColumn<String>(
    'cover_hint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memoryCountMeta = const VerificationMeta(
    'memoryCount',
  );
  @override
  late final GeneratedColumn<int> memoryCount = GeneratedColumn<int>(
    'memory_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoCountMeta = const VerificationMeta(
    'photoCount',
  );
  @override
  late final GeneratedColumn<int> photoCount = GeneratedColumn<int>(
    'photo_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countryCountMeta = const VerificationMeta(
    'countryCount',
  );
  @override
  late final GeneratedColumn<int> countryCount = GeneratedColumn<int>(
    'country_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    subtitle,
    startDate,
    endDate,
    heroCountryCode,
    heroCountryName,
    heroCityName,
    heroLatitude,
    heroLongitude,
    coverHint,
    memoryCount,
    photoCount,
    countryCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbTrip> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(
        _subtitleMeta,
        subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta),
      );
    } else if (isInserting) {
      context.missing(_subtitleMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('hero_country_code')) {
      context.handle(
        _heroCountryCodeMeta,
        heroCountryCode.isAcceptableOrUnknown(
          data['hero_country_code']!,
          _heroCountryCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_heroCountryCodeMeta);
    }
    if (data.containsKey('hero_country_name')) {
      context.handle(
        _heroCountryNameMeta,
        heroCountryName.isAcceptableOrUnknown(
          data['hero_country_name']!,
          _heroCountryNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_heroCountryNameMeta);
    }
    if (data.containsKey('hero_city_name')) {
      context.handle(
        _heroCityNameMeta,
        heroCityName.isAcceptableOrUnknown(
          data['hero_city_name']!,
          _heroCityNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_heroCityNameMeta);
    }
    if (data.containsKey('hero_latitude')) {
      context.handle(
        _heroLatitudeMeta,
        heroLatitude.isAcceptableOrUnknown(
          data['hero_latitude']!,
          _heroLatitudeMeta,
        ),
      );
    }
    if (data.containsKey('hero_longitude')) {
      context.handle(
        _heroLongitudeMeta,
        heroLongitude.isAcceptableOrUnknown(
          data['hero_longitude']!,
          _heroLongitudeMeta,
        ),
      );
    }
    if (data.containsKey('cover_hint')) {
      context.handle(
        _coverHintMeta,
        coverHint.isAcceptableOrUnknown(data['cover_hint']!, _coverHintMeta),
      );
    } else if (isInserting) {
      context.missing(_coverHintMeta);
    }
    if (data.containsKey('memory_count')) {
      context.handle(
        _memoryCountMeta,
        memoryCount.isAcceptableOrUnknown(
          data['memory_count']!,
          _memoryCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_memoryCountMeta);
    }
    if (data.containsKey('photo_count')) {
      context.handle(
        _photoCountMeta,
        photoCount.isAcceptableOrUnknown(data['photo_count']!, _photoCountMeta),
      );
    } else if (isInserting) {
      context.missing(_photoCountMeta);
    }
    if (data.containsKey('country_count')) {
      context.handle(
        _countryCountMeta,
        countryCount.isAcceptableOrUnknown(
          data['country_count']!,
          _countryCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_countryCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbTrip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbTrip(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      subtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitle'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      )!,
      heroCountryCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hero_country_code'],
      )!,
      heroCountryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hero_country_name'],
      )!,
      heroCityName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hero_city_name'],
      )!,
      heroLatitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hero_latitude'],
      ),
      heroLongitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hero_longitude'],
      ),
      coverHint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_hint'],
      )!,
      memoryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}memory_count'],
      )!,
      photoCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}photo_count'],
      )!,
      countryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}country_count'],
      )!,
    );
  }

  @override
  $TripsTable createAlias(String alias) {
    return $TripsTable(attachedDatabase, alias);
  }
}

class DbTrip extends DataClass implements Insertable<DbTrip> {
  final String id;
  final String title;
  final String subtitle;
  final DateTime startDate;
  final DateTime endDate;
  final String heroCountryCode;
  final String heroCountryName;
  final String heroCityName;
  final double? heroLatitude;
  final double? heroLongitude;
  final String coverHint;
  final int memoryCount;
  final int photoCount;
  final int countryCount;
  const DbTrip({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.startDate,
    required this.endDate,
    required this.heroCountryCode,
    required this.heroCountryName,
    required this.heroCityName,
    this.heroLatitude,
    this.heroLongitude,
    required this.coverHint,
    required this.memoryCount,
    required this.photoCount,
    required this.countryCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['subtitle'] = Variable<String>(subtitle);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['hero_country_code'] = Variable<String>(heroCountryCode);
    map['hero_country_name'] = Variable<String>(heroCountryName);
    map['hero_city_name'] = Variable<String>(heroCityName);
    if (!nullToAbsent || heroLatitude != null) {
      map['hero_latitude'] = Variable<double>(heroLatitude);
    }
    if (!nullToAbsent || heroLongitude != null) {
      map['hero_longitude'] = Variable<double>(heroLongitude);
    }
    map['cover_hint'] = Variable<String>(coverHint);
    map['memory_count'] = Variable<int>(memoryCount);
    map['photo_count'] = Variable<int>(photoCount);
    map['country_count'] = Variable<int>(countryCount);
    return map;
  }

  TripsCompanion toCompanion(bool nullToAbsent) {
    return TripsCompanion(
      id: Value(id),
      title: Value(title),
      subtitle: Value(subtitle),
      startDate: Value(startDate),
      endDate: Value(endDate),
      heroCountryCode: Value(heroCountryCode),
      heroCountryName: Value(heroCountryName),
      heroCityName: Value(heroCityName),
      heroLatitude: heroLatitude == null && nullToAbsent
          ? const Value.absent()
          : Value(heroLatitude),
      heroLongitude: heroLongitude == null && nullToAbsent
          ? const Value.absent()
          : Value(heroLongitude),
      coverHint: Value(coverHint),
      memoryCount: Value(memoryCount),
      photoCount: Value(photoCount),
      countryCount: Value(countryCount),
    );
  }

  factory DbTrip.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbTrip(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String>(json['subtitle']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      heroCountryCode: serializer.fromJson<String>(json['heroCountryCode']),
      heroCountryName: serializer.fromJson<String>(json['heroCountryName']),
      heroCityName: serializer.fromJson<String>(json['heroCityName']),
      heroLatitude: serializer.fromJson<double?>(json['heroLatitude']),
      heroLongitude: serializer.fromJson<double?>(json['heroLongitude']),
      coverHint: serializer.fromJson<String>(json['coverHint']),
      memoryCount: serializer.fromJson<int>(json['memoryCount']),
      photoCount: serializer.fromJson<int>(json['photoCount']),
      countryCount: serializer.fromJson<int>(json['countryCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String>(subtitle),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'heroCountryCode': serializer.toJson<String>(heroCountryCode),
      'heroCountryName': serializer.toJson<String>(heroCountryName),
      'heroCityName': serializer.toJson<String>(heroCityName),
      'heroLatitude': serializer.toJson<double?>(heroLatitude),
      'heroLongitude': serializer.toJson<double?>(heroLongitude),
      'coverHint': serializer.toJson<String>(coverHint),
      'memoryCount': serializer.toJson<int>(memoryCount),
      'photoCount': serializer.toJson<int>(photoCount),
      'countryCount': serializer.toJson<int>(countryCount),
    };
  }

  DbTrip copyWith({
    String? id,
    String? title,
    String? subtitle,
    DateTime? startDate,
    DateTime? endDate,
    String? heroCountryCode,
    String? heroCountryName,
    String? heroCityName,
    Value<double?> heroLatitude = const Value.absent(),
    Value<double?> heroLongitude = const Value.absent(),
    String? coverHint,
    int? memoryCount,
    int? photoCount,
    int? countryCount,
  }) => DbTrip(
    id: id ?? this.id,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    heroCountryCode: heroCountryCode ?? this.heroCountryCode,
    heroCountryName: heroCountryName ?? this.heroCountryName,
    heroCityName: heroCityName ?? this.heroCityName,
    heroLatitude: heroLatitude.present ? heroLatitude.value : this.heroLatitude,
    heroLongitude: heroLongitude.present
        ? heroLongitude.value
        : this.heroLongitude,
    coverHint: coverHint ?? this.coverHint,
    memoryCount: memoryCount ?? this.memoryCount,
    photoCount: photoCount ?? this.photoCount,
    countryCount: countryCount ?? this.countryCount,
  );
  DbTrip copyWithCompanion(TripsCompanion data) {
    return DbTrip(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      heroCountryCode: data.heroCountryCode.present
          ? data.heroCountryCode.value
          : this.heroCountryCode,
      heroCountryName: data.heroCountryName.present
          ? data.heroCountryName.value
          : this.heroCountryName,
      heroCityName: data.heroCityName.present
          ? data.heroCityName.value
          : this.heroCityName,
      heroLatitude: data.heroLatitude.present
          ? data.heroLatitude.value
          : this.heroLatitude,
      heroLongitude: data.heroLongitude.present
          ? data.heroLongitude.value
          : this.heroLongitude,
      coverHint: data.coverHint.present ? data.coverHint.value : this.coverHint,
      memoryCount: data.memoryCount.present
          ? data.memoryCount.value
          : this.memoryCount,
      photoCount: data.photoCount.present
          ? data.photoCount.value
          : this.photoCount,
      countryCount: data.countryCount.present
          ? data.countryCount.value
          : this.countryCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbTrip(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('heroCountryCode: $heroCountryCode, ')
          ..write('heroCountryName: $heroCountryName, ')
          ..write('heroCityName: $heroCityName, ')
          ..write('heroLatitude: $heroLatitude, ')
          ..write('heroLongitude: $heroLongitude, ')
          ..write('coverHint: $coverHint, ')
          ..write('memoryCount: $memoryCount, ')
          ..write('photoCount: $photoCount, ')
          ..write('countryCount: $countryCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    subtitle,
    startDate,
    endDate,
    heroCountryCode,
    heroCountryName,
    heroCityName,
    heroLatitude,
    heroLongitude,
    coverHint,
    memoryCount,
    photoCount,
    countryCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbTrip &&
          other.id == this.id &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.heroCountryCode == this.heroCountryCode &&
          other.heroCountryName == this.heroCountryName &&
          other.heroCityName == this.heroCityName &&
          other.heroLatitude == this.heroLatitude &&
          other.heroLongitude == this.heroLongitude &&
          other.coverHint == this.coverHint &&
          other.memoryCount == this.memoryCount &&
          other.photoCount == this.photoCount &&
          other.countryCount == this.countryCount);
}

class TripsCompanion extends UpdateCompanion<DbTrip> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> subtitle;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<String> heroCountryCode;
  final Value<String> heroCountryName;
  final Value<String> heroCityName;
  final Value<double?> heroLatitude;
  final Value<double?> heroLongitude;
  final Value<String> coverHint;
  final Value<int> memoryCount;
  final Value<int> photoCount;
  final Value<int> countryCount;
  final Value<int> rowid;
  const TripsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.heroCountryCode = const Value.absent(),
    this.heroCountryName = const Value.absent(),
    this.heroCityName = const Value.absent(),
    this.heroLatitude = const Value.absent(),
    this.heroLongitude = const Value.absent(),
    this.coverHint = const Value.absent(),
    this.memoryCount = const Value.absent(),
    this.photoCount = const Value.absent(),
    this.countryCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripsCompanion.insert({
    required String id,
    required String title,
    required String subtitle,
    required DateTime startDate,
    required DateTime endDate,
    required String heroCountryCode,
    required String heroCountryName,
    required String heroCityName,
    this.heroLatitude = const Value.absent(),
    this.heroLongitude = const Value.absent(),
    required String coverHint,
    required int memoryCount,
    required int photoCount,
    required int countryCount,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       subtitle = Value(subtitle),
       startDate = Value(startDate),
       endDate = Value(endDate),
       heroCountryCode = Value(heroCountryCode),
       heroCountryName = Value(heroCountryName),
       heroCityName = Value(heroCityName),
       coverHint = Value(coverHint),
       memoryCount = Value(memoryCount),
       photoCount = Value(photoCount),
       countryCount = Value(countryCount);
  static Insertable<DbTrip> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? heroCountryCode,
    Expression<String>? heroCountryName,
    Expression<String>? heroCityName,
    Expression<double>? heroLatitude,
    Expression<double>? heroLongitude,
    Expression<String>? coverHint,
    Expression<int>? memoryCount,
    Expression<int>? photoCount,
    Expression<int>? countryCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (heroCountryCode != null) 'hero_country_code': heroCountryCode,
      if (heroCountryName != null) 'hero_country_name': heroCountryName,
      if (heroCityName != null) 'hero_city_name': heroCityName,
      if (heroLatitude != null) 'hero_latitude': heroLatitude,
      if (heroLongitude != null) 'hero_longitude': heroLongitude,
      if (coverHint != null) 'cover_hint': coverHint,
      if (memoryCount != null) 'memory_count': memoryCount,
      if (photoCount != null) 'photo_count': photoCount,
      if (countryCount != null) 'country_count': countryCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? subtitle,
    Value<DateTime>? startDate,
    Value<DateTime>? endDate,
    Value<String>? heroCountryCode,
    Value<String>? heroCountryName,
    Value<String>? heroCityName,
    Value<double?>? heroLatitude,
    Value<double?>? heroLongitude,
    Value<String>? coverHint,
    Value<int>? memoryCount,
    Value<int>? photoCount,
    Value<int>? countryCount,
    Value<int>? rowid,
  }) {
    return TripsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      heroCountryCode: heroCountryCode ?? this.heroCountryCode,
      heroCountryName: heroCountryName ?? this.heroCountryName,
      heroCityName: heroCityName ?? this.heroCityName,
      heroLatitude: heroLatitude ?? this.heroLatitude,
      heroLongitude: heroLongitude ?? this.heroLongitude,
      coverHint: coverHint ?? this.coverHint,
      memoryCount: memoryCount ?? this.memoryCount,
      photoCount: photoCount ?? this.photoCount,
      countryCount: countryCount ?? this.countryCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (heroCountryCode.present) {
      map['hero_country_code'] = Variable<String>(heroCountryCode.value);
    }
    if (heroCountryName.present) {
      map['hero_country_name'] = Variable<String>(heroCountryName.value);
    }
    if (heroCityName.present) {
      map['hero_city_name'] = Variable<String>(heroCityName.value);
    }
    if (heroLatitude.present) {
      map['hero_latitude'] = Variable<double>(heroLatitude.value);
    }
    if (heroLongitude.present) {
      map['hero_longitude'] = Variable<double>(heroLongitude.value);
    }
    if (coverHint.present) {
      map['cover_hint'] = Variable<String>(coverHint.value);
    }
    if (memoryCount.present) {
      map['memory_count'] = Variable<int>(memoryCount.value);
    }
    if (photoCount.present) {
      map['photo_count'] = Variable<int>(photoCount.value);
    }
    if (countryCount.present) {
      map['country_count'] = Variable<int>(countryCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('heroCountryCode: $heroCountryCode, ')
          ..write('heroCountryName: $heroCountryName, ')
          ..write('heroCityName: $heroCityName, ')
          ..write('heroLatitude: $heroLatitude, ')
          ..write('heroLongitude: $heroLongitude, ')
          ..write('coverHint: $coverHint, ')
          ..write('memoryCount: $memoryCount, ')
          ..write('photoCount: $photoCount, ')
          ..write('countryCount: $countryCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JournalEntriesTable extends JournalEntries
    with TableInfo<$JournalEntriesTable, DbJournalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeCountryCodeMeta = const VerificationMeta(
    'placeCountryCode',
  );
  @override
  late final GeneratedColumn<String> placeCountryCode = GeneratedColumn<String>(
    'place_country_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeCountryNameMeta = const VerificationMeta(
    'placeCountryName',
  );
  @override
  late final GeneratedColumn<String> placeCountryName = GeneratedColumn<String>(
    'place_country_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeCityNameMeta = const VerificationMeta(
    'placeCityName',
  );
  @override
  late final GeneratedColumn<String> placeCityName = GeneratedColumn<String>(
    'place_city_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeLatitudeMeta = const VerificationMeta(
    'placeLatitude',
  );
  @override
  late final GeneratedColumn<double> placeLatitude = GeneratedColumn<double>(
    'place_latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _placeLongitudeMeta = const VerificationMeta(
    'placeLongitude',
  );
  @override
  late final GeneratedColumn<double> placeLongitude = GeneratedColumn<double>(
    'place_longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  photoAssetIds = GeneratedColumn<String>(
    'photo_asset_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>($JournalEntriesTable.$converterphotoAssetIds);
  static const VerificationMeta _hasPendingUploadMeta = const VerificationMeta(
    'hasPendingUpload',
  );
  @override
  late final GeneratedColumn<bool> hasPendingUpload = GeneratedColumn<bool>(
    'has_pending_upload',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_pending_upload" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    title,
    body,
    recordedAt,
    placeCountryCode,
    placeCountryName,
    placeCityName,
    placeLatitude,
    placeLongitude,
    type,
    photoAssetIds,
    hasPendingUpload,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbJournalEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('place_country_code')) {
      context.handle(
        _placeCountryCodeMeta,
        placeCountryCode.isAcceptableOrUnknown(
          data['place_country_code']!,
          _placeCountryCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_placeCountryCodeMeta);
    }
    if (data.containsKey('place_country_name')) {
      context.handle(
        _placeCountryNameMeta,
        placeCountryName.isAcceptableOrUnknown(
          data['place_country_name']!,
          _placeCountryNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_placeCountryNameMeta);
    }
    if (data.containsKey('place_city_name')) {
      context.handle(
        _placeCityNameMeta,
        placeCityName.isAcceptableOrUnknown(
          data['place_city_name']!,
          _placeCityNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_placeCityNameMeta);
    }
    if (data.containsKey('place_latitude')) {
      context.handle(
        _placeLatitudeMeta,
        placeLatitude.isAcceptableOrUnknown(
          data['place_latitude']!,
          _placeLatitudeMeta,
        ),
      );
    }
    if (data.containsKey('place_longitude')) {
      context.handle(
        _placeLongitudeMeta,
        placeLongitude.isAcceptableOrUnknown(
          data['place_longitude']!,
          _placeLongitudeMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('has_pending_upload')) {
      context.handle(
        _hasPendingUploadMeta,
        hasPendingUpload.isAcceptableOrUnknown(
          data['has_pending_upload']!,
          _hasPendingUploadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hasPendingUploadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbJournalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbJournalEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      placeCountryCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_country_code'],
      )!,
      placeCountryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_country_name'],
      )!,
      placeCityName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_city_name'],
      )!,
      placeLatitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}place_latitude'],
      ),
      placeLongitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}place_longitude'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      photoAssetIds: $JournalEntriesTable.$converterphotoAssetIds.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}photo_asset_ids'],
        )!,
      ),
      hasPendingUpload: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_pending_upload'],
      )!,
    );
  }

  @override
  $JournalEntriesTable createAlias(String alias) {
    return $JournalEntriesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterphotoAssetIds =
      const StringListConverter();
}

class DbJournalEntry extends DataClass implements Insertable<DbJournalEntry> {
  final String id;
  final String tripId;
  final String title;
  final String body;
  final DateTime recordedAt;
  final String placeCountryCode;
  final String placeCountryName;
  final String placeCityName;
  final double? placeLatitude;
  final double? placeLongitude;
  final String type;
  final List<String> photoAssetIds;
  final bool hasPendingUpload;
  const DbJournalEntry({
    required this.id,
    required this.tripId,
    required this.title,
    required this.body,
    required this.recordedAt,
    required this.placeCountryCode,
    required this.placeCountryName,
    required this.placeCityName,
    this.placeLatitude,
    this.placeLongitude,
    required this.type,
    required this.photoAssetIds,
    required this.hasPendingUpload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['place_country_code'] = Variable<String>(placeCountryCode);
    map['place_country_name'] = Variable<String>(placeCountryName);
    map['place_city_name'] = Variable<String>(placeCityName);
    if (!nullToAbsent || placeLatitude != null) {
      map['place_latitude'] = Variable<double>(placeLatitude);
    }
    if (!nullToAbsent || placeLongitude != null) {
      map['place_longitude'] = Variable<double>(placeLongitude);
    }
    map['type'] = Variable<String>(type);
    {
      map['photo_asset_ids'] = Variable<String>(
        $JournalEntriesTable.$converterphotoAssetIds.toSql(photoAssetIds),
      );
    }
    map['has_pending_upload'] = Variable<bool>(hasPendingUpload);
    return map;
  }

  JournalEntriesCompanion toCompanion(bool nullToAbsent) {
    return JournalEntriesCompanion(
      id: Value(id),
      tripId: Value(tripId),
      title: Value(title),
      body: Value(body),
      recordedAt: Value(recordedAt),
      placeCountryCode: Value(placeCountryCode),
      placeCountryName: Value(placeCountryName),
      placeCityName: Value(placeCityName),
      placeLatitude: placeLatitude == null && nullToAbsent
          ? const Value.absent()
          : Value(placeLatitude),
      placeLongitude: placeLongitude == null && nullToAbsent
          ? const Value.absent()
          : Value(placeLongitude),
      type: Value(type),
      photoAssetIds: Value(photoAssetIds),
      hasPendingUpload: Value(hasPendingUpload),
    );
  }

  factory DbJournalEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbJournalEntry(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      placeCountryCode: serializer.fromJson<String>(json['placeCountryCode']),
      placeCountryName: serializer.fromJson<String>(json['placeCountryName']),
      placeCityName: serializer.fromJson<String>(json['placeCityName']),
      placeLatitude: serializer.fromJson<double?>(json['placeLatitude']),
      placeLongitude: serializer.fromJson<double?>(json['placeLongitude']),
      type: serializer.fromJson<String>(json['type']),
      photoAssetIds: serializer.fromJson<List<String>>(json['photoAssetIds']),
      hasPendingUpload: serializer.fromJson<bool>(json['hasPendingUpload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'placeCountryCode': serializer.toJson<String>(placeCountryCode),
      'placeCountryName': serializer.toJson<String>(placeCountryName),
      'placeCityName': serializer.toJson<String>(placeCityName),
      'placeLatitude': serializer.toJson<double?>(placeLatitude),
      'placeLongitude': serializer.toJson<double?>(placeLongitude),
      'type': serializer.toJson<String>(type),
      'photoAssetIds': serializer.toJson<List<String>>(photoAssetIds),
      'hasPendingUpload': serializer.toJson<bool>(hasPendingUpload),
    };
  }

  DbJournalEntry copyWith({
    String? id,
    String? tripId,
    String? title,
    String? body,
    DateTime? recordedAt,
    String? placeCountryCode,
    String? placeCountryName,
    String? placeCityName,
    Value<double?> placeLatitude = const Value.absent(),
    Value<double?> placeLongitude = const Value.absent(),
    String? type,
    List<String>? photoAssetIds,
    bool? hasPendingUpload,
  }) => DbJournalEntry(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    title: title ?? this.title,
    body: body ?? this.body,
    recordedAt: recordedAt ?? this.recordedAt,
    placeCountryCode: placeCountryCode ?? this.placeCountryCode,
    placeCountryName: placeCountryName ?? this.placeCountryName,
    placeCityName: placeCityName ?? this.placeCityName,
    placeLatitude: placeLatitude.present
        ? placeLatitude.value
        : this.placeLatitude,
    placeLongitude: placeLongitude.present
        ? placeLongitude.value
        : this.placeLongitude,
    type: type ?? this.type,
    photoAssetIds: photoAssetIds ?? this.photoAssetIds,
    hasPendingUpload: hasPendingUpload ?? this.hasPendingUpload,
  );
  DbJournalEntry copyWithCompanion(JournalEntriesCompanion data) {
    return DbJournalEntry(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      placeCountryCode: data.placeCountryCode.present
          ? data.placeCountryCode.value
          : this.placeCountryCode,
      placeCountryName: data.placeCountryName.present
          ? data.placeCountryName.value
          : this.placeCountryName,
      placeCityName: data.placeCityName.present
          ? data.placeCityName.value
          : this.placeCityName,
      placeLatitude: data.placeLatitude.present
          ? data.placeLatitude.value
          : this.placeLatitude,
      placeLongitude: data.placeLongitude.present
          ? data.placeLongitude.value
          : this.placeLongitude,
      type: data.type.present ? data.type.value : this.type,
      photoAssetIds: data.photoAssetIds.present
          ? data.photoAssetIds.value
          : this.photoAssetIds,
      hasPendingUpload: data.hasPendingUpload.present
          ? data.hasPendingUpload.value
          : this.hasPendingUpload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbJournalEntry(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('placeCountryCode: $placeCountryCode, ')
          ..write('placeCountryName: $placeCountryName, ')
          ..write('placeCityName: $placeCityName, ')
          ..write('placeLatitude: $placeLatitude, ')
          ..write('placeLongitude: $placeLongitude, ')
          ..write('type: $type, ')
          ..write('photoAssetIds: $photoAssetIds, ')
          ..write('hasPendingUpload: $hasPendingUpload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    title,
    body,
    recordedAt,
    placeCountryCode,
    placeCountryName,
    placeCityName,
    placeLatitude,
    placeLongitude,
    type,
    photoAssetIds,
    hasPendingUpload,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbJournalEntry &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.title == this.title &&
          other.body == this.body &&
          other.recordedAt == this.recordedAt &&
          other.placeCountryCode == this.placeCountryCode &&
          other.placeCountryName == this.placeCountryName &&
          other.placeCityName == this.placeCityName &&
          other.placeLatitude == this.placeLatitude &&
          other.placeLongitude == this.placeLongitude &&
          other.type == this.type &&
          other.photoAssetIds == this.photoAssetIds &&
          other.hasPendingUpload == this.hasPendingUpload);
}

class JournalEntriesCompanion extends UpdateCompanion<DbJournalEntry> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> title;
  final Value<String> body;
  final Value<DateTime> recordedAt;
  final Value<String> placeCountryCode;
  final Value<String> placeCountryName;
  final Value<String> placeCityName;
  final Value<double?> placeLatitude;
  final Value<double?> placeLongitude;
  final Value<String> type;
  final Value<List<String>> photoAssetIds;
  final Value<bool> hasPendingUpload;
  final Value<int> rowid;
  const JournalEntriesCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.placeCountryCode = const Value.absent(),
    this.placeCountryName = const Value.absent(),
    this.placeCityName = const Value.absent(),
    this.placeLatitude = const Value.absent(),
    this.placeLongitude = const Value.absent(),
    this.type = const Value.absent(),
    this.photoAssetIds = const Value.absent(),
    this.hasPendingUpload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalEntriesCompanion.insert({
    required String id,
    required String tripId,
    required String title,
    required String body,
    required DateTime recordedAt,
    required String placeCountryCode,
    required String placeCountryName,
    required String placeCityName,
    this.placeLatitude = const Value.absent(),
    this.placeLongitude = const Value.absent(),
    required String type,
    required List<String> photoAssetIds,
    required bool hasPendingUpload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       title = Value(title),
       body = Value(body),
       recordedAt = Value(recordedAt),
       placeCountryCode = Value(placeCountryCode),
       placeCountryName = Value(placeCountryName),
       placeCityName = Value(placeCityName),
       type = Value(type),
       photoAssetIds = Value(photoAssetIds),
       hasPendingUpload = Value(hasPendingUpload);
  static Insertable<DbJournalEntry> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? title,
    Expression<String>? body,
    Expression<DateTime>? recordedAt,
    Expression<String>? placeCountryCode,
    Expression<String>? placeCountryName,
    Expression<String>? placeCityName,
    Expression<double>? placeLatitude,
    Expression<double>? placeLongitude,
    Expression<String>? type,
    Expression<String>? photoAssetIds,
    Expression<bool>? hasPendingUpload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (placeCountryCode != null) 'place_country_code': placeCountryCode,
      if (placeCountryName != null) 'place_country_name': placeCountryName,
      if (placeCityName != null) 'place_city_name': placeCityName,
      if (placeLatitude != null) 'place_latitude': placeLatitude,
      if (placeLongitude != null) 'place_longitude': placeLongitude,
      if (type != null) 'type': type,
      if (photoAssetIds != null) 'photo_asset_ids': photoAssetIds,
      if (hasPendingUpload != null) 'has_pending_upload': hasPendingUpload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String>? title,
    Value<String>? body,
    Value<DateTime>? recordedAt,
    Value<String>? placeCountryCode,
    Value<String>? placeCountryName,
    Value<String>? placeCityName,
    Value<double?>? placeLatitude,
    Value<double?>? placeLongitude,
    Value<String>? type,
    Value<List<String>>? photoAssetIds,
    Value<bool>? hasPendingUpload,
    Value<int>? rowid,
  }) {
    return JournalEntriesCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      body: body ?? this.body,
      recordedAt: recordedAt ?? this.recordedAt,
      placeCountryCode: placeCountryCode ?? this.placeCountryCode,
      placeCountryName: placeCountryName ?? this.placeCountryName,
      placeCityName: placeCityName ?? this.placeCityName,
      placeLatitude: placeLatitude ?? this.placeLatitude,
      placeLongitude: placeLongitude ?? this.placeLongitude,
      type: type ?? this.type,
      photoAssetIds: photoAssetIds ?? this.photoAssetIds,
      hasPendingUpload: hasPendingUpload ?? this.hasPendingUpload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (placeCountryCode.present) {
      map['place_country_code'] = Variable<String>(placeCountryCode.value);
    }
    if (placeCountryName.present) {
      map['place_country_name'] = Variable<String>(placeCountryName.value);
    }
    if (placeCityName.present) {
      map['place_city_name'] = Variable<String>(placeCityName.value);
    }
    if (placeLatitude.present) {
      map['place_latitude'] = Variable<double>(placeLatitude.value);
    }
    if (placeLongitude.present) {
      map['place_longitude'] = Variable<double>(placeLongitude.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (photoAssetIds.present) {
      map['photo_asset_ids'] = Variable<String>(
        $JournalEntriesTable.$converterphotoAssetIds.toSql(photoAssetIds.value),
      );
    }
    if (hasPendingUpload.present) {
      map['has_pending_upload'] = Variable<bool>(hasPendingUpload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntriesCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('placeCountryCode: $placeCountryCode, ')
          ..write('placeCountryName: $placeCountryName, ')
          ..write('placeCityName: $placeCityName, ')
          ..write('placeLatitude: $placeLatitude, ')
          ..write('placeLongitude: $placeLongitude, ')
          ..write('type: $type, ')
          ..write('photoAssetIds: $photoAssetIds, ')
          ..write('hasPendingUpload: $hasPendingUpload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotoAssetsTable extends PhotoAssets
    with TableInfo<$PhotoAssetsTable, DbPhotoAsset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotoAssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previewLabelMeta = const VerificationMeta(
    'previewLabel',
  );
  @override
  late final GeneratedColumn<String> previewLabel = GeneratedColumn<String>(
    'preview_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeCountryCodeMeta = const VerificationMeta(
    'placeCountryCode',
  );
  @override
  late final GeneratedColumn<String> placeCountryCode = GeneratedColumn<String>(
    'place_country_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeCountryNameMeta = const VerificationMeta(
    'placeCountryName',
  );
  @override
  late final GeneratedColumn<String> placeCountryName = GeneratedColumn<String>(
    'place_country_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeCityNameMeta = const VerificationMeta(
    'placeCityName',
  );
  @override
  late final GeneratedColumn<String> placeCityName = GeneratedColumn<String>(
    'place_city_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeLatitudeMeta = const VerificationMeta(
    'placeLatitude',
  );
  @override
  late final GeneratedColumn<double> placeLatitude = GeneratedColumn<double>(
    'place_latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _placeLongitudeMeta = const VerificationMeta(
    'placeLongitude',
  );
  @override
  late final GeneratedColumn<double> placeLongitude = GeneratedColumn<double>(
    'place_longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uploadStateMeta = const VerificationMeta(
    'uploadState',
  );
  @override
  late final GeneratedColumn<String> uploadState = GeneratedColumn<String>(
    'upload_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _storagePathMeta = const VerificationMeta(
    'storagePath',
  );
  @override
  late final GeneratedColumn<String> storagePath = GeneratedColumn<String>(
    'storage_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _byteSizeMeta = const VerificationMeta(
    'byteSize',
  );
  @override
  late final GeneratedColumn<int> byteSize = GeneratedColumn<int>(
    'byte_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fileName,
    previewLabel,
    format,
    takenAt,
    placeCountryCode,
    placeCountryName,
    placeCityName,
    placeLatitude,
    placeLongitude,
    uploadState,
    localPath,
    storagePath,
    byteSize,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photo_assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbPhotoAsset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('preview_label')) {
      context.handle(
        _previewLabelMeta,
        previewLabel.isAcceptableOrUnknown(
          data['preview_label']!,
          _previewLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_previewLabelMeta);
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    if (data.containsKey('place_country_code')) {
      context.handle(
        _placeCountryCodeMeta,
        placeCountryCode.isAcceptableOrUnknown(
          data['place_country_code']!,
          _placeCountryCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_placeCountryCodeMeta);
    }
    if (data.containsKey('place_country_name')) {
      context.handle(
        _placeCountryNameMeta,
        placeCountryName.isAcceptableOrUnknown(
          data['place_country_name']!,
          _placeCountryNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_placeCountryNameMeta);
    }
    if (data.containsKey('place_city_name')) {
      context.handle(
        _placeCityNameMeta,
        placeCityName.isAcceptableOrUnknown(
          data['place_city_name']!,
          _placeCityNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_placeCityNameMeta);
    }
    if (data.containsKey('place_latitude')) {
      context.handle(
        _placeLatitudeMeta,
        placeLatitude.isAcceptableOrUnknown(
          data['place_latitude']!,
          _placeLatitudeMeta,
        ),
      );
    }
    if (data.containsKey('place_longitude')) {
      context.handle(
        _placeLongitudeMeta,
        placeLongitude.isAcceptableOrUnknown(
          data['place_longitude']!,
          _placeLongitudeMeta,
        ),
      );
    }
    if (data.containsKey('upload_state')) {
      context.handle(
        _uploadStateMeta,
        uploadState.isAcceptableOrUnknown(
          data['upload_state']!,
          _uploadStateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uploadStateMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('storage_path')) {
      context.handle(
        _storagePathMeta,
        storagePath.isAcceptableOrUnknown(
          data['storage_path']!,
          _storagePathMeta,
        ),
      );
    }
    if (data.containsKey('byte_size')) {
      context.handle(
        _byteSizeMeta,
        byteSize.isAcceptableOrUnknown(data['byte_size']!, _byteSizeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbPhotoAsset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbPhotoAsset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      previewLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preview_label'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      )!,
      placeCountryCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_country_code'],
      )!,
      placeCountryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_country_name'],
      )!,
      placeCityName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_city_name'],
      )!,
      placeLatitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}place_latitude'],
      ),
      placeLongitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}place_longitude'],
      ),
      uploadState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upload_state'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      storagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_path'],
      ),
      byteSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_size'],
      ),
    );
  }

  @override
  $PhotoAssetsTable createAlias(String alias) {
    return $PhotoAssetsTable(attachedDatabase, alias);
  }
}

class DbPhotoAsset extends DataClass implements Insertable<DbPhotoAsset> {
  final String id;
  final String fileName;
  final String previewLabel;
  final String format;
  final DateTime takenAt;
  final String placeCountryCode;
  final String placeCountryName;
  final String placeCityName;
  final double? placeLatitude;
  final double? placeLongitude;
  final String uploadState;
  final String? localPath;
  final String? storagePath;
  final int? byteSize;
  const DbPhotoAsset({
    required this.id,
    required this.fileName,
    required this.previewLabel,
    required this.format,
    required this.takenAt,
    required this.placeCountryCode,
    required this.placeCountryName,
    required this.placeCityName,
    this.placeLatitude,
    this.placeLongitude,
    required this.uploadState,
    this.localPath,
    this.storagePath,
    this.byteSize,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['file_name'] = Variable<String>(fileName);
    map['preview_label'] = Variable<String>(previewLabel);
    map['format'] = Variable<String>(format);
    map['taken_at'] = Variable<DateTime>(takenAt);
    map['place_country_code'] = Variable<String>(placeCountryCode);
    map['place_country_name'] = Variable<String>(placeCountryName);
    map['place_city_name'] = Variable<String>(placeCityName);
    if (!nullToAbsent || placeLatitude != null) {
      map['place_latitude'] = Variable<double>(placeLatitude);
    }
    if (!nullToAbsent || placeLongitude != null) {
      map['place_longitude'] = Variable<double>(placeLongitude);
    }
    map['upload_state'] = Variable<String>(uploadState);
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || storagePath != null) {
      map['storage_path'] = Variable<String>(storagePath);
    }
    if (!nullToAbsent || byteSize != null) {
      map['byte_size'] = Variable<int>(byteSize);
    }
    return map;
  }

  PhotoAssetsCompanion toCompanion(bool nullToAbsent) {
    return PhotoAssetsCompanion(
      id: Value(id),
      fileName: Value(fileName),
      previewLabel: Value(previewLabel),
      format: Value(format),
      takenAt: Value(takenAt),
      placeCountryCode: Value(placeCountryCode),
      placeCountryName: Value(placeCountryName),
      placeCityName: Value(placeCityName),
      placeLatitude: placeLatitude == null && nullToAbsent
          ? const Value.absent()
          : Value(placeLatitude),
      placeLongitude: placeLongitude == null && nullToAbsent
          ? const Value.absent()
          : Value(placeLongitude),
      uploadState: Value(uploadState),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      storagePath: storagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(storagePath),
      byteSize: byteSize == null && nullToAbsent
          ? const Value.absent()
          : Value(byteSize),
    );
  }

  factory DbPhotoAsset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbPhotoAsset(
      id: serializer.fromJson<String>(json['id']),
      fileName: serializer.fromJson<String>(json['fileName']),
      previewLabel: serializer.fromJson<String>(json['previewLabel']),
      format: serializer.fromJson<String>(json['format']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
      placeCountryCode: serializer.fromJson<String>(json['placeCountryCode']),
      placeCountryName: serializer.fromJson<String>(json['placeCountryName']),
      placeCityName: serializer.fromJson<String>(json['placeCityName']),
      placeLatitude: serializer.fromJson<double?>(json['placeLatitude']),
      placeLongitude: serializer.fromJson<double?>(json['placeLongitude']),
      uploadState: serializer.fromJson<String>(json['uploadState']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      storagePath: serializer.fromJson<String?>(json['storagePath']),
      byteSize: serializer.fromJson<int?>(json['byteSize']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fileName': serializer.toJson<String>(fileName),
      'previewLabel': serializer.toJson<String>(previewLabel),
      'format': serializer.toJson<String>(format),
      'takenAt': serializer.toJson<DateTime>(takenAt),
      'placeCountryCode': serializer.toJson<String>(placeCountryCode),
      'placeCountryName': serializer.toJson<String>(placeCountryName),
      'placeCityName': serializer.toJson<String>(placeCityName),
      'placeLatitude': serializer.toJson<double?>(placeLatitude),
      'placeLongitude': serializer.toJson<double?>(placeLongitude),
      'uploadState': serializer.toJson<String>(uploadState),
      'localPath': serializer.toJson<String?>(localPath),
      'storagePath': serializer.toJson<String?>(storagePath),
      'byteSize': serializer.toJson<int?>(byteSize),
    };
  }

  DbPhotoAsset copyWith({
    String? id,
    String? fileName,
    String? previewLabel,
    String? format,
    DateTime? takenAt,
    String? placeCountryCode,
    String? placeCountryName,
    String? placeCityName,
    Value<double?> placeLatitude = const Value.absent(),
    Value<double?> placeLongitude = const Value.absent(),
    String? uploadState,
    Value<String?> localPath = const Value.absent(),
    Value<String?> storagePath = const Value.absent(),
    Value<int?> byteSize = const Value.absent(),
  }) => DbPhotoAsset(
    id: id ?? this.id,
    fileName: fileName ?? this.fileName,
    previewLabel: previewLabel ?? this.previewLabel,
    format: format ?? this.format,
    takenAt: takenAt ?? this.takenAt,
    placeCountryCode: placeCountryCode ?? this.placeCountryCode,
    placeCountryName: placeCountryName ?? this.placeCountryName,
    placeCityName: placeCityName ?? this.placeCityName,
    placeLatitude: placeLatitude.present
        ? placeLatitude.value
        : this.placeLatitude,
    placeLongitude: placeLongitude.present
        ? placeLongitude.value
        : this.placeLongitude,
    uploadState: uploadState ?? this.uploadState,
    localPath: localPath.present ? localPath.value : this.localPath,
    storagePath: storagePath.present ? storagePath.value : this.storagePath,
    byteSize: byteSize.present ? byteSize.value : this.byteSize,
  );
  DbPhotoAsset copyWithCompanion(PhotoAssetsCompanion data) {
    return DbPhotoAsset(
      id: data.id.present ? data.id.value : this.id,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      previewLabel: data.previewLabel.present
          ? data.previewLabel.value
          : this.previewLabel,
      format: data.format.present ? data.format.value : this.format,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      placeCountryCode: data.placeCountryCode.present
          ? data.placeCountryCode.value
          : this.placeCountryCode,
      placeCountryName: data.placeCountryName.present
          ? data.placeCountryName.value
          : this.placeCountryName,
      placeCityName: data.placeCityName.present
          ? data.placeCityName.value
          : this.placeCityName,
      placeLatitude: data.placeLatitude.present
          ? data.placeLatitude.value
          : this.placeLatitude,
      placeLongitude: data.placeLongitude.present
          ? data.placeLongitude.value
          : this.placeLongitude,
      uploadState: data.uploadState.present
          ? data.uploadState.value
          : this.uploadState,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      storagePath: data.storagePath.present
          ? data.storagePath.value
          : this.storagePath,
      byteSize: data.byteSize.present ? data.byteSize.value : this.byteSize,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbPhotoAsset(')
          ..write('id: $id, ')
          ..write('fileName: $fileName, ')
          ..write('previewLabel: $previewLabel, ')
          ..write('format: $format, ')
          ..write('takenAt: $takenAt, ')
          ..write('placeCountryCode: $placeCountryCode, ')
          ..write('placeCountryName: $placeCountryName, ')
          ..write('placeCityName: $placeCityName, ')
          ..write('placeLatitude: $placeLatitude, ')
          ..write('placeLongitude: $placeLongitude, ')
          ..write('uploadState: $uploadState, ')
          ..write('localPath: $localPath, ')
          ..write('storagePath: $storagePath, ')
          ..write('byteSize: $byteSize')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fileName,
    previewLabel,
    format,
    takenAt,
    placeCountryCode,
    placeCountryName,
    placeCityName,
    placeLatitude,
    placeLongitude,
    uploadState,
    localPath,
    storagePath,
    byteSize,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbPhotoAsset &&
          other.id == this.id &&
          other.fileName == this.fileName &&
          other.previewLabel == this.previewLabel &&
          other.format == this.format &&
          other.takenAt == this.takenAt &&
          other.placeCountryCode == this.placeCountryCode &&
          other.placeCountryName == this.placeCountryName &&
          other.placeCityName == this.placeCityName &&
          other.placeLatitude == this.placeLatitude &&
          other.placeLongitude == this.placeLongitude &&
          other.uploadState == this.uploadState &&
          other.localPath == this.localPath &&
          other.storagePath == this.storagePath &&
          other.byteSize == this.byteSize);
}

class PhotoAssetsCompanion extends UpdateCompanion<DbPhotoAsset> {
  final Value<String> id;
  final Value<String> fileName;
  final Value<String> previewLabel;
  final Value<String> format;
  final Value<DateTime> takenAt;
  final Value<String> placeCountryCode;
  final Value<String> placeCountryName;
  final Value<String> placeCityName;
  final Value<double?> placeLatitude;
  final Value<double?> placeLongitude;
  final Value<String> uploadState;
  final Value<String?> localPath;
  final Value<String?> storagePath;
  final Value<int?> byteSize;
  final Value<int> rowid;
  const PhotoAssetsCompanion({
    this.id = const Value.absent(),
    this.fileName = const Value.absent(),
    this.previewLabel = const Value.absent(),
    this.format = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.placeCountryCode = const Value.absent(),
    this.placeCountryName = const Value.absent(),
    this.placeCityName = const Value.absent(),
    this.placeLatitude = const Value.absent(),
    this.placeLongitude = const Value.absent(),
    this.uploadState = const Value.absent(),
    this.localPath = const Value.absent(),
    this.storagePath = const Value.absent(),
    this.byteSize = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotoAssetsCompanion.insert({
    required String id,
    required String fileName,
    required String previewLabel,
    required String format,
    required DateTime takenAt,
    required String placeCountryCode,
    required String placeCountryName,
    required String placeCityName,
    this.placeLatitude = const Value.absent(),
    this.placeLongitude = const Value.absent(),
    required String uploadState,
    this.localPath = const Value.absent(),
    this.storagePath = const Value.absent(),
    this.byteSize = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fileName = Value(fileName),
       previewLabel = Value(previewLabel),
       format = Value(format),
       takenAt = Value(takenAt),
       placeCountryCode = Value(placeCountryCode),
       placeCountryName = Value(placeCountryName),
       placeCityName = Value(placeCityName),
       uploadState = Value(uploadState);
  static Insertable<DbPhotoAsset> custom({
    Expression<String>? id,
    Expression<String>? fileName,
    Expression<String>? previewLabel,
    Expression<String>? format,
    Expression<DateTime>? takenAt,
    Expression<String>? placeCountryCode,
    Expression<String>? placeCountryName,
    Expression<String>? placeCityName,
    Expression<double>? placeLatitude,
    Expression<double>? placeLongitude,
    Expression<String>? uploadState,
    Expression<String>? localPath,
    Expression<String>? storagePath,
    Expression<int>? byteSize,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fileName != null) 'file_name': fileName,
      if (previewLabel != null) 'preview_label': previewLabel,
      if (format != null) 'format': format,
      if (takenAt != null) 'taken_at': takenAt,
      if (placeCountryCode != null) 'place_country_code': placeCountryCode,
      if (placeCountryName != null) 'place_country_name': placeCountryName,
      if (placeCityName != null) 'place_city_name': placeCityName,
      if (placeLatitude != null) 'place_latitude': placeLatitude,
      if (placeLongitude != null) 'place_longitude': placeLongitude,
      if (uploadState != null) 'upload_state': uploadState,
      if (localPath != null) 'local_path': localPath,
      if (storagePath != null) 'storage_path': storagePath,
      if (byteSize != null) 'byte_size': byteSize,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotoAssetsCompanion copyWith({
    Value<String>? id,
    Value<String>? fileName,
    Value<String>? previewLabel,
    Value<String>? format,
    Value<DateTime>? takenAt,
    Value<String>? placeCountryCode,
    Value<String>? placeCountryName,
    Value<String>? placeCityName,
    Value<double?>? placeLatitude,
    Value<double?>? placeLongitude,
    Value<String>? uploadState,
    Value<String?>? localPath,
    Value<String?>? storagePath,
    Value<int?>? byteSize,
    Value<int>? rowid,
  }) {
    return PhotoAssetsCompanion(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      previewLabel: previewLabel ?? this.previewLabel,
      format: format ?? this.format,
      takenAt: takenAt ?? this.takenAt,
      placeCountryCode: placeCountryCode ?? this.placeCountryCode,
      placeCountryName: placeCountryName ?? this.placeCountryName,
      placeCityName: placeCityName ?? this.placeCityName,
      placeLatitude: placeLatitude ?? this.placeLatitude,
      placeLongitude: placeLongitude ?? this.placeLongitude,
      uploadState: uploadState ?? this.uploadState,
      localPath: localPath ?? this.localPath,
      storagePath: storagePath ?? this.storagePath,
      byteSize: byteSize ?? this.byteSize,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (previewLabel.present) {
      map['preview_label'] = Variable<String>(previewLabel.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (placeCountryCode.present) {
      map['place_country_code'] = Variable<String>(placeCountryCode.value);
    }
    if (placeCountryName.present) {
      map['place_country_name'] = Variable<String>(placeCountryName.value);
    }
    if (placeCityName.present) {
      map['place_city_name'] = Variable<String>(placeCityName.value);
    }
    if (placeLatitude.present) {
      map['place_latitude'] = Variable<double>(placeLatitude.value);
    }
    if (placeLongitude.present) {
      map['place_longitude'] = Variable<double>(placeLongitude.value);
    }
    if (uploadState.present) {
      map['upload_state'] = Variable<String>(uploadState.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (storagePath.present) {
      map['storage_path'] = Variable<String>(storagePath.value);
    }
    if (byteSize.present) {
      map['byte_size'] = Variable<int>(byteSize.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotoAssetsCompanion(')
          ..write('id: $id, ')
          ..write('fileName: $fileName, ')
          ..write('previewLabel: $previewLabel, ')
          ..write('format: $format, ')
          ..write('takenAt: $takenAt, ')
          ..write('placeCountryCode: $placeCountryCode, ')
          ..write('placeCountryName: $placeCountryName, ')
          ..write('placeCityName: $placeCityName, ')
          ..write('placeLatitude: $placeLatitude, ')
          ..write('placeLongitude: $placeLongitude, ')
          ..write('uploadState: $uploadState, ')
          ..write('localPath: $localPath, ')
          ..write('storagePath: $storagePath, ')
          ..write('byteSize: $byteSize, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxMutationsTable extends OutboxMutations
    with TableInfo<$OutboxMutationsTable, DbOutboxMutation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxMutationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    operation,
    entityId,
    status,
    attemptCount,
    lastError,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_mutations';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbOutboxMutation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attemptCountMeta);
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbOutboxMutation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbOutboxMutation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $OutboxMutationsTable createAlias(String alias) {
    return $OutboxMutationsTable(attachedDatabase, alias);
  }
}

class DbOutboxMutation extends DataClass
    implements Insertable<DbOutboxMutation> {
  final String id;
  final String operation;
  final String entityId;
  final String status;
  final int attemptCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DbOutboxMutation({
    required this.id,
    required this.operation,
    required this.entityId,
    required this.status,
    required this.attemptCount,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['operation'] = Variable<String>(operation);
    map['entity_id'] = Variable<String>(entityId);
    map['status'] = Variable<String>(status);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  OutboxMutationsCompanion toCompanion(bool nullToAbsent) {
    return OutboxMutationsCompanion(
      id: Value(id),
      operation: Value(operation),
      entityId: Value(entityId),
      status: Value(status),
      attemptCount: Value(attemptCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DbOutboxMutation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbOutboxMutation(
      id: serializer.fromJson<String>(json['id']),
      operation: serializer.fromJson<String>(json['operation']),
      entityId: serializer.fromJson<String>(json['entityId']),
      status: serializer.fromJson<String>(json['status']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'operation': serializer.toJson<String>(operation),
      'entityId': serializer.toJson<String>(entityId),
      'status': serializer.toJson<String>(status),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DbOutboxMutation copyWith({
    String? id,
    String? operation,
    String? entityId,
    String? status,
    int? attemptCount,
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DbOutboxMutation(
    id: id ?? this.id,
    operation: operation ?? this.operation,
    entityId: entityId ?? this.entityId,
    status: status ?? this.status,
    attemptCount: attemptCount ?? this.attemptCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DbOutboxMutation copyWithCompanion(OutboxMutationsCompanion data) {
    return DbOutboxMutation(
      id: data.id.present ? data.id.value : this.id,
      operation: data.operation.present ? data.operation.value : this.operation,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      status: data.status.present ? data.status.value : this.status,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbOutboxMutation(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('entityId: $entityId, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    operation,
    entityId,
    status,
    attemptCount,
    lastError,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbOutboxMutation &&
          other.id == this.id &&
          other.operation == this.operation &&
          other.entityId == this.entityId &&
          other.status == this.status &&
          other.attemptCount == this.attemptCount &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class OutboxMutationsCompanion extends UpdateCompanion<DbOutboxMutation> {
  final Value<String> id;
  final Value<String> operation;
  final Value<String> entityId;
  final Value<String> status;
  final Value<int> attemptCount;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const OutboxMutationsCompanion({
    this.id = const Value.absent(),
    this.operation = const Value.absent(),
    this.entityId = const Value.absent(),
    this.status = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxMutationsCompanion.insert({
    required String id,
    required String operation,
    required String entityId,
    required String status,
    required int attemptCount,
    this.lastError = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       operation = Value(operation),
       entityId = Value(entityId),
       status = Value(status),
       attemptCount = Value(attemptCount),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DbOutboxMutation> custom({
    Expression<String>? id,
    Expression<String>? operation,
    Expression<String>? entityId,
    Expression<String>? status,
    Expression<int>? attemptCount,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operation != null) 'operation': operation,
      if (entityId != null) 'entity_id': entityId,
      if (status != null) 'status': status,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxMutationsCompanion copyWith({
    Value<String>? id,
    Value<String>? operation,
    Value<String>? entityId,
    Value<String>? status,
    Value<int>? attemptCount,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return OutboxMutationsCompanion(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      entityId: entityId ?? this.entityId,
      status: status ?? this.status,
      attemptCount: attemptCount ?? this.attemptCount,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxMutationsCompanion(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('entityId: $entityId, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingMediaUploadsTable extends PendingMediaUploads
    with TableInfo<$PendingMediaUploadsTable, DbPendingMediaUpload> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingMediaUploadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoIdMeta = const VerificationMeta(
    'photoId',
  );
  @override
  late final GeneratedColumn<String> photoId = GeneratedColumn<String>(
    'photo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES photo_assets (id)',
    ),
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storageBucketMeta = const VerificationMeta(
    'storageBucket',
  );
  @override
  late final GeneratedColumn<String> storageBucket = GeneratedColumn<String>(
    'storage_bucket',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storagePathMeta = const VerificationMeta(
    'storagePath',
  );
  @override
  late final GeneratedColumn<String> storagePath = GeneratedColumn<String>(
    'storage_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    photoId,
    localPath,
    fileName,
    storageBucket,
    storagePath,
    status,
    attemptCount,
    lastError,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_media_uploads';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbPendingMediaUpload> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('photo_id')) {
      context.handle(
        _photoIdMeta,
        photoId.isAcceptableOrUnknown(data['photo_id']!, _photoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_photoIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('storage_bucket')) {
      context.handle(
        _storageBucketMeta,
        storageBucket.isAcceptableOrUnknown(
          data['storage_bucket']!,
          _storageBucketMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storageBucketMeta);
    }
    if (data.containsKey('storage_path')) {
      context.handle(
        _storagePathMeta,
        storagePath.isAcceptableOrUnknown(
          data['storage_path']!,
          _storagePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storagePathMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attemptCountMeta);
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbPendingMediaUpload map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbPendingMediaUpload(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      photoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_id'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      storageBucket: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_bucket'],
      )!,
      storagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_path'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PendingMediaUploadsTable createAlias(String alias) {
    return $PendingMediaUploadsTable(attachedDatabase, alias);
  }
}

class DbPendingMediaUpload extends DataClass
    implements Insertable<DbPendingMediaUpload> {
  final String id;
  final String photoId;
  final String localPath;
  final String fileName;
  final String storageBucket;
  final String storagePath;
  final String status;
  final int attemptCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DbPendingMediaUpload({
    required this.id,
    required this.photoId,
    required this.localPath,
    required this.fileName,
    required this.storageBucket,
    required this.storagePath,
    required this.status,
    required this.attemptCount,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['photo_id'] = Variable<String>(photoId);
    map['local_path'] = Variable<String>(localPath);
    map['file_name'] = Variable<String>(fileName);
    map['storage_bucket'] = Variable<String>(storageBucket);
    map['storage_path'] = Variable<String>(storagePath);
    map['status'] = Variable<String>(status);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PendingMediaUploadsCompanion toCompanion(bool nullToAbsent) {
    return PendingMediaUploadsCompanion(
      id: Value(id),
      photoId: Value(photoId),
      localPath: Value(localPath),
      fileName: Value(fileName),
      storageBucket: Value(storageBucket),
      storagePath: Value(storagePath),
      status: Value(status),
      attemptCount: Value(attemptCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DbPendingMediaUpload.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbPendingMediaUpload(
      id: serializer.fromJson<String>(json['id']),
      photoId: serializer.fromJson<String>(json['photoId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      fileName: serializer.fromJson<String>(json['fileName']),
      storageBucket: serializer.fromJson<String>(json['storageBucket']),
      storagePath: serializer.fromJson<String>(json['storagePath']),
      status: serializer.fromJson<String>(json['status']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'photoId': serializer.toJson<String>(photoId),
      'localPath': serializer.toJson<String>(localPath),
      'fileName': serializer.toJson<String>(fileName),
      'storageBucket': serializer.toJson<String>(storageBucket),
      'storagePath': serializer.toJson<String>(storagePath),
      'status': serializer.toJson<String>(status),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DbPendingMediaUpload copyWith({
    String? id,
    String? photoId,
    String? localPath,
    String? fileName,
    String? storageBucket,
    String? storagePath,
    String? status,
    int? attemptCount,
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DbPendingMediaUpload(
    id: id ?? this.id,
    photoId: photoId ?? this.photoId,
    localPath: localPath ?? this.localPath,
    fileName: fileName ?? this.fileName,
    storageBucket: storageBucket ?? this.storageBucket,
    storagePath: storagePath ?? this.storagePath,
    status: status ?? this.status,
    attemptCount: attemptCount ?? this.attemptCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DbPendingMediaUpload copyWithCompanion(PendingMediaUploadsCompanion data) {
    return DbPendingMediaUpload(
      id: data.id.present ? data.id.value : this.id,
      photoId: data.photoId.present ? data.photoId.value : this.photoId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      storageBucket: data.storageBucket.present
          ? data.storageBucket.value
          : this.storageBucket,
      storagePath: data.storagePath.present
          ? data.storagePath.value
          : this.storagePath,
      status: data.status.present ? data.status.value : this.status,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbPendingMediaUpload(')
          ..write('id: $id, ')
          ..write('photoId: $photoId, ')
          ..write('localPath: $localPath, ')
          ..write('fileName: $fileName, ')
          ..write('storageBucket: $storageBucket, ')
          ..write('storagePath: $storagePath, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    photoId,
    localPath,
    fileName,
    storageBucket,
    storagePath,
    status,
    attemptCount,
    lastError,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbPendingMediaUpload &&
          other.id == this.id &&
          other.photoId == this.photoId &&
          other.localPath == this.localPath &&
          other.fileName == this.fileName &&
          other.storageBucket == this.storageBucket &&
          other.storagePath == this.storagePath &&
          other.status == this.status &&
          other.attemptCount == this.attemptCount &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PendingMediaUploadsCompanion
    extends UpdateCompanion<DbPendingMediaUpload> {
  final Value<String> id;
  final Value<String> photoId;
  final Value<String> localPath;
  final Value<String> fileName;
  final Value<String> storageBucket;
  final Value<String> storagePath;
  final Value<String> status;
  final Value<int> attemptCount;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PendingMediaUploadsCompanion({
    this.id = const Value.absent(),
    this.photoId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.fileName = const Value.absent(),
    this.storageBucket = const Value.absent(),
    this.storagePath = const Value.absent(),
    this.status = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingMediaUploadsCompanion.insert({
    required String id,
    required String photoId,
    required String localPath,
    required String fileName,
    required String storageBucket,
    required String storagePath,
    required String status,
    required int attemptCount,
    this.lastError = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       photoId = Value(photoId),
       localPath = Value(localPath),
       fileName = Value(fileName),
       storageBucket = Value(storageBucket),
       storagePath = Value(storagePath),
       status = Value(status),
       attemptCount = Value(attemptCount),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DbPendingMediaUpload> custom({
    Expression<String>? id,
    Expression<String>? photoId,
    Expression<String>? localPath,
    Expression<String>? fileName,
    Expression<String>? storageBucket,
    Expression<String>? storagePath,
    Expression<String>? status,
    Expression<int>? attemptCount,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (photoId != null) 'photo_id': photoId,
      if (localPath != null) 'local_path': localPath,
      if (fileName != null) 'file_name': fileName,
      if (storageBucket != null) 'storage_bucket': storageBucket,
      if (storagePath != null) 'storage_path': storagePath,
      if (status != null) 'status': status,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingMediaUploadsCompanion copyWith({
    Value<String>? id,
    Value<String>? photoId,
    Value<String>? localPath,
    Value<String>? fileName,
    Value<String>? storageBucket,
    Value<String>? storagePath,
    Value<String>? status,
    Value<int>? attemptCount,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PendingMediaUploadsCompanion(
      id: id ?? this.id,
      photoId: photoId ?? this.photoId,
      localPath: localPath ?? this.localPath,
      fileName: fileName ?? this.fileName,
      storageBucket: storageBucket ?? this.storageBucket,
      storagePath: storagePath ?? this.storagePath,
      status: status ?? this.status,
      attemptCount: attemptCount ?? this.attemptCount,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (photoId.present) {
      map['photo_id'] = Variable<String>(photoId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (storageBucket.present) {
      map['storage_bucket'] = Variable<String>(storageBucket.value);
    }
    if (storagePath.present) {
      map['storage_path'] = Variable<String>(storagePath.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingMediaUploadsCompanion(')
          ..write('id: $id, ')
          ..write('photoId: $photoId, ')
          ..write('localPath: $localPath, ')
          ..write('fileName: $fileName, ')
          ..write('storageBucket: $storageBucket, ')
          ..write('storagePath: $storagePath, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStatesTable extends SyncStates
    with TableInfo<$SyncStatesTable, DbSyncState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bannerTitleMeta = const VerificationMeta(
    'bannerTitle',
  );
  @override
  late final GeneratedColumn<String> bannerTitle = GeneratedColumn<String>(
    'banner_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bannerMessageMeta = const VerificationMeta(
    'bannerMessage',
  );
  @override
  late final GeneratedColumn<String> bannerMessage = GeneratedColumn<String>(
    'banner_message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pendingChangesMeta = const VerificationMeta(
    'pendingChanges',
  );
  @override
  late final GeneratedColumn<int> pendingChanges = GeneratedColumn<int>(
    'pending_changes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pendingUploadsMeta = const VerificationMeta(
    'pendingUploads',
  );
  @override
  late final GeneratedColumn<int> pendingUploads = GeneratedColumn<int>(
    'pending_uploads',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    severity,
    bannerTitle,
    bannerMessage,
    pendingChanges,
    pendingUploads,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbSyncState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('banner_title')) {
      context.handle(
        _bannerTitleMeta,
        bannerTitle.isAcceptableOrUnknown(
          data['banner_title']!,
          _bannerTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bannerTitleMeta);
    }
    if (data.containsKey('banner_message')) {
      context.handle(
        _bannerMessageMeta,
        bannerMessage.isAcceptableOrUnknown(
          data['banner_message']!,
          _bannerMessageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bannerMessageMeta);
    }
    if (data.containsKey('pending_changes')) {
      context.handle(
        _pendingChangesMeta,
        pendingChanges.isAcceptableOrUnknown(
          data['pending_changes']!,
          _pendingChangesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pendingChangesMeta);
    }
    if (data.containsKey('pending_uploads')) {
      context.handle(
        _pendingUploadsMeta,
        pendingUploads.isAcceptableOrUnknown(
          data['pending_uploads']!,
          _pendingUploadsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pendingUploadsMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbSyncState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbSyncState(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      bannerTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}banner_title'],
      )!,
      bannerMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}banner_message'],
      )!,
      pendingChanges: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pending_changes'],
      )!,
      pendingUploads: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pending_uploads'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $SyncStatesTable createAlias(String alias) {
    return $SyncStatesTable(attachedDatabase, alias);
  }
}

class DbSyncState extends DataClass implements Insertable<DbSyncState> {
  final int id;
  final String severity;
  final String bannerTitle;
  final String bannerMessage;
  final int pendingChanges;
  final int pendingUploads;
  final DateTime? lastSyncedAt;
  const DbSyncState({
    required this.id,
    required this.severity,
    required this.bannerTitle,
    required this.bannerMessage,
    required this.pendingChanges,
    required this.pendingUploads,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['severity'] = Variable<String>(severity);
    map['banner_title'] = Variable<String>(bannerTitle);
    map['banner_message'] = Variable<String>(bannerMessage);
    map['pending_changes'] = Variable<int>(pendingChanges);
    map['pending_uploads'] = Variable<int>(pendingUploads);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  SyncStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncStatesCompanion(
      id: Value(id),
      severity: Value(severity),
      bannerTitle: Value(bannerTitle),
      bannerMessage: Value(bannerMessage),
      pendingChanges: Value(pendingChanges),
      pendingUploads: Value(pendingUploads),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory DbSyncState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbSyncState(
      id: serializer.fromJson<int>(json['id']),
      severity: serializer.fromJson<String>(json['severity']),
      bannerTitle: serializer.fromJson<String>(json['bannerTitle']),
      bannerMessage: serializer.fromJson<String>(json['bannerMessage']),
      pendingChanges: serializer.fromJson<int>(json['pendingChanges']),
      pendingUploads: serializer.fromJson<int>(json['pendingUploads']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'severity': serializer.toJson<String>(severity),
      'bannerTitle': serializer.toJson<String>(bannerTitle),
      'bannerMessage': serializer.toJson<String>(bannerMessage),
      'pendingChanges': serializer.toJson<int>(pendingChanges),
      'pendingUploads': serializer.toJson<int>(pendingUploads),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  DbSyncState copyWith({
    int? id,
    String? severity,
    String? bannerTitle,
    String? bannerMessage,
    int? pendingChanges,
    int? pendingUploads,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => DbSyncState(
    id: id ?? this.id,
    severity: severity ?? this.severity,
    bannerTitle: bannerTitle ?? this.bannerTitle,
    bannerMessage: bannerMessage ?? this.bannerMessage,
    pendingChanges: pendingChanges ?? this.pendingChanges,
    pendingUploads: pendingUploads ?? this.pendingUploads,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  DbSyncState copyWithCompanion(SyncStatesCompanion data) {
    return DbSyncState(
      id: data.id.present ? data.id.value : this.id,
      severity: data.severity.present ? data.severity.value : this.severity,
      bannerTitle: data.bannerTitle.present
          ? data.bannerTitle.value
          : this.bannerTitle,
      bannerMessage: data.bannerMessage.present
          ? data.bannerMessage.value
          : this.bannerMessage,
      pendingChanges: data.pendingChanges.present
          ? data.pendingChanges.value
          : this.pendingChanges,
      pendingUploads: data.pendingUploads.present
          ? data.pendingUploads.value
          : this.pendingUploads,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbSyncState(')
          ..write('id: $id, ')
          ..write('severity: $severity, ')
          ..write('bannerTitle: $bannerTitle, ')
          ..write('bannerMessage: $bannerMessage, ')
          ..write('pendingChanges: $pendingChanges, ')
          ..write('pendingUploads: $pendingUploads, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    severity,
    bannerTitle,
    bannerMessage,
    pendingChanges,
    pendingUploads,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbSyncState &&
          other.id == this.id &&
          other.severity == this.severity &&
          other.bannerTitle == this.bannerTitle &&
          other.bannerMessage == this.bannerMessage &&
          other.pendingChanges == this.pendingChanges &&
          other.pendingUploads == this.pendingUploads &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class SyncStatesCompanion extends UpdateCompanion<DbSyncState> {
  final Value<int> id;
  final Value<String> severity;
  final Value<String> bannerTitle;
  final Value<String> bannerMessage;
  final Value<int> pendingChanges;
  final Value<int> pendingUploads;
  final Value<DateTime?> lastSyncedAt;
  const SyncStatesCompanion({
    this.id = const Value.absent(),
    this.severity = const Value.absent(),
    this.bannerTitle = const Value.absent(),
    this.bannerMessage = const Value.absent(),
    this.pendingChanges = const Value.absent(),
    this.pendingUploads = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  SyncStatesCompanion.insert({
    this.id = const Value.absent(),
    required String severity,
    required String bannerTitle,
    required String bannerMessage,
    required int pendingChanges,
    required int pendingUploads,
    this.lastSyncedAt = const Value.absent(),
  }) : severity = Value(severity),
       bannerTitle = Value(bannerTitle),
       bannerMessage = Value(bannerMessage),
       pendingChanges = Value(pendingChanges),
       pendingUploads = Value(pendingUploads);
  static Insertable<DbSyncState> custom({
    Expression<int>? id,
    Expression<String>? severity,
    Expression<String>? bannerTitle,
    Expression<String>? bannerMessage,
    Expression<int>? pendingChanges,
    Expression<int>? pendingUploads,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (severity != null) 'severity': severity,
      if (bannerTitle != null) 'banner_title': bannerTitle,
      if (bannerMessage != null) 'banner_message': bannerMessage,
      if (pendingChanges != null) 'pending_changes': pendingChanges,
      if (pendingUploads != null) 'pending_uploads': pendingUploads,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  SyncStatesCompanion copyWith({
    Value<int>? id,
    Value<String>? severity,
    Value<String>? bannerTitle,
    Value<String>? bannerMessage,
    Value<int>? pendingChanges,
    Value<int>? pendingUploads,
    Value<DateTime?>? lastSyncedAt,
  }) {
    return SyncStatesCompanion(
      id: id ?? this.id,
      severity: severity ?? this.severity,
      bannerTitle: bannerTitle ?? this.bannerTitle,
      bannerMessage: bannerMessage ?? this.bannerMessage,
      pendingChanges: pendingChanges ?? this.pendingChanges,
      pendingUploads: pendingUploads ?? this.pendingUploads,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (bannerTitle.present) {
      map['banner_title'] = Variable<String>(bannerTitle.value);
    }
    if (bannerMessage.present) {
      map['banner_message'] = Variable<String>(bannerMessage.value);
    }
    if (pendingChanges.present) {
      map['pending_changes'] = Variable<int>(pendingChanges.value);
    }
    if (pendingUploads.present) {
      map['pending_uploads'] = Variable<int>(pendingUploads.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStatesCompanion(')
          ..write('id: $id, ')
          ..write('severity: $severity, ')
          ..write('bannerTitle: $bannerTitle, ')
          ..write('bannerMessage: $bannerMessage, ')
          ..write('pendingChanges: $pendingChanges, ')
          ..write('pendingUploads: $pendingUploads, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$TravelAtlasDatabase extends GeneratedDatabase {
  _$TravelAtlasDatabase(QueryExecutor e) : super(e);
  $TravelAtlasDatabaseManager get managers => $TravelAtlasDatabaseManager(this);
  late final $TripsTable trips = $TripsTable(this);
  late final $JournalEntriesTable journalEntries = $JournalEntriesTable(this);
  late final $PhotoAssetsTable photoAssets = $PhotoAssetsTable(this);
  late final $OutboxMutationsTable outboxMutations = $OutboxMutationsTable(
    this,
  );
  late final $PendingMediaUploadsTable pendingMediaUploads =
      $PendingMediaUploadsTable(this);
  late final $SyncStatesTable syncStates = $SyncStatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    trips,
    journalEntries,
    photoAssets,
    outboxMutations,
    pendingMediaUploads,
    syncStates,
  ];
}

typedef $$TripsTableCreateCompanionBuilder =
    TripsCompanion Function({
      required String id,
      required String title,
      required String subtitle,
      required DateTime startDate,
      required DateTime endDate,
      required String heroCountryCode,
      required String heroCountryName,
      required String heroCityName,
      Value<double?> heroLatitude,
      Value<double?> heroLongitude,
      required String coverHint,
      required int memoryCount,
      required int photoCount,
      required int countryCount,
      Value<int> rowid,
    });
typedef $$TripsTableUpdateCompanionBuilder =
    TripsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> subtitle,
      Value<DateTime> startDate,
      Value<DateTime> endDate,
      Value<String> heroCountryCode,
      Value<String> heroCountryName,
      Value<String> heroCityName,
      Value<double?> heroLatitude,
      Value<double?> heroLongitude,
      Value<String> coverHint,
      Value<int> memoryCount,
      Value<int> photoCount,
      Value<int> countryCount,
      Value<int> rowid,
    });

final class $$TripsTableReferences
    extends BaseReferences<_$TravelAtlasDatabase, $TripsTable, DbTrip> {
  $$TripsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$JournalEntriesTable, List<DbJournalEntry>>
  _journalEntriesRefsTable(_$TravelAtlasDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.journalEntries,
        aliasName: $_aliasNameGenerator(db.trips.id, db.journalEntries.tripId),
      );

  $$JournalEntriesTableProcessedTableManager get journalEntriesRefs {
    final manager = $$JournalEntriesTableTableManager(
      $_db,
      $_db.journalEntries,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_journalEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TripsTableFilterComposer
    extends Composer<_$TravelAtlasDatabase, $TripsTable> {
  $$TripsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get heroCountryCode => $composableBuilder(
    column: $table.heroCountryCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get heroCountryName => $composableBuilder(
    column: $table.heroCountryName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get heroCityName => $composableBuilder(
    column: $table.heroCityName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heroLatitude => $composableBuilder(
    column: $table.heroLatitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heroLongitude => $composableBuilder(
    column: $table.heroLongitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverHint => $composableBuilder(
    column: $table.coverHint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get memoryCount => $composableBuilder(
    column: $table.memoryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get photoCount => $composableBuilder(
    column: $table.photoCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get countryCount => $composableBuilder(
    column: $table.countryCount,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> journalEntriesRefs(
    Expression<bool> Function($$JournalEntriesTableFilterComposer f) f,
  ) {
    final $$JournalEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.journalEntries,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalEntriesTableFilterComposer(
            $db: $db,
            $table: $db.journalEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripsTableOrderingComposer
    extends Composer<_$TravelAtlasDatabase, $TripsTable> {
  $$TripsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get heroCountryCode => $composableBuilder(
    column: $table.heroCountryCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get heroCountryName => $composableBuilder(
    column: $table.heroCountryName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get heroCityName => $composableBuilder(
    column: $table.heroCityName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heroLatitude => $composableBuilder(
    column: $table.heroLatitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heroLongitude => $composableBuilder(
    column: $table.heroLongitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverHint => $composableBuilder(
    column: $table.coverHint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get memoryCount => $composableBuilder(
    column: $table.memoryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get photoCount => $composableBuilder(
    column: $table.photoCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get countryCount => $composableBuilder(
    column: $table.countryCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripsTableAnnotationComposer
    extends Composer<_$TravelAtlasDatabase, $TripsTable> {
  $$TripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get heroCountryCode => $composableBuilder(
    column: $table.heroCountryCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get heroCountryName => $composableBuilder(
    column: $table.heroCountryName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get heroCityName => $composableBuilder(
    column: $table.heroCityName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get heroLatitude => $composableBuilder(
    column: $table.heroLatitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get heroLongitude => $composableBuilder(
    column: $table.heroLongitude,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverHint =>
      $composableBuilder(column: $table.coverHint, builder: (column) => column);

  GeneratedColumn<int> get memoryCount => $composableBuilder(
    column: $table.memoryCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get photoCount => $composableBuilder(
    column: $table.photoCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get countryCount => $composableBuilder(
    column: $table.countryCount,
    builder: (column) => column,
  );

  Expression<T> journalEntriesRefs<T extends Object>(
    Expression<T> Function($$JournalEntriesTableAnnotationComposer a) f,
  ) {
    final $$JournalEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.journalEntries,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.journalEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripsTableTableManager
    extends
        RootTableManager<
          _$TravelAtlasDatabase,
          $TripsTable,
          DbTrip,
          $$TripsTableFilterComposer,
          $$TripsTableOrderingComposer,
          $$TripsTableAnnotationComposer,
          $$TripsTableCreateCompanionBuilder,
          $$TripsTableUpdateCompanionBuilder,
          (DbTrip, $$TripsTableReferences),
          DbTrip,
          PrefetchHooks Function({bool journalEntriesRefs})
        > {
  $$TripsTableTableManager(_$TravelAtlasDatabase db, $TripsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> subtitle = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> endDate = const Value.absent(),
                Value<String> heroCountryCode = const Value.absent(),
                Value<String> heroCountryName = const Value.absent(),
                Value<String> heroCityName = const Value.absent(),
                Value<double?> heroLatitude = const Value.absent(),
                Value<double?> heroLongitude = const Value.absent(),
                Value<String> coverHint = const Value.absent(),
                Value<int> memoryCount = const Value.absent(),
                Value<int> photoCount = const Value.absent(),
                Value<int> countryCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion(
                id: id,
                title: title,
                subtitle: subtitle,
                startDate: startDate,
                endDate: endDate,
                heroCountryCode: heroCountryCode,
                heroCountryName: heroCountryName,
                heroCityName: heroCityName,
                heroLatitude: heroLatitude,
                heroLongitude: heroLongitude,
                coverHint: coverHint,
                memoryCount: memoryCount,
                photoCount: photoCount,
                countryCount: countryCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String subtitle,
                required DateTime startDate,
                required DateTime endDate,
                required String heroCountryCode,
                required String heroCountryName,
                required String heroCityName,
                Value<double?> heroLatitude = const Value.absent(),
                Value<double?> heroLongitude = const Value.absent(),
                required String coverHint,
                required int memoryCount,
                required int photoCount,
                required int countryCount,
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion.insert(
                id: id,
                title: title,
                subtitle: subtitle,
                startDate: startDate,
                endDate: endDate,
                heroCountryCode: heroCountryCode,
                heroCountryName: heroCountryName,
                heroCityName: heroCityName,
                heroLatitude: heroLatitude,
                heroLongitude: heroLongitude,
                coverHint: coverHint,
                memoryCount: memoryCount,
                photoCount: photoCount,
                countryCount: countryCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TripsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({journalEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (journalEntriesRefs) db.journalEntries,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (journalEntriesRefs)
                    await $_getPrefetchedData<
                      DbTrip,
                      $TripsTable,
                      DbJournalEntry
                    >(
                      currentTable: table,
                      referencedTable: $$TripsTableReferences
                          ._journalEntriesRefsTable(db),
                      managerFromTypedResult: (p0) => $$TripsTableReferences(
                        db,
                        table,
                        p0,
                      ).journalEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tripId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TripsTableProcessedTableManager =
    ProcessedTableManager<
      _$TravelAtlasDatabase,
      $TripsTable,
      DbTrip,
      $$TripsTableFilterComposer,
      $$TripsTableOrderingComposer,
      $$TripsTableAnnotationComposer,
      $$TripsTableCreateCompanionBuilder,
      $$TripsTableUpdateCompanionBuilder,
      (DbTrip, $$TripsTableReferences),
      DbTrip,
      PrefetchHooks Function({bool journalEntriesRefs})
    >;
typedef $$JournalEntriesTableCreateCompanionBuilder =
    JournalEntriesCompanion Function({
      required String id,
      required String tripId,
      required String title,
      required String body,
      required DateTime recordedAt,
      required String placeCountryCode,
      required String placeCountryName,
      required String placeCityName,
      Value<double?> placeLatitude,
      Value<double?> placeLongitude,
      required String type,
      required List<String> photoAssetIds,
      required bool hasPendingUpload,
      Value<int> rowid,
    });
typedef $$JournalEntriesTableUpdateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<String> title,
      Value<String> body,
      Value<DateTime> recordedAt,
      Value<String> placeCountryCode,
      Value<String> placeCountryName,
      Value<String> placeCityName,
      Value<double?> placeLatitude,
      Value<double?> placeLongitude,
      Value<String> type,
      Value<List<String>> photoAssetIds,
      Value<bool> hasPendingUpload,
      Value<int> rowid,
    });

final class $$JournalEntriesTableReferences
    extends
        BaseReferences<
          _$TravelAtlasDatabase,
          $JournalEntriesTable,
          DbJournalEntry
        > {
  $$JournalEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TripsTable _tripIdTable(_$TravelAtlasDatabase db) => db.trips
      .createAlias($_aliasNameGenerator(db.journalEntries.tripId, db.trips.id));

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$JournalEntriesTableFilterComposer
    extends Composer<_$TravelAtlasDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placeCountryCode => $composableBuilder(
    column: $table.placeCountryCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placeCountryName => $composableBuilder(
    column: $table.placeCountryName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placeCityName => $composableBuilder(
    column: $table.placeCityName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get placeLatitude => $composableBuilder(
    column: $table.placeLatitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get placeLongitude => $composableBuilder(
    column: $table.placeLongitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get photoAssetIds => $composableBuilder(
    column: $table.photoAssetIds,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get hasPendingUpload => $composableBuilder(
    column: $table.hasPendingUpload,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JournalEntriesTableOrderingComposer
    extends Composer<_$TravelAtlasDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placeCountryCode => $composableBuilder(
    column: $table.placeCountryCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placeCountryName => $composableBuilder(
    column: $table.placeCountryName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placeCityName => $composableBuilder(
    column: $table.placeCityName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get placeLatitude => $composableBuilder(
    column: $table.placeLatitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get placeLongitude => $composableBuilder(
    column: $table.placeLongitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoAssetIds => $composableBuilder(
    column: $table.photoAssetIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasPendingUpload => $composableBuilder(
    column: $table.hasPendingUpload,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JournalEntriesTableAnnotationComposer
    extends Composer<_$TravelAtlasDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get placeCountryCode => $composableBuilder(
    column: $table.placeCountryCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get placeCountryName => $composableBuilder(
    column: $table.placeCountryName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get placeCityName => $composableBuilder(
    column: $table.placeCityName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get placeLatitude => $composableBuilder(
    column: $table.placeLatitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get placeLongitude => $composableBuilder(
    column: $table.placeLongitude,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get photoAssetIds =>
      $composableBuilder(
        column: $table.photoAssetIds,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get hasPendingUpload => $composableBuilder(
    column: $table.hasPendingUpload,
    builder: (column) => column,
  );

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JournalEntriesTableTableManager
    extends
        RootTableManager<
          _$TravelAtlasDatabase,
          $JournalEntriesTable,
          DbJournalEntry,
          $$JournalEntriesTableFilterComposer,
          $$JournalEntriesTableOrderingComposer,
          $$JournalEntriesTableAnnotationComposer,
          $$JournalEntriesTableCreateCompanionBuilder,
          $$JournalEntriesTableUpdateCompanionBuilder,
          (DbJournalEntry, $$JournalEntriesTableReferences),
          DbJournalEntry,
          PrefetchHooks Function({bool tripId})
        > {
  $$JournalEntriesTableTableManager(
    _$TravelAtlasDatabase db,
    $JournalEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<String> placeCountryCode = const Value.absent(),
                Value<String> placeCountryName = const Value.absent(),
                Value<String> placeCityName = const Value.absent(),
                Value<double?> placeLatitude = const Value.absent(),
                Value<double?> placeLongitude = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<List<String>> photoAssetIds = const Value.absent(),
                Value<bool> hasPendingUpload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion(
                id: id,
                tripId: tripId,
                title: title,
                body: body,
                recordedAt: recordedAt,
                placeCountryCode: placeCountryCode,
                placeCountryName: placeCountryName,
                placeCityName: placeCityName,
                placeLatitude: placeLatitude,
                placeLongitude: placeLongitude,
                type: type,
                photoAssetIds: photoAssetIds,
                hasPendingUpload: hasPendingUpload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required String title,
                required String body,
                required DateTime recordedAt,
                required String placeCountryCode,
                required String placeCountryName,
                required String placeCityName,
                Value<double?> placeLatitude = const Value.absent(),
                Value<double?> placeLongitude = const Value.absent(),
                required String type,
                required List<String> photoAssetIds,
                required bool hasPendingUpload,
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion.insert(
                id: id,
                tripId: tripId,
                title: title,
                body: body,
                recordedAt: recordedAt,
                placeCountryCode: placeCountryCode,
                placeCountryName: placeCountryName,
                placeCityName: placeCityName,
                placeLatitude: placeLatitude,
                placeLongitude: placeLongitude,
                type: type,
                photoAssetIds: photoAssetIds,
                hasPendingUpload: hasPendingUpload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$JournalEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tripId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tripId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tripId,
                                referencedTable: $$JournalEntriesTableReferences
                                    ._tripIdTable(db),
                                referencedColumn:
                                    $$JournalEntriesTableReferences
                                        ._tripIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$JournalEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$TravelAtlasDatabase,
      $JournalEntriesTable,
      DbJournalEntry,
      $$JournalEntriesTableFilterComposer,
      $$JournalEntriesTableOrderingComposer,
      $$JournalEntriesTableAnnotationComposer,
      $$JournalEntriesTableCreateCompanionBuilder,
      $$JournalEntriesTableUpdateCompanionBuilder,
      (DbJournalEntry, $$JournalEntriesTableReferences),
      DbJournalEntry,
      PrefetchHooks Function({bool tripId})
    >;
typedef $$PhotoAssetsTableCreateCompanionBuilder =
    PhotoAssetsCompanion Function({
      required String id,
      required String fileName,
      required String previewLabel,
      required String format,
      required DateTime takenAt,
      required String placeCountryCode,
      required String placeCountryName,
      required String placeCityName,
      Value<double?> placeLatitude,
      Value<double?> placeLongitude,
      required String uploadState,
      Value<String?> localPath,
      Value<String?> storagePath,
      Value<int?> byteSize,
      Value<int> rowid,
    });
typedef $$PhotoAssetsTableUpdateCompanionBuilder =
    PhotoAssetsCompanion Function({
      Value<String> id,
      Value<String> fileName,
      Value<String> previewLabel,
      Value<String> format,
      Value<DateTime> takenAt,
      Value<String> placeCountryCode,
      Value<String> placeCountryName,
      Value<String> placeCityName,
      Value<double?> placeLatitude,
      Value<double?> placeLongitude,
      Value<String> uploadState,
      Value<String?> localPath,
      Value<String?> storagePath,
      Value<int?> byteSize,
      Value<int> rowid,
    });

final class $$PhotoAssetsTableReferences
    extends
        BaseReferences<_$TravelAtlasDatabase, $PhotoAssetsTable, DbPhotoAsset> {
  $$PhotoAssetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $PendingMediaUploadsTable,
    List<DbPendingMediaUpload>
  >
  _pendingMediaUploadsRefsTable(_$TravelAtlasDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.pendingMediaUploads,
        aliasName: $_aliasNameGenerator(
          db.photoAssets.id,
          db.pendingMediaUploads.photoId,
        ),
      );

  $$PendingMediaUploadsTableProcessedTableManager get pendingMediaUploadsRefs {
    final manager = $$PendingMediaUploadsTableTableManager(
      $_db,
      $_db.pendingMediaUploads,
    ).filter((f) => f.photoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pendingMediaUploadsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PhotoAssetsTableFilterComposer
    extends Composer<_$TravelAtlasDatabase, $PhotoAssetsTable> {
  $$PhotoAssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previewLabel => $composableBuilder(
    column: $table.previewLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placeCountryCode => $composableBuilder(
    column: $table.placeCountryCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placeCountryName => $composableBuilder(
    column: $table.placeCountryName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placeCityName => $composableBuilder(
    column: $table.placeCityName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get placeLatitude => $composableBuilder(
    column: $table.placeLatitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get placeLongitude => $composableBuilder(
    column: $table.placeLongitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uploadState => $composableBuilder(
    column: $table.uploadState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> pendingMediaUploadsRefs(
    Expression<bool> Function($$PendingMediaUploadsTableFilterComposer f) f,
  ) {
    final $$PendingMediaUploadsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pendingMediaUploads,
      getReferencedColumn: (t) => t.photoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PendingMediaUploadsTableFilterComposer(
            $db: $db,
            $table: $db.pendingMediaUploads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PhotoAssetsTableOrderingComposer
    extends Composer<_$TravelAtlasDatabase, $PhotoAssetsTable> {
  $$PhotoAssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previewLabel => $composableBuilder(
    column: $table.previewLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placeCountryCode => $composableBuilder(
    column: $table.placeCountryCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placeCountryName => $composableBuilder(
    column: $table.placeCountryName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placeCityName => $composableBuilder(
    column: $table.placeCityName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get placeLatitude => $composableBuilder(
    column: $table.placeLatitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get placeLongitude => $composableBuilder(
    column: $table.placeLongitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uploadState => $composableBuilder(
    column: $table.uploadState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PhotoAssetsTableAnnotationComposer
    extends Composer<_$TravelAtlasDatabase, $PhotoAssetsTable> {
  $$PhotoAssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get previewLabel => $composableBuilder(
    column: $table.previewLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<String> get placeCountryCode => $composableBuilder(
    column: $table.placeCountryCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get placeCountryName => $composableBuilder(
    column: $table.placeCountryName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get placeCityName => $composableBuilder(
    column: $table.placeCityName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get placeLatitude => $composableBuilder(
    column: $table.placeLatitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get placeLongitude => $composableBuilder(
    column: $table.placeLongitude,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uploadState => $composableBuilder(
    column: $table.uploadState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get byteSize =>
      $composableBuilder(column: $table.byteSize, builder: (column) => column);

  Expression<T> pendingMediaUploadsRefs<T extends Object>(
    Expression<T> Function($$PendingMediaUploadsTableAnnotationComposer a) f,
  ) {
    final $$PendingMediaUploadsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.pendingMediaUploads,
          getReferencedColumn: (t) => t.photoId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PendingMediaUploadsTableAnnotationComposer(
                $db: $db,
                $table: $db.pendingMediaUploads,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PhotoAssetsTableTableManager
    extends
        RootTableManager<
          _$TravelAtlasDatabase,
          $PhotoAssetsTable,
          DbPhotoAsset,
          $$PhotoAssetsTableFilterComposer,
          $$PhotoAssetsTableOrderingComposer,
          $$PhotoAssetsTableAnnotationComposer,
          $$PhotoAssetsTableCreateCompanionBuilder,
          $$PhotoAssetsTableUpdateCompanionBuilder,
          (DbPhotoAsset, $$PhotoAssetsTableReferences),
          DbPhotoAsset,
          PrefetchHooks Function({bool pendingMediaUploadsRefs})
        > {
  $$PhotoAssetsTableTableManager(
    _$TravelAtlasDatabase db,
    $PhotoAssetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotoAssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotoAssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotoAssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> previewLabel = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<DateTime> takenAt = const Value.absent(),
                Value<String> placeCountryCode = const Value.absent(),
                Value<String> placeCountryName = const Value.absent(),
                Value<String> placeCityName = const Value.absent(),
                Value<double?> placeLatitude = const Value.absent(),
                Value<double?> placeLongitude = const Value.absent(),
                Value<String> uploadState = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String?> storagePath = const Value.absent(),
                Value<int?> byteSize = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotoAssetsCompanion(
                id: id,
                fileName: fileName,
                previewLabel: previewLabel,
                format: format,
                takenAt: takenAt,
                placeCountryCode: placeCountryCode,
                placeCountryName: placeCountryName,
                placeCityName: placeCityName,
                placeLatitude: placeLatitude,
                placeLongitude: placeLongitude,
                uploadState: uploadState,
                localPath: localPath,
                storagePath: storagePath,
                byteSize: byteSize,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fileName,
                required String previewLabel,
                required String format,
                required DateTime takenAt,
                required String placeCountryCode,
                required String placeCountryName,
                required String placeCityName,
                Value<double?> placeLatitude = const Value.absent(),
                Value<double?> placeLongitude = const Value.absent(),
                required String uploadState,
                Value<String?> localPath = const Value.absent(),
                Value<String?> storagePath = const Value.absent(),
                Value<int?> byteSize = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotoAssetsCompanion.insert(
                id: id,
                fileName: fileName,
                previewLabel: previewLabel,
                format: format,
                takenAt: takenAt,
                placeCountryCode: placeCountryCode,
                placeCountryName: placeCountryName,
                placeCityName: placeCityName,
                placeLatitude: placeLatitude,
                placeLongitude: placeLongitude,
                uploadState: uploadState,
                localPath: localPath,
                storagePath: storagePath,
                byteSize: byteSize,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PhotoAssetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pendingMediaUploadsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (pendingMediaUploadsRefs) db.pendingMediaUploads,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (pendingMediaUploadsRefs)
                    await $_getPrefetchedData<
                      DbPhotoAsset,
                      $PhotoAssetsTable,
                      DbPendingMediaUpload
                    >(
                      currentTable: table,
                      referencedTable: $$PhotoAssetsTableReferences
                          ._pendingMediaUploadsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PhotoAssetsTableReferences(
                            db,
                            table,
                            p0,
                          ).pendingMediaUploadsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.photoId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PhotoAssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$TravelAtlasDatabase,
      $PhotoAssetsTable,
      DbPhotoAsset,
      $$PhotoAssetsTableFilterComposer,
      $$PhotoAssetsTableOrderingComposer,
      $$PhotoAssetsTableAnnotationComposer,
      $$PhotoAssetsTableCreateCompanionBuilder,
      $$PhotoAssetsTableUpdateCompanionBuilder,
      (DbPhotoAsset, $$PhotoAssetsTableReferences),
      DbPhotoAsset,
      PrefetchHooks Function({bool pendingMediaUploadsRefs})
    >;
typedef $$OutboxMutationsTableCreateCompanionBuilder =
    OutboxMutationsCompanion Function({
      required String id,
      required String operation,
      required String entityId,
      required String status,
      required int attemptCount,
      Value<String?> lastError,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$OutboxMutationsTableUpdateCompanionBuilder =
    OutboxMutationsCompanion Function({
      Value<String> id,
      Value<String> operation,
      Value<String> entityId,
      Value<String> status,
      Value<int> attemptCount,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$OutboxMutationsTableFilterComposer
    extends Composer<_$TravelAtlasDatabase, $OutboxMutationsTable> {
  $$OutboxMutationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxMutationsTableOrderingComposer
    extends Composer<_$TravelAtlasDatabase, $OutboxMutationsTable> {
  $$OutboxMutationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxMutationsTableAnnotationComposer
    extends Composer<_$TravelAtlasDatabase, $OutboxMutationsTable> {
  $$OutboxMutationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$OutboxMutationsTableTableManager
    extends
        RootTableManager<
          _$TravelAtlasDatabase,
          $OutboxMutationsTable,
          DbOutboxMutation,
          $$OutboxMutationsTableFilterComposer,
          $$OutboxMutationsTableOrderingComposer,
          $$OutboxMutationsTableAnnotationComposer,
          $$OutboxMutationsTableCreateCompanionBuilder,
          $$OutboxMutationsTableUpdateCompanionBuilder,
          (
            DbOutboxMutation,
            BaseReferences<
              _$TravelAtlasDatabase,
              $OutboxMutationsTable,
              DbOutboxMutation
            >,
          ),
          DbOutboxMutation,
          PrefetchHooks Function()
        > {
  $$OutboxMutationsTableTableManager(
    _$TravelAtlasDatabase db,
    $OutboxMutationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxMutationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxMutationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxMutationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxMutationsCompanion(
                id: id,
                operation: operation,
                entityId: entityId,
                status: status,
                attemptCount: attemptCount,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String operation,
                required String entityId,
                required String status,
                required int attemptCount,
                Value<String?> lastError = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => OutboxMutationsCompanion.insert(
                id: id,
                operation: operation,
                entityId: entityId,
                status: status,
                attemptCount: attemptCount,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxMutationsTableProcessedTableManager =
    ProcessedTableManager<
      _$TravelAtlasDatabase,
      $OutboxMutationsTable,
      DbOutboxMutation,
      $$OutboxMutationsTableFilterComposer,
      $$OutboxMutationsTableOrderingComposer,
      $$OutboxMutationsTableAnnotationComposer,
      $$OutboxMutationsTableCreateCompanionBuilder,
      $$OutboxMutationsTableUpdateCompanionBuilder,
      (
        DbOutboxMutation,
        BaseReferences<
          _$TravelAtlasDatabase,
          $OutboxMutationsTable,
          DbOutboxMutation
        >,
      ),
      DbOutboxMutation,
      PrefetchHooks Function()
    >;
typedef $$PendingMediaUploadsTableCreateCompanionBuilder =
    PendingMediaUploadsCompanion Function({
      required String id,
      required String photoId,
      required String localPath,
      required String fileName,
      required String storageBucket,
      required String storagePath,
      required String status,
      required int attemptCount,
      Value<String?> lastError,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PendingMediaUploadsTableUpdateCompanionBuilder =
    PendingMediaUploadsCompanion Function({
      Value<String> id,
      Value<String> photoId,
      Value<String> localPath,
      Value<String> fileName,
      Value<String> storageBucket,
      Value<String> storagePath,
      Value<String> status,
      Value<int> attemptCount,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PendingMediaUploadsTableReferences
    extends
        BaseReferences<
          _$TravelAtlasDatabase,
          $PendingMediaUploadsTable,
          DbPendingMediaUpload
        > {
  $$PendingMediaUploadsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PhotoAssetsTable _photoIdTable(_$TravelAtlasDatabase db) =>
      db.photoAssets.createAlias(
        $_aliasNameGenerator(db.pendingMediaUploads.photoId, db.photoAssets.id),
      );

  $$PhotoAssetsTableProcessedTableManager get photoId {
    final $_column = $_itemColumn<String>('photo_id')!;

    final manager = $$PhotoAssetsTableTableManager(
      $_db,
      $_db.photoAssets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_photoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PendingMediaUploadsTableFilterComposer
    extends Composer<_$TravelAtlasDatabase, $PendingMediaUploadsTable> {
  $$PendingMediaUploadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storageBucket => $composableBuilder(
    column: $table.storageBucket,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PhotoAssetsTableFilterComposer get photoId {
    final $$PhotoAssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.photoId,
      referencedTable: $db.photoAssets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotoAssetsTableFilterComposer(
            $db: $db,
            $table: $db.photoAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PendingMediaUploadsTableOrderingComposer
    extends Composer<_$TravelAtlasDatabase, $PendingMediaUploadsTable> {
  $$PendingMediaUploadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storageBucket => $composableBuilder(
    column: $table.storageBucket,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PhotoAssetsTableOrderingComposer get photoId {
    final $$PhotoAssetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.photoId,
      referencedTable: $db.photoAssets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotoAssetsTableOrderingComposer(
            $db: $db,
            $table: $db.photoAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PendingMediaUploadsTableAnnotationComposer
    extends Composer<_$TravelAtlasDatabase, $PendingMediaUploadsTable> {
  $$PendingMediaUploadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get storageBucket => $composableBuilder(
    column: $table.storageBucket,
    builder: (column) => column,
  );

  GeneratedColumn<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PhotoAssetsTableAnnotationComposer get photoId {
    final $$PhotoAssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.photoId,
      referencedTable: $db.photoAssets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotoAssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.photoAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PendingMediaUploadsTableTableManager
    extends
        RootTableManager<
          _$TravelAtlasDatabase,
          $PendingMediaUploadsTable,
          DbPendingMediaUpload,
          $$PendingMediaUploadsTableFilterComposer,
          $$PendingMediaUploadsTableOrderingComposer,
          $$PendingMediaUploadsTableAnnotationComposer,
          $$PendingMediaUploadsTableCreateCompanionBuilder,
          $$PendingMediaUploadsTableUpdateCompanionBuilder,
          (DbPendingMediaUpload, $$PendingMediaUploadsTableReferences),
          DbPendingMediaUpload,
          PrefetchHooks Function({bool photoId})
        > {
  $$PendingMediaUploadsTableTableManager(
    _$TravelAtlasDatabase db,
    $PendingMediaUploadsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingMediaUploadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingMediaUploadsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PendingMediaUploadsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> photoId = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> storageBucket = const Value.absent(),
                Value<String> storagePath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingMediaUploadsCompanion(
                id: id,
                photoId: photoId,
                localPath: localPath,
                fileName: fileName,
                storageBucket: storageBucket,
                storagePath: storagePath,
                status: status,
                attemptCount: attemptCount,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String photoId,
                required String localPath,
                required String fileName,
                required String storageBucket,
                required String storagePath,
                required String status,
                required int attemptCount,
                Value<String?> lastError = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PendingMediaUploadsCompanion.insert(
                id: id,
                photoId: photoId,
                localPath: localPath,
                fileName: fileName,
                storageBucket: storageBucket,
                storagePath: storagePath,
                status: status,
                attemptCount: attemptCount,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PendingMediaUploadsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({photoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (photoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.photoId,
                                referencedTable:
                                    $$PendingMediaUploadsTableReferences
                                        ._photoIdTable(db),
                                referencedColumn:
                                    $$PendingMediaUploadsTableReferences
                                        ._photoIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PendingMediaUploadsTableProcessedTableManager =
    ProcessedTableManager<
      _$TravelAtlasDatabase,
      $PendingMediaUploadsTable,
      DbPendingMediaUpload,
      $$PendingMediaUploadsTableFilterComposer,
      $$PendingMediaUploadsTableOrderingComposer,
      $$PendingMediaUploadsTableAnnotationComposer,
      $$PendingMediaUploadsTableCreateCompanionBuilder,
      $$PendingMediaUploadsTableUpdateCompanionBuilder,
      (DbPendingMediaUpload, $$PendingMediaUploadsTableReferences),
      DbPendingMediaUpload,
      PrefetchHooks Function({bool photoId})
    >;
typedef $$SyncStatesTableCreateCompanionBuilder =
    SyncStatesCompanion Function({
      Value<int> id,
      required String severity,
      required String bannerTitle,
      required String bannerMessage,
      required int pendingChanges,
      required int pendingUploads,
      Value<DateTime?> lastSyncedAt,
    });
typedef $$SyncStatesTableUpdateCompanionBuilder =
    SyncStatesCompanion Function({
      Value<int> id,
      Value<String> severity,
      Value<String> bannerTitle,
      Value<String> bannerMessage,
      Value<int> pendingChanges,
      Value<int> pendingUploads,
      Value<DateTime?> lastSyncedAt,
    });

class $$SyncStatesTableFilterComposer
    extends Composer<_$TravelAtlasDatabase, $SyncStatesTable> {
  $$SyncStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bannerTitle => $composableBuilder(
    column: $table.bannerTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bannerMessage => $composableBuilder(
    column: $table.bannerMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pendingChanges => $composableBuilder(
    column: $table.pendingChanges,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pendingUploads => $composableBuilder(
    column: $table.pendingUploads,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStatesTableOrderingComposer
    extends Composer<_$TravelAtlasDatabase, $SyncStatesTable> {
  $$SyncStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bannerTitle => $composableBuilder(
    column: $table.bannerTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bannerMessage => $composableBuilder(
    column: $table.bannerMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pendingChanges => $composableBuilder(
    column: $table.pendingChanges,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pendingUploads => $composableBuilder(
    column: $table.pendingUploads,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStatesTableAnnotationComposer
    extends Composer<_$TravelAtlasDatabase, $SyncStatesTable> {
  $$SyncStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get bannerTitle => $composableBuilder(
    column: $table.bannerTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bannerMessage => $composableBuilder(
    column: $table.bannerMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pendingChanges => $composableBuilder(
    column: $table.pendingChanges,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pendingUploads => $composableBuilder(
    column: $table.pendingUploads,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$SyncStatesTableTableManager
    extends
        RootTableManager<
          _$TravelAtlasDatabase,
          $SyncStatesTable,
          DbSyncState,
          $$SyncStatesTableFilterComposer,
          $$SyncStatesTableOrderingComposer,
          $$SyncStatesTableAnnotationComposer,
          $$SyncStatesTableCreateCompanionBuilder,
          $$SyncStatesTableUpdateCompanionBuilder,
          (
            DbSyncState,
            BaseReferences<
              _$TravelAtlasDatabase,
              $SyncStatesTable,
              DbSyncState
            >,
          ),
          DbSyncState,
          PrefetchHooks Function()
        > {
  $$SyncStatesTableTableManager(
    _$TravelAtlasDatabase db,
    $SyncStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<String> bannerTitle = const Value.absent(),
                Value<String> bannerMessage = const Value.absent(),
                Value<int> pendingChanges = const Value.absent(),
                Value<int> pendingUploads = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => SyncStatesCompanion(
                id: id,
                severity: severity,
                bannerTitle: bannerTitle,
                bannerMessage: bannerMessage,
                pendingChanges: pendingChanges,
                pendingUploads: pendingUploads,
                lastSyncedAt: lastSyncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String severity,
                required String bannerTitle,
                required String bannerMessage,
                required int pendingChanges,
                required int pendingUploads,
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => SyncStatesCompanion.insert(
                id: id,
                severity: severity,
                bannerTitle: bannerTitle,
                bannerMessage: bannerMessage,
                pendingChanges: pendingChanges,
                pendingUploads: pendingUploads,
                lastSyncedAt: lastSyncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$TravelAtlasDatabase,
      $SyncStatesTable,
      DbSyncState,
      $$SyncStatesTableFilterComposer,
      $$SyncStatesTableOrderingComposer,
      $$SyncStatesTableAnnotationComposer,
      $$SyncStatesTableCreateCompanionBuilder,
      $$SyncStatesTableUpdateCompanionBuilder,
      (
        DbSyncState,
        BaseReferences<_$TravelAtlasDatabase, $SyncStatesTable, DbSyncState>,
      ),
      DbSyncState,
      PrefetchHooks Function()
    >;

class $TravelAtlasDatabaseManager {
  final _$TravelAtlasDatabase _db;
  $TravelAtlasDatabaseManager(this._db);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db, _db.trips);
  $$JournalEntriesTableTableManager get journalEntries =>
      $$JournalEntriesTableTableManager(_db, _db.journalEntries);
  $$PhotoAssetsTableTableManager get photoAssets =>
      $$PhotoAssetsTableTableManager(_db, _db.photoAssets);
  $$OutboxMutationsTableTableManager get outboxMutations =>
      $$OutboxMutationsTableTableManager(_db, _db.outboxMutations);
  $$PendingMediaUploadsTableTableManager get pendingMediaUploads =>
      $$PendingMediaUploadsTableTableManager(_db, _db.pendingMediaUploads);
  $$SyncStatesTableTableManager get syncStates =>
      $$SyncStatesTableTableManager(_db, _db.syncStates);
}
