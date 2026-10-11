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

/// A box to black out, in fractions (0..1) of the image width/height so it does not
/// depend on how large the photo was drawn on screen.
class RedactBox {
  const RedactBox(this.left, this.top, this.right, this.bottom);
  final double left;
  final double top;
  final double right;
  final double bottom;
}

/// Burns solid black boxes into the JPEG (pixels are replaced, not overlaid), so the
/// covered details never leave the phone. Runs synchronously; call via `Isolate.run`.
Uint8List applyRedactions(Uint8List jpeg, List<RedactBox> boxes) {
  if (boxes.isEmpty) return jpeg;
  final image = img.decodeImage(jpeg);
  if (image == null) throw const ImagePrepException('Unsupported or corrupt image');
  final black = img.ColorRgb8(0, 0, 0);
  int px(double f, int size) => (f.clamp(0.0, 1.0) * size).round();
  for (final b in boxes) {
    img.fillRect(
      image,
      x1: px(b.left, image.width),
      y1: px(b.top, image.height),
      x2: px(b.right, image.width),
      y2: px(b.bottom, image.height),
      color: black,
    );
  }
  image.exif = img.ExifData();
  return img.encodeJpg(image, quality: jpegQuality);
}
