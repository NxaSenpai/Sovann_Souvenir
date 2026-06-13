import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_repository.dart';
import '../../models/artisan.dart';
import '../../models/product.dart';
import '../../state/favorites_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/rating_stars.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});
  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final _pageController = PageController();
  int _currentImage = 0;
  final repo = MockRepository.instance;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = repo.products.firstWhere((p) => p.id == widget.productId);
    final artisan = repo.artisanById(product.artisanId);
    final isFav = ref.watch(favoritesProvider).contains(product.id);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          // --- Image Carousel ---
          _imageCarousel(product, isFav),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 24),
              _productHeader(product),
              const SizedBox(height: 8),
              _ratingRow(product),
              const SizedBox(height: 16),
              const Divider(height: 32),

              // Artisan info
              if (artisan != null) _artisanCard(artisan),

              // Story
              const SizedBox(height: 20),
              _sectionTitle('The Story'),
              const SizedBox(height: 10),
              _storyCard(product.story),

              // Description
              const SizedBox(height: 20),
              _sectionTitle('Description'),
              const SizedBox(height: 10),
              _descriptionCard(product.description),

              // Details
              const SizedBox(height: 20),
              _sectionTitle('Details'),
              const SizedBox(height: 10),
              _detailsCard(product.materials, product.dimensions),

              // Tags
              const SizedBox(height: 20),
              _sectionTitle('Tags'),
              const SizedBox(height: 10),
              _tags(product.tags),

              // Actions
              const SizedBox(height: 24),
              _galleryButton(product.id),
              const SizedBox(height: 12),
              _bookingButton(product.id),
              const SizedBox(height: 32),
            ]),
          ),
        ]),
    ));
  }

  // ──────────────────────────────────────
  // Widgets
  // ──────────────────────────────────────

  Widget _imageCarousel(Product product, bool isFav) {
    return SizedBox(
      height: 340,
      child: Stack(children: [
        PageView.builder(
          controller: _pageController,
          itemCount: product.images.length,
          onPageChanged: (i) => setState(() => _currentImage = i),
          itemBuilder: (context, i) => Container(
            color: AppColors.lightGray,
            child: CachedNetworkImage(
              imageUrl: product.images[i],
              width: double.infinity,
              height: 340,
              fit: BoxFit.contain,
              placeholder: (_, __) => const SizedBox(),
            ),
          ),
        ),
        Positioned(top: 52, left: 16,
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.9),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
              onPressed: () => context.pop(),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        Positioned(top: 52, right: 16,
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.9),
            child: IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.red : AppColors.charcoal,
              ),
              onPressed: () => ref.read(favoritesProvider.notifier).toggle(product.id),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        if (product.images.length > 1)
          Positioned(
            bottom: 16, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(product.images.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentImage == i ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentImage == i ? AppColors.gold : Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(3),
                ),
              )),
            ),
          ),
      ]),
    );
  }

  Widget _productHeader(Product product) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.2)),
        ),
        const SizedBox(width: 16),
        Text('\$${product.price.toStringAsFixed(2)}',
            style: const TextStyle(color: AppColors.gold, fontSize: 22, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _ratingRow(Product product) {
    return GestureDetector(
      onTap: () => context.push('/reviews/${product.id}'),
      child: Row(children: [
        RatingStars(rating: product.rating),
        const SizedBox(width: 8),
        Text(product.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(' (${product.reviewCount})', style: const TextStyle(color: AppColors.warmGray, fontSize: 14)),
        const Spacer(),
        Text('See all reviews', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w500, fontSize: 14)),
        Icon(Icons.chevron_right, color: AppColors.gold, size: 18),
      ]),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(children: [
      Container(width: 3, height: 18, color: AppColors.gold),
      const SizedBox(width: 10),
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
    ]);
  }

  Widget _descriptionCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.ivory,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.charcoal)),
    );
  }

  Widget _storyCard(String story) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.auto_stories, size: 20, color: AppColors.gold.withOpacity(0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(story, style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.warmGray, fontStyle: FontStyle.italic)),
        ),
      ]),
    );
  }

  Widget _artisanCard(Artisan artisan) {
    return GestureDetector(
      onTap: () => context.push('/artisan/${artisan.id}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.goldLight.withOpacity(0.4)),
        ),
        child: Row(children: [
          CircleAvatar(backgroundImage: CachedNetworkImageProvider(artisan.avatar)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Made by ${artisan.name}', style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(artisan.region,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
            ]),
          ),
          const Icon(Icons.chevron_right, color: AppColors.gold),
        ]),
      ),
    );
  }

  Widget _detailsCard(String materials, String dimensions) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGray, width: 1),
      ),
      child: Column(children: [
        _specRow(context, 'Materials', materials),
        const SizedBox(height: 14),
        Divider(color: AppColors.lightGray, height: 1, thickness: 1),
        const SizedBox(height: 14),
        _specRow(context, 'Dimensions', dimensions),
      ]),
    );
  }

  Widget _tags(List<String> tags) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: tags.map((tag) => Chip(
        label: Text(tag, style: const TextStyle(fontSize: 11)),
      )).toList(),
    );
  }

  Widget _bookingButton(String productId) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.event_outlined),
        label: const Text('Book Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        onPressed: () => context.push('/booking/$productId'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _galleryButton(String productId) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.photo_library_outlined),
        label: const Text('View Gallery'),
        onPressed: () => context.push('/gallery/$productId'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _specRow(BuildContext context, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      SizedBox(width: 100, child: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 13))),
      Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
    ]),
  );
}
