import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/image_prep.dart';

/// Wraps camera/gallery picking, native cropping and on-device image storage so
/// the flow can be tested with a fake.
abstract interface class ImageService {
  Future<String?> pick({required bool camera});
  Future<String?> crop(String path, {required String title, required Color toolbarColor});

  /// Reads the cropped file into memory, prepares it for upload (resize, JPEG,
  /// metadata stripped) and deletes the temporary files.
  Future<Uint8List> loadPreparedAndDeleteTemp(List<String> tempPaths);

  /// Deletes temporary picked/cropped files (e.g. when the user cancels).
  Future<void> deleteTemp(List<String> tempPaths);

  /// Persists bill image bytes when the "keep images" setting is on.
  Future<String> keep(String billId, Uint8List bytes);
  Future<void> deleteKept(String? path);
  Future<void> deleteAllKept();
}

class DeviceImageService implements ImageService {
  final _picker = ImagePicker();

  @override
  Future<String?> pick({required bool camera}) async {
    final file = await _picker.pickImage(source: camera ? ImageSource.camera : ImageSource.gallery, requestFullMetadata: false);
    return file?.path;
  }

  @override
  Future<String?> crop(String path, {required String title, required Color toolbarColor}) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 95,
      uiSettings: [
        AndroidUiSettings(toolbarTitle: title, toolbarColor: toolbarColor, toolbarWidgetColor: Colors.white, lockAspectRatio: false, initAspectRatio: CropAspectRatioPreset.original),
        IOSUiSettings(title: title, aspectRatioLockEnabled: false),
      ],
    );
    return cropped?.path;
  }

  @override
  Future<Uint8List> loadPreparedAndDeleteTemp(List<String> tempPaths) async {
    try {
      final raw = await File(tempPaths.last).readAsBytes();
      return await Isolate.run(() => prepareForUpload(raw));
    } finally {
      await deleteTemp(tempPaths);
    }
  }

  @override
  Future<void> deleteTemp(List<String> tempPaths) async {
    for (final path in tempPaths.toSet()) {
      try {
        final f = File(path);
        if (await f.exists()) await f.delete();
      } on FileSystemException {
        // Best effort: OS temp dirs are cleaned eventually.
      }
    }
  }

  Future<Directory> _dir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'bill_images'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  @override
  Future<String> keep(String billId, Uint8List bytes) async {
    final file = File(p.join((await _dir()).path, '$billId.jpg'));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  @override
  Future<void> deleteKept(String? path) async {
    if (path == null) return;
    final f = File(path);
    if (await f.exists()) await f.delete();
  }

  @override
  Future<void> deleteAllKept() async {
    final dir = await _dir();
    if (await dir.exists()) await dir.delete(recursive: true);
  }
}

final imageServiceProvider = Provider<ImageService>((ref) => DeviceImageService());
