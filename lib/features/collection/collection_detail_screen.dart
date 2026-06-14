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
    final repo = MockRepository.instance;
    final col = repo.collectionByIdTr(collectionId)!;
    final products = repo.byCollectionTr(collectionId);

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          leading: IconButton(
            icon: const CircleAvatar(backgroundColor: Colors.white70, child: Icon(Icons.arrow_back, color: Colors.black)),
            onPressed: () => context.pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(col.name, style: const TextStyle(fontWeight: FontWeight.w800, shadows: [Shadow(blurRadius: 4, color: Colors.black38)])),
            background: CachedNetworkImage(imageUrl: col.coverImage, fit: BoxFit.cover),
          ),
        ),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(50)),
              child: Text(col.tag, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
            const SizedBox(height: 12),
            Text(col.description, style: const TextStyle(color: AppColors.warmGray, height: 1.6)),
            const SizedBox(height: 20),
            Text(l10n.itemsCount(products.length), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ]),
        )),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.67),
            delegate: SliverChildBuilderDelegate(
                  (context, i) => ProductCard(product: products[i], width: double.infinity),
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