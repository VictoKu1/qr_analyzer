import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const _apiKey = 'YOUR_OPENAI_API_KEY';
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';

  // 1) Analyze the raw image bytes
  //    In reality, OpenAI doesn't natively support direct image analysis via /chat/completions,
  //    you'd typically use the "Vision" model or an image endpoint if available, or a 3rd-party service.
  //    For demonstration, let's pretend we can send the image as a base64 string and ask a GPT model.
  static Future<String> analyzeImage(List<int> imageBytes) async {
    final base64Image = base64Encode(imageBytes);
    final prompt = '''
We have an image (base64 below). 
- If possible, can you guess how many QR codes might be in this image?
- Are there any potential security concerns from this image (like malicious code or something suspicious about size, etc.)?

(base64 truncated for brevity)
''';

    return await _sendChatPrompt(prompt);
  }

  // 2) Analyze text from a decoded QR
  static Future<String> analyzeQRText(String qrText) async {
    final prompt = '''
The following text was extracted from a QR code:

"$qrText"

1. What does this text represent? (e.g., URL, Wi-Fi credentials, contact info, etc.)
2. Could it pose any security risk to a mobile device? 
3. Summarize in a user-friendly manner.
''';

    return await _sendChatPrompt(prompt);
  }

  static Future<String> _sendChatPrompt(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo", // or "gpt-4" if you have access
          "messages": [
            {"role": "user", "content": prompt}
          ],
          "max_tokens": 200,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResp = jsonDecode(response.body);
        final content = jsonResp['choices'][0]['message']['content'];
        return content.trim();
      } else {
        return 'OpenAI API error: ${response.body}';
      }
    } catch (e) {
      return 'OpenAI API exception: $e';
    }
  }
}
