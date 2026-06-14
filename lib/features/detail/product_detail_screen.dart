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
import '../../l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    final product = repo.productsTr.firstWhere((p) => p.id == widget.productId);
    final artisan = repo.artisanByIdTr(product.artisanId);
    final isFav = ref.watch(favoritesProvider).contains(product.id);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          _imageCarousel(product, isFav),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 24),
              _productHeader(product),
              const SizedBox(height: 8),
              _ratingRow(product),
              const SizedBox(height: 16),
              _descriptionCard(product.description),
              const Divider(height: 32),
              if (artisan != null) ...[
                _artisanCard(artisan),
                const SizedBox(height: 24),
              ],
              _sectionTitle(l10n.details),
              const SizedBox(height: 10),
              _detailsCard(context, product.materials, product.dimensions),
              const SizedBox(height: 24),
              Text(l10n.theStory, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.gold)),
              const SizedBox(height: 8),
              _storyCard(product.story),
              const SizedBox(height: 24),
              _sectionTitle(l10n.tags),
              const SizedBox(height: 10),
              _tags(product.tags),
              const SizedBox(height: 24),
              _galleryButton(product.id),
              SizedBox(height: 24 + MediaQuery.of(context).padding.bottom),
            ]),
          ),
        ]),
      ),
    );
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
          itemBuilder: (context, i) => CachedNetworkImage(
            imageUrl: product.images[i],
            width: double.infinity,
            height: 340,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: AppColors.lightGray),
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
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => context.push('/reviews/${product.id}'),
      child: Row(children: [
        RatingStars(rating: product.rating),
        const SizedBox(width: 8),
        Text(product.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(' (${product.reviewCount})', style: const TextStyle(color: AppColors.warmGray, fontSize: 14)),
        const Spacer(),
        Text(l10n.seeAllReviews, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w500, fontSize: 14)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.ivory,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: TextStyle(
        fontSize: 15, height: 1.6,
        color: isDark ? AppColors.cream : AppColors.charcoal,
      )),
    );
  }

  Widget _storyCard(String story) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.auto_stories, size: 20, color: AppColors.gold.withOpacity(0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(story, style: TextStyle(
            fontSize: 15, height: 1.6,
            color: isDark ? AppColors.cream.withOpacity(0.8) : AppColors.warmGray,
            fontStyle: FontStyle.italic,
          )),
        ),
      ]),
    );
  }

  Widget _artisanCard(Artisan artisan) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.push('/artisan/${artisan.id}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightGray.withOpacity(0.3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkSurface : AppColors.lightGray,
            width: 1,
          ),
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

  Widget _detailsCard(BuildContext context, String materials, String dimensions) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkSurface : AppColors.lightGray,
          width: 1,
        ),
      ),
      child: Column(children: [
        _specRow(context, l10n.materials, materials),
        const SizedBox(height: 14),
        Divider(
          color: isDark ? AppColors.darkSurface : AppColors.lightGray,
          height: 1, thickness: 1,
        ),
        const SizedBox(height: 14),
        _specRow(context, l10n.dimensions, dimensions),
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

  Widget _galleryButton(String productId) {
    final l10n = AppLocalizations.of(context);
    return OutlinedButton.icon(
      onPressed: () => context.push('/gallery/$productId'),
      icon: const Icon(Icons.photo_library_outlined),
      label: Text(l10n.viewGallery),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.gold,
        side: const BorderSide(color: AppColors.gold),
        minimumSize: const Size(double.infinity, 48),
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
