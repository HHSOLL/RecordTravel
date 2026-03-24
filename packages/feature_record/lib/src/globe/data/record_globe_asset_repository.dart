import 'package:flutter/foundation.dart';

import '../domain/entities/record_globe_asset_set.dart';
import '../../globe_engine/record_globe_engine_config.dart';

abstract class RecordGlobeAssetRepository {
  Future<RecordGlobeAssetSet> loadAssets({
    required RecordGlobeRendererKind rendererKind,
  });
}

class StaticRecordGlobeAssetRepository implements RecordGlobeAssetRepository {
  const StaticRecordGlobeAssetRepository(this._assetSet);

  final RecordGlobeAssetSet _assetSet;

  @override
  Future<RecordGlobeAssetSet> loadAssets({
    required RecordGlobeRendererKind rendererKind,
  }) async {
    if (_assetSet.rendererKind != rendererKind) {
      return _assetSet.copyWith(rendererKind: rendererKind);
    }
    return _assetSet;
  }
}

@immutable
class RecordGlobeAssetRepositoryError implements Exception {
  const RecordGlobeAssetRepositoryError(this.message);

  final String message;

  @override
  String toString() => 'RecordGlobeAssetRepositoryError($message)';
}
