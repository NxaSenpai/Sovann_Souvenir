import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../state/favorites_provider.dart';
import '../theme/app_colors.dart';
import 'rating_stars.dart';

class ProductCard extends ConsumerWidget {
  final Product product;
  final double width;
  const ProductCard({super.key, required this.product, this.width = 180});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favoritesProvider).contains(product.id);

    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
      child: Container(
        width: width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black.withOpacity(0.05)
                  : Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4)
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Image
          Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: product.images.first,
                height: 140, width: double.infinity, fit: BoxFit.cover,
                placeholder: (c, u) => Container(color: Theme.of(context).colorScheme.surfaceContainerHighest, height: 140),
                errorWidget: (c, u, e) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest, height: 140,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            Positioned(
              top: 8, right: 8,
              child: GestureDetector(
                onTap: () => ref.read(favoritesProvider.notifier).toggle(product.id),
                child: CircleAvatar(
                  radius: 18, 
                  backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : AppColors.warmGray, size: 18,
                  ),
                ),
              ),
            ),
          ]),
          // Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              RatingStars(rating: product.rating, size: 12),
              const SizedBox(height: 4),
              Text('\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 15)),
            ]),
          ),
        ]),
      ),
    );
  }
}