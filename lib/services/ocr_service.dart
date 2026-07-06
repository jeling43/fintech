import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Service for performing OCR on scanned PDF pages.
///
/// Uses Google ML Kit text recognition to extract text from images.
/// Temporary images are deleted after processing to protect privacy.
class OcrService {
  TextRecognizer? _textRecognizer;

  TextRecognizer get _recognizer {
    _textRecognizer ??= TextRecognizer();
    return _textRecognizer!;
  }

  /// Perform OCR on an image file and return the extracted text.
  ///
  /// [imageFile] should be a rendered image of a PDF page.
  Future<String> recognizeText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognizedText = await _recognizer.processImage(inputImage);
    return recognizedText.text;
  }

  /// Perform OCR on image bytes (e.g., from a rendered PDF page).
  ///
  /// Saves the bytes to a temporary file, performs OCR, then deletes
  /// the temporary file for security.
  Future<String> recognizeFromBytes(List<int> imageBytes,
      {String filename = 'ocr_temp.png'}) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(p.join(tempDir.path, filename));

    try {
      await tempFile.writeAsBytes(imageBytes);
      final text = await recognizeText(tempFile);
      return text;
    } finally {
      // Always delete temporary OCR images for security
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

  /// Clean up resources.
  void dispose() {
    _textRecognizer?.close();
    _textRecognizer = null;
  }

  /// Delete all temporary OCR files from the temp directory.
  Future<void> cleanupTempFiles() async {
    final tempDir = await getTemporaryDirectory();
    final dir = Directory(tempDir.path);
    final entities = dir.listSync();

    for (final entity in entities) {
      if (entity is File && entity.path.contains('ocr_temp')) {
        await entity.delete();
      }
    }
  }
}
