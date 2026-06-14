import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/mock_repository.dart';
import 'data/content_translations.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase — this handles auth persistence, session
  // restoration, and deep link handling automatically.
  await Supabase.initialize(
    url: 'https://rzagrbcpjfylllpxpzty.supabase.co',
    publishableKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ6YWdyYmNwamZ5bGxscHhwenR5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk2MDE2OTQsImV4cCI6MjA5NTE3NzY5NH0.JS6g2T8BzuvDutymYFm_-WdO09mplgy5E8W_cuhiNkU',
  );

  // Load mock data (will be replaced by Supabase queries in later phases).
  await MockRepository.instance.init();

  // Load content translations for the 5 supported languages.
  await ContentTranslations.init();

  runApp(
    const ProviderScope(
      child: SovannSouvenirApp(),
    ),
  );
}
