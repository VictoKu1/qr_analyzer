// lib/services/openai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const String _apiKey = "YOUR_OPENAI_API_KEY";
  // Using a GPT completion endpoint (adjust as needed)
  static const String _apiUrl = "https://api.openai.com/v1/completions";

  // For image analysis (conceptual)
  static Future<String> analyzeImage(String prompt) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_apiKey",
      },
      body: jsonEncode({
        "model": "text-davinci-003",
        "prompt": prompt,
        "max_tokens": 150,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String result = data["choices"][0]["text"];
      return result.trim();
    } else {
      return "Error analyzing image: ${response.statusCode}";
    }
  }

  // For QR text analysis
  static Future<String> analyzeQRText(String prompt) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_apiKey",
      },
      body: jsonEncode({
        "model": "text-davinci-003",
        "prompt": prompt,
        "max_tokens": 150,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String result = data["choices"][0]["text"];
      return result.trim();
    } else {
      return "Error analyzing QR text: ${response.statusCode}";
    }
  }
}







