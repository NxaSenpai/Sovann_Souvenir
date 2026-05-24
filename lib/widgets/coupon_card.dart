import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/promotion.dart';
import '../theme/app_colors.dart';

class CouponCard extends StatelessWidget {
  final Promotion promo;
  const CouponCard({super.key, required this.promo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(children: [
        // Left color strip
        Container(
          width: 12,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
          ),
        ),
        const SizedBox(width: 16),
        // Content
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(promo.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 4),
            Text(promo.subtitle, style: const TextStyle(fontSize: 13, color: AppColors.warmGray)),
            const SizedBox(height: 8),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gold, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(promo.code, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: promo.code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code copied!')),
                  );
                },
                child: const Icon(Icons.copy, size: 16, color: AppColors.warmGray),
              ),
            ]),
          ],
        )),
        // Discount badge
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Text(promo.discount, style: const TextStyle(
                color: AppColors.gold, fontWeight: FontWeight.w900, fontSize: 18)),
            Text('OFF', style: TextStyle(color: AppColors.warmGray, fontSize: 11)),
          ]),
        ),
      ]),
    );
  }
}