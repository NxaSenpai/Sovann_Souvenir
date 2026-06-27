import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class KhmerPatternDivider extends StatelessWidget {
  const KhmerPatternDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Expanded(child: Divider(color: AppColors.gold, thickness: 0.8)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text('✦', style: TextStyle(color: AppColors.gold, fontSize: 16)),
      ),
      const Expanded(child: Divider(color: AppColors.gold, thickness: 0.8)),
    ]);
  }
}