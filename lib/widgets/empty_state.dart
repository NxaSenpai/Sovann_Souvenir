import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final greyColor = isDark ? Colors.grey.shade600 : Colors.grey.shade300;
    final textColor = isDark ? Colors.grey.shade500 : Colors.grey;
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 80, color: greyColor),
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: textColor)),
        const SizedBox(height: 8),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
            textAlign: TextAlign.center),
      ]),
    );
  }
}