import 'dart:convert';
import 'package:flutter/services.dart';

/// Singleton that loads translated content from `assets/i18n/content.json`
/// and applies translation overlays at runtime.
///
/// The JSON structure:
/// ```json
/// {
///   "km": {
///     "products": { "p1": { "name": "ក្រមា", "description": "..." } }
///   },
///   "zh": { ... }
/// }
/// ```
class ContentTranslations {
  ContentTranslations._();

  static ContentTranslations? _instance;
  static ContentTranslations get instance => _instance!;

  final Map<String, Map<String, Map<String, Map<String, dynamic>>>> _data = {};

  static Future<void> init() async {
    _instance = ContentTranslations._();
    try {
      final raw = await rootBundle.loadString('assets/i18n/content.json');
      final parsed = json.decode(raw) as Map<String, dynamic>;
      for (final locale in parsed.keys) {
        _instance!._data[locale] = {};
        final langData = parsed[locale] as Map<String, dynamic>;
        for (final entityType in langData.keys) {
          _instance!._data[locale]![entityType] = {};
          final entities = langData[entityType] as Map<String, dynamic>;
          for (final id in entities.keys) {
            _instance!._data[locale]![entityType]![id] =
                Map<String, dynamic>.from(entities[id] as Map);
          }
        }
      }
    } catch (_) {
      // content.json may not exist yet — that's OK, fall back to English.
    }
  }

  /// Returns the translation overlay for [entityType] and [id] in [locale],
  /// or null if no translation exists.
  Map<String, dynamic>? get(
    String locale,
    String entityType,
    String id,
  ) {
    return _data[locale]?[entityType]?[id];
  }

  /// Merges [translation] fields into [base], returning a new map.
  /// Any field present in [translation] overrides the corresponding field
  /// in [base]. Fields only in [base] are preserved.
  static Map<String, dynamic> merge(
    Map<String, dynamic> base,
    Map<String, dynamic>? translation,
  ) {
    if (translation == null) return Map.of(base);
    return {...base, ...translation};
  }
}
