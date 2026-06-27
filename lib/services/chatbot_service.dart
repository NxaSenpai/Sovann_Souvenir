import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatbotService {
  static String get _apiKey =>
      dotenv.env['OPENROUTER_API_KEY'] ?? '';
  static const _endpoint = 'https://openrouter.ai/api/v1/chat/completions';
  static const _model = 'nvidia/nemotron-3-ultra-550b-a55b:free';

  static const _systemPrompt = '''
You are Sovann, a friendly gift-shopping assistant for **Sovann Souvenir**, a Cambodian artisan souvenir shop. Help users find gifts by asking about who it's for, budget, and style.

## Categories:
- Textile 🧵 — krama scarves, silk wraps, plush toys
- Silver 🥈 — jewelry, engraved boxes, ornaments
- Wood 🪵 — carved statues, decorative boxes
- Edible 🫙 — palm sugar, spices, tea sets
- Jewelry 💎 — gemstone pendants, gold accessories

## Featured products:
1. Surprise Doll Balloon Box — \$24.00 (textile)
2. Romantic Pink Roses & Big Teddy Set — \$42.00 (silver)
3. Hand-carved Wooden Elephant Statue — \$35.00 (wood)
4. Organic Palm Sugar Gift Set — \$12.00 (edible)
5. Khmer Silk Krama Scarf — \$18.50 (textile)
6. Sterling Silver Earrings — \$28.00 (jewelry)
7. Spice Collection Box — \$15.00 (edible)
8. Buddha Wood Carving — \$48.00 (wood)

Keep replies warm and concise (2-4 sentences). Use occasional emoji. Be conversational.
''';

  /// Send a conversation with automatic history trimming.
  static Future<String> sendChat(List<Map<String, String>> messages) async {
    // Keep only last 8 messages to stay within free model context limits
    final trimmed = messages.length > 8 ? messages.sublist(messages.length - 8) : messages;

    final formatted = [
      {'role': 'system', 'content': _systemPrompt},
      ...trimmed.map((m) => {'role': m['role'], 'content': m['content']}),
    ];

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'https://sovann-souvenir.app',
          'X-Title': 'Sovann Souvenir',
        },
        body: jsonEncode({
          'model': _model,
          'messages': formatted,
          'temperature': 0.7,
          'max_tokens': 600,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else if (response.statusCode == 429) {
        return 'I\'m a bit busy right now! Please wait a moment and try again. 🙏';
      } else {
        // Log the actual error for debugging
        final body = response.body;
        return 'Sorry, I had a hiccup. Try again? ($body)';
      }
    } catch (e) {
      return 'Connection issue — please check your internet and try again. ✨';
    }
  }
}
