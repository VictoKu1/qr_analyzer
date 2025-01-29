import 'dart:typed_data';
import 'package:qr_code_tools/qr_code_tools.dart';

class QRUtils {
  /// Decodes the first QR code found in [imageBytes].
  /// Returns the decoded text, or null if none found.
  static Future<String?> decodeFirstQR(Uint8List imageBytes) async {
    try {
      final result = await QrCodeToolsPlugin.decodeFrom(imageBytes);
      if (result != null && result.isNotEmpty) {
        return result;
      }
      return null;
    } catch (e) {
      // Log or handle errors as needed
      return null;
    }
  }

  // If you want to attempt multiple QRs, you may need a different library,
  // or a custom approach scanning multiple regions of the image.
  // Add those methods here if necessary.
}
