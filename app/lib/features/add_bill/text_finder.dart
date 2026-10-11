import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/private_text.dart';

/// Reads the lines of text on a photo, on the phone (nothing is sent anywhere).
abstract interface class TextFinder {
  /// [width]/[height] are the photo's pixel size, used to turn boxes into fractions.
  Future<List<FoundText>> lines(Uint8List jpeg, {required int width, required int height});
}

/// Google ML Kit's offline text reader (Latin script).
class MlKitTextFinder implements TextFinder {
  @override
  Future<List<FoundText>> lines(Uint8List jpeg, {required int width, required int height}) async {
    // ML Kit reads compressed images only from a file. It lives in the app's private
    // cache for a moment and is deleted right after.
    final file = File(p.join((await getTemporaryDirectory()).path, 'ocr_${DateTime.now().microsecondsSinceEpoch}.jpg'));
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      await file.writeAsBytes(jpeg, flush: true);
      final result = await recognizer.processImage(InputImage.fromFilePath(file.path));
      return [
        for (final block in result.blocks)
          for (final line in block.lines)
            FoundText(
              line.text,
              line.boundingBox.left / width,
              line.boundingBox.top / height,
              line.boundingBox.right / width,
              line.boundingBox.bottom / height,
            ),
      ];
    } finally {
      await recognizer.close();
      if (await file.exists()) await file.delete();
    }
  }
}

final textFinderProvider = Provider<TextFinder>((ref) => MlKitTextFinder());
