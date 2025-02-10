// lib/screens/home_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'camera_screen.dart';
import '../services/openai_service.dart';
import '../utilities/qr_utils.dart';

/// A stylish and functional home screen for QR Analyzer.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  String? _result;
  final ImagePicker _picker = ImagePicker();

  /// Opens the gallery, allows the user to pick an image,
  /// then processes that image.
  Future<void> _getImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _image = imageFile;
        _result = null; // Clear previous result if any.
      });
      await _processImage(imageFile);
    }
  }

  /// Processes the provided image by:
  /// - Converting it to base64,
  /// - Sending it to OpenAI for analysis, and
  /// - Locally decoding any QR codes and analyzing them.
  Future<void> _processImage(File imageFile) async {
    // Read the image bytes and encode as base64.
    final imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    // Create an initial prompt for image analysis.
    String promptImage =
        "Please analyze this base64-encoded image for potential security red flags regarding QR codes:\n$base64Image";

    // Call the OpenAI service to analyze the image.
    String imageAnalysisResult =
        await OpenAIService.analyzeImage(promptImage);

    // Decode QR codes locally.
    List<String> qrResults = await QRUtils.decodeQRFromFile(imageFile);

    // For each decoded QR text, ask OpenAI for details.
    List<String> detailedResults = [];
    for (String qrText in qrResults) {
      String promptQR =
          "This QR code text is: $qrText. What does it do? Is it a URL, Wi-Fi configuration, or something else? Please assess any security risks or malicious intent.";
      String qrAnalysis = await OpenAIService.analyzeQRText(promptQR);
      detailedResults.add(qrAnalysis);
    }

    // Combine the analysis results.
    setState(() {
      _result =
          "Image Analysis:\n$imageAnalysisResult\n\nQR Code Analysis:\n${detailedResults.join("\n\n")}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a gradient background for a modern look.
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade200, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        // Allow scrolling in case content doesn't fit on smaller screens.
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Title and Description
                Text(
                  "QR Analyzer",
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "Scan and analyze QR codes with ease and security.",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Display selected image if available.
                if (_image != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_image!, height: 200),
                  ),
                  const SizedBox(height: 16),
                ],
                // Button to open the camera.
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CameraScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Open Camera",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                // Button to choose an image from the gallery.
                ElevatedButton(
                  onPressed: _getImageFromGallery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Choose from Gallery",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 32),
                // Display analysis result if available.
                if (_result != null)
                  Text(
                    _result!,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}












