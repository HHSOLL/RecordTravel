import 'dart:io';

import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:image_picker/image_picker.dart';
import 'package:native_exif/native_exif.dart';

class NativePhotoIngestionAdapter implements PhotoIngestionPlatformAdapter {
  NativePhotoIngestionAdapter({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<List<ExtractedPhotoMetadata>> pickPhotos(
    PhotoIngestionRequest request,
  ) async {
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

  Future<ExtractedPhotoMetadata> _extractMetadata(XFile file) async {
    final path = file.path;
    final exif = await Exif.fromPath(path);
    final latLong = await exif.getLatLong();
    final originalDate = await exif.getOriginalDate();
    await exif.close();

    final fileName = _basename(path);
    final fileSize = await File(path).length();
    final takenAt = originalDate ?? DateTime.now();
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
      latitude: latLong?.latitude,
      longitude: latLong?.longitude,
    );
  }

  String _basename(String path) => path.split(Platform.pathSeparator).last;

  String _formatFor(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot == -1 || dot == fileName.length - 1) return 'UNKNOWN';
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
