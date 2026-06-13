import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../data/mock_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/product_card.dart';
import '../../widgets/khmer_pattern_divider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _heroController = PageController();
  final _searchController = TextEditingController();
  final repo = MockRepository.instance;

  final _heroItems = [
    {'image': 'https://picsum.photos/seed/hero1/800/400', 'title': 'Crafted in Cambodia', 'sub': 'Artisan-made gifts with a story'},
    {'image': 'https://picsum.photos/seed/hero2/800/400', 'title': 'Pure Silk Tradition', 'sub': 'Woven by hand for generations'},
    {'image': 'https://picsum.photos/seed/hero3/800/400', 'title': 'Silver & Soul', 'sub': 'Royal court craftsmanship'},
  ];

  final _categories = [
    {'id': 'textile',  'label': 'Textile',  'emoji': '🧵'},
    {'id': 'silver',   'label': 'Silver',   'emoji': '🥈'},
    {'id': 'wood',     'label': 'Wood',     'emoji': '🪵'},
    {'id': 'edible',   'label': 'Edible',   'emoji': '🫙'},
    {'id': 'jewelry',  'label': 'Jewelry',  'emoji': '💎'},
  ];

  @override
  Widget build(BuildContext context) {
    final featured = repo.featured;
    final collections = repo.collections;
    final artisans = repo.artisans;

    return Scaffold(
      body: CustomScrollView(slivers: [
        // App Bar
        SliverAppBar(
          floating: true,
          snap: true,
          title: Row(children: [
            const Text('✦', style: TextStyle(color: AppColors.gold, fontSize: 20)),
            const SizedBox(width: 8),
            Text('Sovann Souvenir', style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700)),
          ]),
          actions: [
            IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () => context.push('/chat')),
          ],
        ),

        SliverToBoxAdapter(child: Column(children: [

          // Hero Carousel (Story-style)
          SizedBox(
            height: 220,
            child: Stack(children: [
              PageView.builder(
                controller: _heroController,
                itemCount: _heroItems.length,
                itemBuilder: (context, i) {
                  final item = _heroItems[i];
                  return Stack(fit: StackFit.expand, children: [
                    CachedNetworkImage(imageUrl: item['image']!, fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                        ),
                      ),
                    ),
                    Positioned(bottom: 30, left: 20, right: 60, child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title']!, style: const TextStyle(
                            color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                        Text(item['sub']!, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                      ],
                    )),
                  ]);
                },
              ),
              Positioned(bottom: 10, right: 20, child: SmoothPageIndicator(
                controller: _heroController,
                count: _heroItems.length,
                effect: const WormEffect(
                  dotColor: Colors.white54, activeDotColor: AppColors.gold,
                  dotHeight: 6, dotWidth: 6,
                ),
              )),
            ]),
          ).animate().fadeIn(duration: 600.ms),

          const SizedBox(height: 24),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search gifts, artisans...',
                prefixIcon: const Icon(Icons.search, color: AppColors.gold),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Categories', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, i) {
                final cat = _categories[i];
                return GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 70, margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.light 
                              ? Colors.black.withOpacity(0.05) 
                              : Colors.black.withOpacity(0.2), 
                          blurRadius: 6
                        )
                      ],
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(cat['emoji']!, style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 4),
                      Text(cat['label']!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          const KhmerPatternDivider(),
          const SizedBox(height: 24),

          // Featured Products
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Featured', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              TextButton(onPressed: () {}, child: const Text('See all')),
            ]),
          ),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: featured.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ProductCard(product: featured[i]),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Curated Collections
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Collections', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
          ...collections.map((col) => GestureDetector(
            onTap: () => context.push('/collection/${col.id}'),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              height: 100,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
              child: Stack(fit: StackFit.expand, children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(imageUrl: col.coverImage, fit: BoxFit.cover),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [Colors.black54, Colors.transparent],
                      begin: Alignment.centerLeft,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: AppColors.gold, borderRadius: BorderRadius.circular(4)),
                        child: Text(col.tag, style: const TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                      const SizedBox(height: 4),
                      Text(col.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                    ],
                  ),
                ),
              ]),
            ),
          )),

          const SizedBox(height: 24),
          const KhmerPatternDivider(),
          const SizedBox(height: 24),

          // Featured Artisans
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Meet the Artisans', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: artisans.length,
              itemBuilder: (context, i) {
                final a = artisans[i];
                return GestureDetector(
                  onTap: () => context.push('/artisan/${a.id}'),
                  child: Container(
                    width: 85, margin: const EdgeInsets.only(right: 16),
                    child: Column(children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundImage: CachedNetworkImageProvider(a.avatar),
                      ),
                      const SizedBox(height: 6),
                      Text(a.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                );
              },
            ),
          ),

          // Gift Finder Quiz Banner
          GestureDetector(
            onTap: () => context.push('/quiz'),
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.gold, AppColors.goldDark]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(children: [
                const Text('🎁', style: TextStyle(fontSize: 40)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Not sure what to get?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Take our Gift Finder Quiz', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
                ])),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ]),
            ),
          ),

          const SizedBox(height: 80),
        ])),
      ]),
    );
  }
}