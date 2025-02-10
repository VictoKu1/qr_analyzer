// lib/utilities/qr_utils.dart
import 'dart:io';
import 'package:qr_code_tools/qr_code_tools.dart';

class QRUtils {
  /// Attempts to decode a QR code from the provided image file.
  /// Returns a list of decoded strings (if any).
  static Future<List<String>> decodeQRFromFile(File imageFile) async {
    List<String> qrResults = [];
    try {
      // The QrCodeToolsPlugin decodes a single QR code.
      String? qrText = await QrCodeToolsPlugin.decodeFrom(imageFile.path);
      if (qrText != null && qrText.isNotEmpty) {
        qrResults.add(qrText);
      }
    } catch (e) {
      print("Error decoding QR code: $e");
    }
    return qrResults;
  }
}



