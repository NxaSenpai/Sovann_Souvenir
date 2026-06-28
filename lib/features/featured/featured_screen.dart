import 'package:flutter/material.dart';
import '../../data/mock_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/product_card.dart';
import '../../l10n/generated/app_localizations.dart';

class FeaturedScreen extends StatelessWidget {
  const FeaturedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final products = MockRepository.instance.featuredTr;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.cream,
      appBar: AppBar(
        title: Text(l10n.featured, style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: isDark ? AppColors.darkBg : AppColors.cream,
      ),
      body: products.isEmpty
          ? Center(child: Text('No featured products', style: TextStyle(color: AppColors.warmGray)))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 0.68),
              itemCount: products.length,
              itemBuilder: (context, i) => ProductCard(product: products[i]),
            ),
    );
  }
}
