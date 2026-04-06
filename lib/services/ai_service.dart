import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const apiKey = ""; // 🔥 replace this

  static Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {"role": "user", "content": message}
          ]
        }),
      );

      /// ✅ CHECK RESPONSE
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data["choices"]?[0]?["message"]?["content"] ??
            "No response from AI";
      } else {
        return "Error: ${response.statusCode} - ${response.body}";
      }

    } catch (e) {
      return "Something went wrong: $e";
    }
  }
}