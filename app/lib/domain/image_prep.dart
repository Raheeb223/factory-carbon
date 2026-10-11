/// Client-side image preparation before upload (spec 8.2): long edge ~1600 px, JPEG,
/// EXIF orientation applied and ALL metadata (incl. GPS) stripped.
library;

import 'dart:typed_data';

import 'package:image/image.dart' as img;

const int targetLongEdge = 1600;
const int jpegQuality = 85;

class ImagePrepException implements Exception {
  const ImagePrepException(this.message);
  final String message;
}

/// Runs synchronously; call through `compute`/`Isolate.run` from UI code.
Uint8List prepareForUpload(Uint8List input) {
  img.Image? decoded;
  try {
    decoded = img.decodeImage(input);
  } catch (_) {
    decoded = null; // decoders can throw on truncated/garbage data
  }
  if (decoded == null) throw const ImagePrepException('Unsupported or corrupt image');
  var image = img.bakeOrientation(decoded);
  final longEdge = image.width > image.height ? image.width : image.height;
  if (longEdge > targetLongEdge) {
    image = image.width >= image.height
        ? img.copyResize(image, width: targetLongEdge, interpolation: img.Interpolation.average)
        : img.copyResize(image, height: targetLongEdge, interpolation: img.Interpolation.average);
  }
  image.exif = img.ExifData();
  return img.encodeJpg(image, quality: jpegQuality);
}
