import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported locales for the app.
const supportedLocales = [
  Locale('en'),
  Locale('km'),
  Locale('zh'),
  Locale('ja'),
  Locale('vi'),
];

/// Display names for each supported language (in its own script).
const languageNames = {
  'en': 'English',
  'km': 'ភាសាខ្មែរ',
  'zh': '中文',
  'ja': '日本語',
  'vi': 'Tiếng Việt',
};

/// Manages the active locale, persisted via SharedPreferences.
class LocaleNotifier extends Notifier<Locale> {
  static const _key = 'app_locale';

  @override
  Locale build() {
    // Schedule async load; return English as default.
    _loadFromPrefs();
    return const Locale('en');
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null) {
      final locale = Locale(code);
      if (supportedLocales.any((l) => l.languageCode == locale.languageCode)) {
        state = locale;
      }
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
