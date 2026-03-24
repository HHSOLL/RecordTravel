import '../../data/record_country_repository.dart';
import '../../data/record_globe_asset_repository.dart';
import '../entities/record_globe_scene_spec.dart';
import '../../../globe_engine/record_globe_engine_config.dart';

abstract class BuildGlobeSceneUseCase {
  Future<RecordGlobeSceneSpec> call({
    required RecordGlobeStyle style,
    required RecordGlobeRendererKind rendererKind,
    String? initialCountryCode,
    String? selectedCountryCode,
    String? focusedCountryCode,
  });
}

class DefaultBuildGlobeSceneUseCase implements BuildGlobeSceneUseCase {
  const DefaultBuildGlobeSceneUseCase({
    required RecordCountryRepository countryRepository,
    required RecordGlobeAssetRepository assetRepository,
  })  : _countryRepository = countryRepository,
        _assetRepository = assetRepository;

  final RecordCountryRepository _countryRepository;
  final RecordGlobeAssetRepository _assetRepository;

  @override
  Future<RecordGlobeSceneSpec> call({
    required RecordGlobeStyle style,
    required RecordGlobeRendererKind rendererKind,
    String? initialCountryCode,
    String? selectedCountryCode,
    String? focusedCountryCode,
  }) async {
    final countries = await _countryRepository.loadCountries();
    final assetSet = await _assetRepository.loadAssets(
      rendererKind: rendererKind,
    );
    return RecordGlobeSceneSpec(
      style: style,
      countries: countries,
      assetSet: assetSet,
      initialCountryCode: initialCountryCode,
      selectedCountryCode: selectedCountryCode,
      focusedCountryCode: focusedCountryCode,
    );
  }
}
