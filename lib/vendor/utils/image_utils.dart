import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class ImageUtils {
  /// Converts a File to base64 string without data URI prefix
  static Future<String?> fileToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      return null;
    }
  }

  /// Removes data URI prefix from base64 string
  /// Example: "data:image/jpeg;base64,/9j/4AAQ..." -> "/9j/4AAQ..."
  static String cleanBase64String(String base64String) {
    if (base64String.contains(',')) {
      return base64String.split(',')[1];
    }
    return base64String;
  }

  /// Converts base64 string to Uint8List for image display
  static Uint8List? base64ToBytes(String base64String) {
    try {
      final cleanBase64 = cleanBase64String(base64String);
      return base64Decode(cleanBase64);
    } catch (e) {
      return null;
    }
  }

  /// Checks if a string is a valid base64 image
  static bool isValidBase64Image(String value) {
    try {
      final cleanBase64 = cleanBase64String(value);
      base64Decode(cleanBase64);
      return true;
    } catch (e) {
      return false;
    }
  }
}