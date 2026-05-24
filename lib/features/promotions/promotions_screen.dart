import 'package:flutter/material.dart';
import '../../data/mock_repository.dart';
import '../../widgets/coupon_card.dart';

class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final promos = MockRepository.instance.promotions;
    return Scaffold(
      appBar: AppBar(title: const Text('Promotions & Coupons')),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: promos.length,
        itemBuilder: (context, i) => CouponCard(promo: promos[i]),
      ),
    );
  }
}