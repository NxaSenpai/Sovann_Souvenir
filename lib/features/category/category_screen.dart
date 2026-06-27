import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_repository.dart';
import '../../theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/product_card.dart';

class CategoryScreen extends StatelessWidget {
  final String categoryId;
  const CategoryScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo = MockRepository.instance;
    final l10nMap = <String, String>{
      'textile': l10n.textile, 'silver': l10n.silver, 'wood': l10n.wood,
      'edible': l10n.edible, 'jewelry': l10n.jewelry,
    };
    final category = repo.categoriesTr.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => repo.categoriesTr.first,
    );
    final catName = l10nMap[categoryId] ?? category.name;
    final products = repo.byCategoryTr(categoryId);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.cream,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.cream,
        title: Row(children: [
          Text(category.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Text(catName, style: const TextStyle(fontWeight: FontWeight.w800)),
        ]),
      ),
      body: products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(category.emoji, style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text('No products in this category yet',
                      style: TextStyle(
                          fontSize: 16,
                          color: isDark ? AppColors.cream.withAlpha(140) : AppColors.warmGray)),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.68,
              ),
              itemCount: products.length,
              itemBuilder: (context, i) => ProductCard(product: products[i]),
            ),
    );
  }
}
