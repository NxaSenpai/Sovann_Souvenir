import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_repository.dart';
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
  Widget build(BuildContext context) {
    final product = repo.products.firstWhere((p) => p.id == widget.productId);
    final artisan = repo.artisanById(product.artisanId);
    final isFav = ref.watch(favoritesProvider).contains(product.id);

    return Scaffold(
      body: CustomScrollView(slivers: [
        // Image Gallery as SliverAppBar
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          leading: IconButton(
            icon: const CircleAvatar(backgroundColor: Colors.white70, child: Icon(Icons.arrow_back, color: Colors.black)),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: CircleAvatar(backgroundColor: Colors.white70,
                  child: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.black)),
              onPressed: () => ref.read(favoritesProvider.notifier).toggle(product.id),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(children: [
              PageView.builder(
                controller: _pageController,
                itemCount: product.images.length,
                onPageChanged: (i) => setState(() => _currentImage = i),
                itemBuilder: (context, i) => CachedNetworkImage(
                    imageUrl: product.images[i], fit: BoxFit.cover),
              ),
              Positioned(bottom: 12, left: 0, right: 0,
                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(product.images.length, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentImage == i ? 20 : 6, height: 6,
                    decoration: BoxDecoration(
                      color: _currentImage == i ? AppColors.gold : Colors.white70,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  )),
                ),
              ),
            ]),
          ),
        ),

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Name + Price
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(product.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800))),
              Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.gold, fontSize: 22, fontWeight: FontWeight.w900)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              RatingStars(rating: product.rating),
              const SizedBox(width: 8),
              Text('(${product.reviewCount} reviews)', style: const TextStyle(color: AppColors.warmGray, fontSize: 12)),
              const Spacer(),
              TextButton(onPressed: () => context.push('/reviews/${product.id}'), child: const Text('See all')),
            ]),

            const Divider(height: 32),

            // Artisan info
            if (artisan != null)
              GestureDetector(
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
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Made by ${artisan.name}', style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(artisan.region, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                    ])),
                    const Icon(Icons.chevron_right, color: AppColors.gold),
                  ]),
                ),
              ),

            const SizedBox(height: 20),

            // Story
            Text('The Story', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.gold)),
            const SizedBox(height: 8),
            Text(product.story, style: TextStyle(height: 1.6, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8))),

            const SizedBox(height: 20),

            // Specs
            Text('Details', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _specRow(context, 'Materials', product.materials),
            _specRow(context, 'Dimensions', product.dimensions),

            const SizedBox(height: 20),

            // Tags
            Wrap(
              spacing: 8, runSpacing: 8,
              children: product.tags.map((tag) => Chip(
                label: Text(tag, style: const TextStyle(fontSize: 11)),
              )).toList(),
            ),

            const SizedBox(height: 20),

            // View Gallery Button
            OutlinedButton.icon(
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('View Gallery & Making-of'),
              onPressed: () => context.push('/gallery/${product.id}'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gold,
                side: const BorderSide(color: AppColors.gold),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),

            const SizedBox(height: 100),
          ]),
        )),
      ]),

      // Bottom CTA
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.card_giftcard),
            label: const Text('Order as Gift', style: TextStyle(fontSize: 16)),
            onPressed: () => context.push('/booking/${product.id}'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 54)),
          ),
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