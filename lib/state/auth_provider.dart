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

  /// Session exists but email not yet confirmed.
  emailNotVerified,

  /// Fully authenticated — user can use the app.
  authenticated,
}

/// Manages authentication state and exposes sign-in, sign-up, sign-out actions.
///
/// Uses [Supabase.instance.client.auth.onAuthStateChange] to listen for
/// session changes automatically (login, logout, token refresh, email confirm).
class AuthNotifier extends Notifier<AppAuthState> {
  StreamSubscription<AuthState>? _subscription;
  String? _pendingEmail;

  /// The email address that's waiting for verification (for resending).
  String? get pendingEmail => _pendingEmail;

  @override
  AppAuthState build() {
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        final session = data.session;
        if (session != null) {
          _pendingEmail = session.user.email;
          if (session.user.emailConfirmedAt != null) {
            state = AppAuthState.authenticated;
          } else {
            state = AppAuthState.emailNotVerified;
          }
        } else {
          // If no session, only move to unauthenticated if we aren't already
          // in a pending verification state, OR if it's an explicit sign out.
          if (data.event == AuthChangeEvent.signedOut) {
            _pendingEmail = null;
            state = AppAuthState.unauthenticated;
          } else if (state != AppAuthState.emailNotVerified) {
            _pendingEmail = null;
            state = AppAuthState.unauthenticated;
          }
        }
      },
    );

    // Check if we already have a session from a previous launch.
    final currentSession = Supabase.instance.client.auth.currentSession;
    if (currentSession == null) {
      return AppAuthState.unauthenticated;
    }
    final user = currentSession.user;
    if (user.emailConfirmedAt != null) {
      return AppAuthState.authenticated;
    }
    _pendingEmail = user.email;
    return AppAuthState.emailNotVerified;
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

  /// Create a new account.
  ///
  /// Also sets the user's full_name in raw_user_meta_data so the
  /// `handle_new_user` database trigger can populate the profiles table.
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
      _pendingEmail = email.trim();

      // If email confirmation is not required, the user is signed in immediately.
      if (response.session != null) {
        state = AppAuthState.authenticated;
      } else {
        state = AppAuthState.emailNotVerified;
      }
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Resend the verification email to [pendingEmail].
  Future<String?> resendVerificationEmail() async {
    if (_pendingEmail == null) return 'No email address found.';
    try {
      await Supabase.instance.client.auth.resend(
        email: _pendingEmail!,
        type: OtpType.signup,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Could not resend verification email.';
    }
  }

  /// Sign out and clear all state.
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    _pendingEmail = null;
  }
}

/// The singleton auth provider used throughout the app.
final authProvider = NotifierProvider<AuthNotifier, AppAuthState>(
  AuthNotifier.new,
);
