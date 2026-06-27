import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_colors.dart';
import '../../state/theme_provider.dart';
import '../../state/locale_provider.dart';
import '../../state/auth_provider.dart';
import '../../state/profile_provider.dart';
import '../../l10n/generated/app_localizations.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);
    final avatarUrl = ref.watch(avatarProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    final user = Supabase.instance.client.auth.currentUser;
    final displayName =
        user?.userMetadata?['full_name'] as String? ?? user?.email ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: ListView(
        children: [
          const SizedBox(height: 32),

          // ── Profile header ──
          Center(
            child: ClipOval(
              child: avatarUrl != null && avatarUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: avatarUrl,
                      width: 104,
                      height: 104,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _initialsCircle(displayName),
                      errorWidget: (_, __, ___) => _initialsCircle(displayName),
                    )
                  : _initialsCircle(displayName),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
          ),
          if (user?.email != null) ...[
            const SizedBox(height: 4),
            Text(
              user!.email!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? AppColors.cream.withAlpha(180)
                    : AppColors.warmGray,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.gold.withAlpha(25),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                _roleLabel(user?.userMetadata?['role'] as String?),
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          _sectionLabel(l10n.profileDetails),
          const SizedBox(height: 8),
          _groupedCard(
            children: [
              _settingRow(
                icon: Icons.person_outline,
                title: l10n.editProfile,
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.warmGray, size: 20),
                onTap: () => context.push('/profile/edit'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _sectionLabel(l10n.settings),
          const SizedBox(height: 8),
          _groupedCard(
            children: [
              _settingRow(
                icon: Icons.dark_mode_outlined,
                title: l10n.darkMode,
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (v) {
                    ref.read(themeModeProvider.notifier).setThemeMode(
                          v ? ThemeMode.dark : ThemeMode.light,
                        );
                  },
                  activeTrackColor: AppColors.gold.withAlpha(120),
                  activeColor: AppColors.gold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _sectionLabel(l10n.language),
          const SizedBox(height: 8),
          _groupedCard(
            children: [
              _settingRow(
                icon: Icons.language,
                title: languageNames[currentLocale.languageCode] ?? 'English',
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.warmGray, size: 20),
                onTap: () => _showLanguagePicker(context, ref),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _groupedCard(
            children: [
              _settingRow(
                icon: Icons.info_outline,
                title: l10n.about,
                subtitle: l10n.aboutVersion,
              ),
            ],
          ),

          const SizedBox(height: 32),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton(
              onPressed: () => ref.read(authProvider.notifier).signOut(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout, size: 18),
                  const SizedBox(width: 8),
                  Text(l10n.signOut),
                ],
              ),
            ),
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _initialsCircle(String name) {
    return CircleAvatar(
      radius: 52,
      backgroundColor: AppColors.gold.withAlpha(40),
      child: Text(
        _initials(name),
        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.gold),
      ),
    );
  }

  Widget _sectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: AppColors.warmGray.withAlpha(200),
        ),
      ),
    );
  }

  Widget _groupedCard({required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(60)
                : Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _settingRow({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppColors.gold.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.gold, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                  if (subtitle != null)
                    Text(subtitle,
                        style: TextStyle(fontSize: 12, color: AppColors.warmGray.withAlpha(200))),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return parts.first[0].toUpperCase();
  }

  String _roleLabel(String? role) {
    switch (role) {
      case 'artisan': return 'Artisan';
      case 'admin':   return 'Admin';
      default:        return 'Customer';
    }
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.warmGray.withAlpha(100),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              for (final locale in supportedLocales)
                ListTile(
                  title: Text(
                    languageNames[locale.languageCode] ?? 'English',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: ref.watch(localeProvider).languageCode == locale.languageCode
                      ? const Icon(Icons.check_circle, color: AppColors.gold, size: 22)
                      : null,
                  onTap: () {
                    ref.read(localeProvider.notifier).setLocale(locale);
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
