import 'dart:typed_data';

import 'runtime_asset_fetcher_native.dart'
    if (dart.library.html) 'runtime_asset_fetcher_web.dart';

abstract class RuntimeAssetFetcher {
  Future<String> loadString(String relativePath);
  Future<Uint8List> loadBytes(String relativePath);
}

RuntimeAssetFetcher createRuntimeAssetFetcher(Uri baseUri) =>
    createRuntimeAssetFetcherImpl(baseUri);
