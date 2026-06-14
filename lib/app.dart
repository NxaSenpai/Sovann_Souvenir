import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'router/app_router.dart';
import 'state/theme_provider.dart';
import 'state/auth_provider.dart';
import 'state/locale_provider.dart';
import 'data/mock_repository.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/auth/verify_email_screen.dart';
import 'l10n/generated/app_localizations.dart';

/// Root widget — acts as the authentication gate.
///
/// Watches [authProvider] and displays the appropriate screen:
/// - [AuthState.loading]          → splash spinner
/// - [AuthState.unauthenticated]  → login / sign-up flow
/// - [AuthState.emailNotVerified] → email verification prompt
/// - [AuthState.authenticated]    → the main app (with theme and GoRouter)
class SovannSouvenirApp extends ConsumerWidget {
  const SovannSouvenirApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    // Keep MockRepository in sync with the active locale so
    // translated getters return content in the user's language.
    MockRepository.instance.setLocale(locale.languageCode);

    switch (authState) {
      case AppAuthState.loading:
        return MaterialApp(
          key: const ValueKey('auth_loading'),
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: ref.watch(localeProvider),
          home: const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
          ),
        );

      case AppAuthState.unauthenticated:
        // Auth flow — uses named routes for login ↔ signup navigation.
        return MaterialApp(
          key: const ValueKey('auth_unauthenticated'),
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: ref.watch(localeProvider),
          initialRoute: '/login',
          routes: {
            '/login': (_) => const LoginScreen(),
            '/signup': (_) => const SignUpScreen(),
          },
        );

      case AppAuthState.emailNotVerified:
        return MaterialApp(
          key: const ValueKey('auth_unverified'),
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: ref.watch(localeProvider),
          home: const VerifyEmailScreen(),
        );

      case AppAuthState.authenticated:
        // The main application shell with GoRouter and dual-theme support.
        return MaterialApp.router(
          key: const ValueKey('auth_authenticated'),
          title: 'Sovann Souvenir',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: ref.watch(localeProvider),
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            // Apply Hanuman font for Khmer locale
            if (Localizations.localeOf(context).languageCode == 'km') {
              return DefaultTextStyle.merge(
                style: const TextStyle(fontFamily: 'Hanuman'),
                child: child!,
              );
            }
            return child!;
          },
        );
    }
  }
}
