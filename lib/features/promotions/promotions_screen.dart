import 'package:flutter/material.dart';
import '../../data/mock_repository.dart';
import '../../widgets/coupon_card.dart';
import '../../l10n/generated/app_localizations.dart';

class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final promos = MockRepository.instance.promotions;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.promotionsAndCoupons)),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: promos.length,
        itemBuilder: (context, i) => CouponCard(promo: promos[i]),
      ),
    );
  }
}