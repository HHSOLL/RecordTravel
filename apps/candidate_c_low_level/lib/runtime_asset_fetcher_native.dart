import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'runtime_asset_fetcher.dart';

class _NativeRuntimeAssetFetcher implements RuntimeAssetFetcher {
  _NativeRuntimeAssetFetcher(Uri baseUri)
    : _bundle = NetworkAssetBundle(baseUri);

  final NetworkAssetBundle _bundle;

  @override
  Future<String> loadString(String relativePath) => _bundle.loadString(relativePath);

  @override
  Future<Uint8List> loadBytes(String relativePath) async {
    final data = await _bundle.load(relativePath);
    return data.buffer.asUint8List();
  }
}

RuntimeAssetFetcher createRuntimeAssetFetcherImpl(Uri baseUri) =>
    _NativeRuntimeAssetFetcher(baseUri);
