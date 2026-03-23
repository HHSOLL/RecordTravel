import 'dart:io';

import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:image_picker/image_picker.dart';
import 'package:native_exif/native_exif.dart';
import 'package:photo_manager/photo_manager.dart';

class NativePhotoIngestionAdapter implements PhotoIngestionPlatformAdapter {
  NativePhotoIngestionAdapter({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<List<ExtractedPhotoMetadata>> pickPhotos(
    PhotoIngestionRequest request,
  ) async {
    if (request.scope == PhotoIngestionScope.library) {
      return _scanLibraryMetadata();
    }

    final selected = await _picker.pickMultiImage(requestFullMetadata: true);
    if (selected.isNotEmpty) {
      return Future.wait(selected.map(_extractMetadata));
    }

    final lost = await _picker.retrieveLostData();
    if (!lost.isEmpty && lost.files != null && lost.files!.isNotEmpty) {
      return Future.wait(lost.files!.map(_extractMetadata));
    }

    return const [];
  }

  Future<List<ExtractedPhotoMetadata>> _scanLibraryMetadata() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.hasAccess) {
      return const [];
    }

    final paths = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image,
    );
    if (paths.isEmpty) return const [];

    final allPhotos = paths.first;
    final total = await allPhotos.assetCountAsync;
    const pageSize = 120;
    final items = <ExtractedPhotoMetadata>[];

    for (var page = 0; page * pageSize < total; page++) {
      final assets = await allPhotos.getAssetListPaged(page: page, size: pageSize);
      for (final asset in assets) {
        final metadata = await _extractAssetEntityMetadata(asset);
        if (metadata != null) {
          items.add(metadata);
        }
      }
    }

    return items;
  }

  Future<ExtractedPhotoMetadata> _extractMetadata(XFile file) async {
    final path = file.path;
    final fileName = _basename(path);
    final fileSize = await File(path).length();
    final exifData = await _readExif(path);
    final takenAt = exifData.originalDate ?? DateTime.now();
    final format = _formatFor(fileName);

    return ExtractedPhotoMetadata(
      id: '${takenAt.microsecondsSinceEpoch}-${fileName.hashCode}',
      fileName: fileName,
      displayName: _displayNameFor(fileName),
      format: format,
      previewLabel: _previewLabelFor(fileName),
      takenAt: takenAt,
      sourcePath: path,
      byteSize: fileSize,
      latitude: exifData.latitude,
      longitude: exifData.longitude,
    );
  }

  Future<ExtractedPhotoMetadata?> _extractAssetEntityMetadata(
    AssetEntity asset,
  ) async {
    final fileName = await asset.titleAsync;
    if (fileName.trim().isEmpty) {
      return null;
    }

    final sourceFile = await asset.originFile;
    final path = sourceFile?.path;
    int? byteSize;
    DateTime takenAt = asset.createDateTime;
    double? latitude = asset.latLng?.latitude ?? asset.latitude;
    double? longitude = asset.latLng?.longitude ?? asset.longitude;

    if (sourceFile != null) {
      byteSize = await sourceFile.length();
      final exifData = await _readExif(path!);
      takenAt = exifData.originalDate ?? takenAt;
      latitude = exifData.latitude ?? latitude;
      longitude = exifData.longitude ?? longitude;
    }

    return ExtractedPhotoMetadata(
      id: asset.id,
      fileName: fileName,
      displayName: _displayNameFor(fileName),
      format: _formatFor(fileName, mimeType: asset.mimeType),
      previewLabel: _previewLabelFor(fileName),
      takenAt: takenAt,
      sourcePath: path,
      byteSize: byteSize,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<_ExifData> _readExif(String path) async {
    final exif = await Exif.fromPath(path);
    final latLong = await exif.getLatLong();
    final originalDate = await exif.getOriginalDate();
    await exif.close();
    return _ExifData(
      latitude: latLong?.latitude,
      longitude: latLong?.longitude,
      originalDate: originalDate,
    );
  }

  String _basename(String path) => path.split(Platform.pathSeparator).last;

  String _formatFor(String fileName, {String? mimeType}) {
    final dot = fileName.lastIndexOf('.');
    if (dot == -1 || dot == fileName.length - 1) {
      if (mimeType != null && mimeType.contains('/')) {
        return mimeType.split('/').last.toUpperCase();
      }
      return 'UNKNOWN';
    }
    return fileName.substring(dot + 1).toUpperCase();
  }

  String _displayNameFor(String fileName) {
    final dot = fileName.lastIndexOf('.');
    final stem = dot == -1 ? fileName : fileName.substring(0, dot);
    return stem
        .split(RegExp(r'[_\-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String _previewLabelFor(String fileName) {
    final clean = _displayNameFor(
      fileName,
    ).replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    if (clean.isEmpty) return 'PH';
    return clean.substring(0, clean.length < 2 ? 1 : 2).toUpperCase();
  }
}

class _ExifData {
  const _ExifData({
    this.latitude,
    this.longitude,
    this.originalDate,
  });

  final double? latitude;
  final double? longitude;
  final DateTime? originalDate;
}
