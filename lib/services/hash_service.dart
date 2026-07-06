import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// Service for computing SHA-256 hashes of files.
///
/// Used to detect duplicate PDF imports and ensure data integrity.
class HashService {
  /// Compute the SHA-256 hash of a file.
  ///
  /// Returns the hex-encoded hash string.
  Future<String> computeFileHash(File file) async {
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Compute the SHA-256 hash of a byte array.
  String computeHash(List<int> bytes) {
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Compute the SHA-256 hash of a string.
  String computeStringHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
