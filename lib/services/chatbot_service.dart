import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../data/mock_repository.dart';

class ChatbotService {
  static String get _apiKey =>
      dotenv.env['OPENROUTER_API_KEY'] ?? '';
  static const _endpoint = 'https://openrouter.ai/api/v1/chat/completions';
  static const _model = 'nvidia/nemotron-3-ultra-550b-a55b:free';

  static String _buildSystemPrompt() {
    final products = MockRepository.instance.productsTr;
    final productList = products.map((p) =>
        '${p.name} (\$${p.price.toStringAsFixed(2)}, ${p.rating}★, ID:${p.id})'
    ).join('; ');

    return '''
You are Sovann, a friendly gift-shopping assistant for Sovann Souvenir, a Cambodian souvenir shop.
Categories: textile🧵, silver🥈, wood🪵, edible🫙, jewelry💎

Our products: $productList

When recommending products:
- First write your recommendation text naturally mentioning the product names
- Then list ALL product tags together at the END like: [PRODUCT:p1] [PRODUCT:p3]
- Example: "I think you'll love our Surprise Doll Balloon Box for its charm, and the Wooden Flower Sculpture for elegance. [PRODUCT:p1] [PRODUCT:p9]"
Keep replies short (2-4 sentences). Be warm. If no match, suggest browsing.
''';
  }

  /// Send conversation history, returns AI response text.
  static Future<String> sendChat(List<Map<String, String>> messages) async {
    // Keep last 10 messages to stay within context limits
    final trimmed = messages.length > 10
        ? messages.sublist(messages.length - 10)
        : messages;

    final formatted = [
      {'role': 'system', 'content': _buildSystemPrompt()},
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
          'max_tokens': 700,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else if (response.statusCode == 429) {
        return 'I\'m a bit busy right now! Please wait a moment and try again. 🙏';
      } else {
        return 'Sorry, I had a hiccup (${response.statusCode}). Please try again.';
      }
    } catch (e) {
      return 'Connection issue — please check your internet and try again. ✨';
    }
  }
}

/// Parses AI response text into structured segments — text and product cards.
class ChatMessageParser {
  static final _productRegex = RegExp(r'\[PRODUCT:(\w+)\]');

  /// Returns a list of segments. Each segment is either a text string
  /// or a Product ID (prefixed with '@' to distinguish).
  static List<String> parse(String text) {
    final segments = <String>[];
    int lastEnd = 0;

    for (final match in _productRegex.allMatches(text)) {
      // Text before this product tag
      if (match.start > lastEnd) {
        segments.add(text.substring(lastEnd, match.start));
      }
      // Product ID
      segments.add('@${match.group(1)}');
      lastEnd = match.end;
    }

    // Remaining text
    if (lastEnd < text.length) {
      segments.add(text.substring(lastEnd));
    }

    return segments.isEmpty ? [text] : segments;
  }
}
