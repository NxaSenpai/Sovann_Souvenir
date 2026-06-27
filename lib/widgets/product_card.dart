import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../state/favorites_provider.dart';
import '../theme/app_colors.dart';
import 'rating_stars.dart';

class ProductCard extends ConsumerStatefulWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _favController;
  late final Animation<double> _favScale;

  @override
  void initState() {
    super.initState();
    _favController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _favScale = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _favController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _favController.dispose();
    super.dispose();
  }

  void _toggleFav() {
    ref.read(favoritesProvider.notifier).toggle(widget.product.id);
    _favController.forward().then((_) => _favController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final isFav  = ref.watch(favoritesProvider).contains(widget.product.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p      = widget.product;

    return GestureDetector(
      onTap: () => context.push('/product/${p.id}'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth  = constraints.maxWidth;
          // Image takes ~65% of card width — proportional on any screen size
          final imageHeight = cardWidth * 0.78;

          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withAlpha(110)
                      : AppColors.gold.withAlpha(22),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 6),
                ),
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── IMAGE SECTION ───────────────────────────────────────────
                Stack(children: [

                  // Photo
                  Hero(
                    tag: 'product-image-${p.id}',
                    child: CachedNetworkImage(
                      imageUrl: p.images.first,
                      height: imageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _ImagePlaceholder(
                          height: imageHeight, isDark: isDark),
                      errorWidget: (_, __, ___) => _ImagePlaceholder(
                          height: imageHeight, isDark: isDark, isError: true),
                    ),
                  ),

                  // Three-stop gradient: dark bottom, transparent mid, faint gold top tint
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.gold.withAlpha(20),
                            Colors.transparent,
                            Colors.black.withAlpha(145),
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Category chip — top left
                  Positioned(
                    top: 10, left: 10,
                    child: _CategoryChip(category: p.categoryId),
                  ),

                  // Favourite button — top right
                  Positioned(
                    top: 8, right: 8,
                    child: ScaleTransition(
                      scale: _favScale,
                      child: GestureDetector(
                        onTap: _toggleFav,
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            // White glassy circle
                            color: Colors.white.withAlpha(isDark ? 35 : 230),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(30),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? Colors.redAccent : AppColors.warmGray,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Price pill — bottom left, overlapping image/info border
                  Positioned(
                    bottom: 0, left: 10,
                    child: Transform.translate(
                      offset: const Offset(0, 14), // half-bleeds into info section
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.gold, AppColors.goldDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withAlpha(80),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          '\$${p.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),

                // ── INFO SECTION ────────────────────────────────────────────
                Padding(
                  // Extra top padding to clear the half-bled price pill
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Product name
                      Text(
                        p.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          height: 1.3,
                          color: isDark ? AppColors.cream : AppColors.charcoal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      // Stars + review count
                      Row(children: [
                        RatingStars(rating: p.rating, size: 11),
                        const SizedBox(width: 5),
                        Text(
                          '(${p.reviewCount})',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.warmGray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Category chip ────────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final String category;
  const _CategoryChip({required this.category});

  static const _labels = {
    'textile': ('', 'Textile'),
    'silver':  ('', 'Silver'),
    'wood':    ('', 'Wood'),
    'edible':  ('', 'Edible'),
    'jewelry': ('', 'Jewelry'),
  };

  @override
  Widget build(BuildContext context) {
    final entry = _labels[category] ?? ('✦', category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(110),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(entry.$1, style: const TextStyle(fontSize: 10)),
        const SizedBox(width: 4),
        Text(
          entry.$2,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ]),
    );
  }
}

// ── Image placeholder / error ────────────────────────────────────────────────
class _ImagePlaceholder extends StatelessWidget {
  final double height;
  final bool isDark;
  final bool isError;
  const _ImagePlaceholder({
    required this.height,
    required this.isDark,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: isDark ? AppColors.darkCard : AppColors.lightGray,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(
          isError ? Icons.broken_image_outlined : Icons.image_outlined,
          color: AppColors.warmGray.withAlpha(100),
          size: 28,
        ),
        if (isError) ...[
          const SizedBox(height: 4),
          Text(
            'Image not found',
            style: TextStyle(
              fontSize: 9,
              color: AppColors.warmGray.withAlpha(120),
            ),
          ),
        ],
      ]),
    );
  }
}