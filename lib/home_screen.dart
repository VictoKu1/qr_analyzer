import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_tools/qr_code_tools.dart';
import 'openai_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  String _analysisResult = '';
  List<String> _qrAnalysisResults = [];

  Future<void> _openCamera() async {
    // Request camera permission
    final status = await Permission.camera.request();
    if (status.isGranted) {
      // Open camera
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        // We have a valid photo, proceed
        await _processSelectedImage(photo);
      }
    } else {
      // Handle permission denied
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission denied')),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    // Request storage/photos permission (platform-dependent)
    final status = await Permission.photos.request();
    // On Android it may be Permission.storage
    if (status.isGranted) {
      final XFile? imageFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (imageFile != null) {
        // Validate extension
        final fileExt = imageFile.name.split('.').last.toLowerCase();
        if (!_isValidImageExtension(fileExt)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Invalid file type. Please select a JPG or PNG image.')),
          );
          return;
        }
        await _processSelectedImage(imageFile);
      }
    } else {
      // Handle permission denied
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gallery permission denied')),
      );
    }
  }

  bool _isValidImageExtension(String ext) {
    const validExts = ['jpg', 'jpeg', 'png'];
    return validExts.contains(ext);
  }

  Future<void> _processSelectedImage(XFile imageFile) async {
    setState(() {
      _analysisResult = 'Analyzing image with OpenAI...';
      _qrAnalysisResults.clear();
    });

    // Convert to bytes
    final bytes = await imageFile.readAsBytes();

    // 1) Send the image to OpenAI for initial analysis
    final initialAnalysis = await OpenAIService.analyzeImage(bytes);
    setState(() {
      _analysisResult = 'Initial Analysis:\n$initialAnalysis';
    });

    // 2) Search for QR codes in the image
    // qr_code_tools can only decode one QR at a time, so we might do repeated scans,
    // but typically it returns the first found. We'll do a basic approach:
    // If you suspect multiple QRs, you'd scan multiple regions or find another library
    // that can detect multiple QRs. For simplicity, let's show a single decode approach.
    setState(() {
      _analysisResult += '\n\nSearching for QR code(s)...';
    });

    // We'll attempt decode multiple times by scanning offsets.
    // However, qr_code_tools currently offers `QrCodeToolsPlugin.decodeFrom` for single decode.
    // For demonstration, let's just decode once:
    try {
      final qrText = await QrCodeToolsPlugin.decodeFrom(bytes);
      if (qrText == null || qrText.isEmpty) {
        setState(() {
          _analysisResult += '\nNo QR code found.';
        });
      } else {
        // We found at least one QR code
        setState(() {
          _analysisResult += '\nFound a QR code: $qrText';
        });

        // 3) Send the decoded text to OpenAI for further analysis
        final qrAnalysis = await OpenAIService.analyzeQRText(qrText);
        setState(() {
          _qrAnalysisResults.add(qrAnalysis);
        });
      }
    } catch (e) {
      setState(() {
        _analysisResult += '\nError decoding QR: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Analyzer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Big Buttons
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Open Camera'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                      ),
                      onPressed: _openCamera,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo),
                      label: const Text('Choose from Gallery'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                      ),
                      onPressed: _pickFromGallery,
                    ),
                  ],
                ),
              ),
            ),
            // Show Analysis Results
            if (_analysisResult.isNotEmpty) ...[
              const Divider(),
              Text(
                _analysisResult,
                style: const TextStyle(fontSize: 16),
              ),
            ],
            for (String result in _qrAnalysisResults)
              Card(
                color: Colors.grey[200],
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(result),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
