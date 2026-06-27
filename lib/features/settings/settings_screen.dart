import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../state/theme_provider.dart';
import '../../state/locale_provider.dart';
import '../../l10n/generated/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(children: [
        ListTile(
          leading: const Icon(Icons.notifications_outlined, color: AppColors.gold),
          title: Text(l10n.notifications),
          trailing: Switch(
            value: _notifications,
            onChanged: (v) => setState(() => _notifications = v),
            activeColor: AppColors.gold
          ),
        ),
        ListTile(
          leading: const Icon(Icons.dark_mode_outlined, color: AppColors.gold),
          title: Text(l10n.darkMode),
          trailing: Switch(
            value: isDarkMode,
            onChanged: (v) {
              ref.read(themeModeProvider.notifier).setThemeMode(
                v ? ThemeMode.dark : ThemeMode.light
              );
            },
            activeColor: AppColors.gold
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.language, color: AppColors.gold),
          title: Text(l10n.language),
          subtitle: Text(languageNames[currentLocale.languageCode] ?? 'English'),
          trailing: const Icon(Icons.chevron_right, color: AppColors.warmGray),
          onTap: () => _showLanguagePicker(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline, color: AppColors.gold),
          title: Text(l10n.about),
          subtitle: Text(l10n.aboutVersion),
        ),
      ]),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final locale in supportedLocales)
              ListTile(
                title: Text(languageNames[locale.languageCode] ?? 'English'),
                trailing: ref.watch(localeProvider).languageCode == locale.languageCode
                    ? const Icon(Icons.check, color: AppColors.gold)
                    : null,
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(locale);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }
}