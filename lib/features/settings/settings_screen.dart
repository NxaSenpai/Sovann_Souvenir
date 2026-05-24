import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(children: [
        ListTile(
          leading: const Icon(Icons.notifications_outlined, color: AppColors.gold),
          title: const Text('Notifications'),
          trailing: Switch(value: _notifications, onChanged: (v) => setState(() => _notifications = v), activeColor: AppColors.gold),
        ),
        ListTile(
          leading: const Icon(Icons.dark_mode_outlined, color: AppColors.gold),
          title: const Text('Dark Mode'),
          trailing: Switch(value: _darkMode, onChanged: (v) => setState(() => _darkMode = v), activeColor: AppColors.gold),
        ),
        const Divider(),
        ListTile(leading: const Icon(Icons.language), title: const Text('Language'), subtitle: const Text('English')),
        ListTile(leading: const Icon(Icons.info_outline), title: const Text('About'), subtitle: const Text('Sovann Souvenir v1.0.0')),
      ]),
    );
  }
}