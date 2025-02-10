// lib/screens/camera_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/openai_service.dart';
import '../utilities/qr_utils.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});
  
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  String? _analysisResult;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _controller = CameraController(_cameras[0], ResolutionPreset.medium);
      await _controller!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // Capture an image and process it.
  Future<void> _captureAndProcessImage() async {
    if (_controller != null && _controller!.value.isInitialized) {
      XFile capturedImage = await _controller!.takePicture();
      File imageFile = File(capturedImage.path);

      // Convert image to base64.
      final imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // Create a prompt for image analysis.
      String promptImage =
          "Please analyze this base64-encoded image for potential security red flags regarding QR codes:\n$base64Image";

      // Get analysis from OpenAI.
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

      // Combine the results.
      setState(() {
        _analysisResult =
            "Image Analysis:\n$imageAnalysisResult\n\nQR Code Analysis:\n${detailedResults.join("\n\n")}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Camera Capture"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade200, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isCameraInitialized
            ? Column(
                children: [
                  // Camera preview with rounded corners.
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CameraPreview(_controller!),
                      ),
                    ),
                  ),
                  // Capture button.
                  ElevatedButton(
                    onPressed: _captureAndProcessImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Capture",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Display analysis result if available.
                  if (_analysisResult != null)
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _analysisResult!,
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}