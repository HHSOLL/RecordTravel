import '../../data/record_globe_asset_repository.dart';
import '../entities/record_globe_asset_set.dart';
import '../../../globe_engine/record_globe_engine_config.dart';

abstract class LoadGlobeAssetsUseCase {
  Future<RecordGlobeAssetSet> call({
    required RecordGlobeRendererKind rendererKind,
  });
}

class DefaultLoadGlobeAssetsUseCase implements LoadGlobeAssetsUseCase {
  const DefaultLoadGlobeAssetsUseCase(this._repository);

  final RecordGlobeAssetRepository _repository;

  @override
  Future<RecordGlobeAssetSet> call({
    required RecordGlobeRendererKind rendererKind,
  }) {
    return _repository.loadAssets(rendererKind: rendererKind);
  }
}
