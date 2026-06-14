import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../state/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

/// Shown after sign-up when email confirmation is required.
///
/// The [authProvider]'s [onAuthStateChange] listener automatically detects
/// when the user clicks the verification link and transitions the state to
/// [AuthState.authenticated]. No manual polling needed.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _isResending = false;
  bool _isChecking = false;

  Future<void> _resend() async {
    setState(() => _isResending = true);
    final error =
        await ref.read(authProvider.notifier).resendVerificationEmail();
    setState(() => _isResending = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? AppLocalizations.of(context).verificationEmailResent),
          backgroundColor: error == null ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _checkNow() async {
    setState(() => _isChecking = true);
    // Refresh the session — if the user verified in another tab/device,
    // this will pick it up.
    try {
      await Supabase.instance.client.auth.refreshSession();
    } catch (_) {
      // Session refresh may fail if token expired — that's fine.
    }
    // The onAuthStateChange stream in AuthNotifier will update state.
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _isChecking = false);
  }

  Future<void> _signOut() async {
    await ref.read(authProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final email = ref.read(authProvider.notifier).pendingEmail ?? 'your email';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Email icon with golden circle
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mark_email_unread_outlined,
                      size: 48, color: AppColors.gold),
                ),
                const SizedBox(height: 28),

                Text(
                  l10n.verifyEmail,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  '${l10n.verifyEmailSent}\n$email',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.warmGray,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  l10n.verifyEmailPrompt,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.warmGray.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 36),

                // Check now button
                OutlinedButton.icon(
                  onPressed: _isChecking ? null : _checkNow,
                  icon: _isChecking
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.gold),
                        )
                      : const Icon(Icons.refresh, color: AppColors.gold),
                  label: Text(
                    _isChecking ? l10n.checking : l10n.iveVerifiedCheckNow,
                    style: const TextStyle(color: AppColors.gold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.gold),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                // Resend button
                TextButton(
                  onPressed: _isResending ? null : _resend,
                  child: Text(
                    _isResending
                        ? l10n.resending
                        : l10n.resendVerificationEmail,
                    style: TextStyle(
                      color: AppColors.warmGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Divider
                Row(children: [
                  const Expanded(
                      child: Divider(color: AppColors.lightGray)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(l10n.or,
                        style: TextStyle(color: AppColors.warmGray)),
                  ),
                  const Expanded(
                      child: Divider(color: AppColors.lightGray)),
                ]),
                const SizedBox(height: 16),

                // Sign out
                TextButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout, color: AppColors.error,
                      size: 18),
                  label: Text(l10n.signOut,
                      style: const TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
