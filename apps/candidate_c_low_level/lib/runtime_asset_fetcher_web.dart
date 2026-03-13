import 'dart:html' as html;
import 'dart:typed_data';

import 'runtime_asset_fetcher.dart';

class _WebRuntimeAssetFetcher implements RuntimeAssetFetcher {
  _WebRuntimeAssetFetcher(this._baseUri);

  final Uri _baseUri;

  Uri _resolve(String relativePath) => _baseUri.resolve(relativePath);

  @override
  Future<String> loadString(String relativePath) =>
      html.HttpRequest.getString(_resolve(relativePath).toString());

  @override
  Future<Uint8List> loadBytes(String relativePath) async {
    final request = await html.HttpRequest.request(
      _resolve(relativePath).toString(),
      method: 'GET',
      responseType: 'arraybuffer',
    );
    final response = request.response;
    if (response is ByteBuffer) {
      return Uint8List.view(response);
    }
    if (response is Uint8List) {
      return response;
    }
    throw StateError(
      'Unexpected runtime asset response type for $relativePath: ${response.runtimeType}',
    );
  }
}

RuntimeAssetFetcher createRuntimeAssetFetcherImpl(Uri baseUri) =>
    _WebRuntimeAssetFetcher(baseUri);
