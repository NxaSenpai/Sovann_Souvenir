import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/product_card.dart';
import '../../l10n/generated/app_localizations.dart';

class CollectionDetailScreen extends StatelessWidget {
  final String collectionId;
  const CollectionDetailScreen({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo = MockRepository.instance;
    final col = repo.collectionByIdTr(collectionId)!;
    final products = repo.byCollectionTr(collectionId);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.cream,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          stretch: true,
          backgroundColor: isDark ? AppColors.darkBg : AppColors.cream,
          leading: IconButton(
            icon: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withAlpha(180) : Colors.white.withAlpha(230),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_rounded,
                  color: isDark ? Colors.white : AppColors.charcoal, size: 22),
            ),
            onPressed: () => context.pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(col.tag,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                Text(col.name,
                    style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white,
                      shadows: [Shadow(blurRadius: 12, color: Colors.black45)],
                    )),
              ],
            ),
            background: Stack(fit: StackFit.expand, children: [
              CachedNetworkImage(imageUrl: col.coverImage, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withAlpha(180)],
                  ),
                ),
              ),
            ]),
          ),
        ),

        // Description
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.info_outline_rounded, size: 16,
                  color: AppColors.gold.withAlpha(isDark ? 200 : 180)),
              const SizedBox(width: 8),
              Text(l10n.collections,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.cream.withAlpha(170) : AppColors.warmGray)),
            ]),
            const SizedBox(height: 10),
            Text(col.description,
                style: TextStyle(fontSize: 15, height: 1.6,
                    color: isDark ? AppColors.cream : AppColors.charcoal)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.gold.withAlpha(isDark ? 40 : 20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.gold),
                const SizedBox(width: 8),
                Text('${l10n.itemsCount(products.length)}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.gold)),
              ]),
            ),
          ]),
        )),

        // Product grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 0.68),
            delegate: SliverChildBuilderDelegate(
                  (context, i) => ProductCard(product: products[i]),
              childCount: products.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: 40 + MediaQuery.of(context).padding.bottom),
        ),
      ]),
    );
  }
}
