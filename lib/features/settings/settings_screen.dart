import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../state/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark || 
        (themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(children: [
        ListTile(
          leading: const Icon(Icons.notifications_outlined, color: AppColors.gold),
          title: const Text('Notifications'),
          trailing: Switch(
            value: _notifications, 
            onChanged: (v) => setState(() => _notifications = v), 
            activeColor: AppColors.gold
          ),
        ),
        ListTile(
          leading: const Icon(Icons.dark_mode_outlined, color: AppColors.gold),
          title: const Text('Dark Mode'),
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
        ListTile(leading: const Icon(Icons.language), title: const Text('Language'), subtitle: const Text('English')),
        ListTile(leading: const Icon(Icons.info_outline), title: const Text('About'), subtitle: const Text('Sovann Souvenir v1.0.0')),
      ]),
    );
  }
}