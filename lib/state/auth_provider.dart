import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Represents the current authentication state of the user.
///
/// Named [AppAuthState] to avoid ambiguity with Supabase's internal `AuthState`.
enum AppAuthState {
  /// Still checking if there's an existing session.
  loading,

  /// No session — user needs to log in or sign up.
  unauthenticated,

  /// Fully authenticated — user can use the app.
  authenticated,
}

/// Manages authentication state and exposes sign-in, sign-up, sign-out actions.
///
/// Uses [Supabase.instance.client.auth.onAuthStateChange] to listen for
/// session changes automatically (login, logout, token refresh).
class AuthNotifier extends Notifier<AppAuthState> {
  StreamSubscription<AuthState>? _subscription;

  @override
  AppAuthState build() {
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        final session = data.session;
        if (session != null) {
          state = AppAuthState.authenticated;
        } else {
          state = AppAuthState.unauthenticated;
        }
      },
    );

    // Check if we already have a session from a previous launch.
    final currentSession = Supabase.instance.client.auth.currentSession;
    if (currentSession != null) {
      return AppAuthState.authenticated;
    }
    return AppAuthState.unauthenticated;
  }

  /// Sign in with email and password.
  ///
  /// Returns null on success, or an error message string on failure.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Create a new account and sign in immediately — no email verification.
  ///
  /// Sets the user's full_name in raw_user_meta_data so the
  /// `handle_new_user` database trigger can populate the profiles table.
  ///
  /// A database trigger (`auto_confirm_email_trigger`) auto-confirms the
  /// user's email before the row is inserted, so no verification is needed.
  /// Returns null on success, or an error message on failure.
  Future<String?> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName.trim()},
      );

      // Trigger auto-confirms email, so we should have a session.
      if (response.session != null) return null;

      // Fallback: sign in manually if session wasn't returned.
      await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Sign out and clear all state.
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}

/// The singleton auth provider used throughout the app.
final authProvider = NotifierProvider<AuthNotifier, AppAuthState>(
  AuthNotifier.new,
);
