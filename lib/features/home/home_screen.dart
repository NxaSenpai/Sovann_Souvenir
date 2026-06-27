import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../data/mock_repository.dart';
import '../../theme/app_colors.dart';
import '../../state/cart_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/search_bar.dart';
import '../../l10n/generated/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _heroController = PageController();
  final repo = MockRepository.instance;

  late List<Map<String, String>> _heroItems;
  late List<Map<String, String>> _categories;

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final featured = repo.featuredTr;
    final collections = repo.collectionsTr;
    final artisans = repo.artisansTr;

    _heroItems = [
      {'image': 'https://picsum.photos/seed/hero1/800/400', 'title': l10n.heroTitle1, 'sub': l10n.heroSub1},
      {'image': 'https://picsum.photos/seed/hero2/800/400', 'title': l10n.heroTitle2, 'sub': l10n.heroSub2},
      {'image': 'https://picsum.photos/seed/hero3/800/400', 'title': l10n.heroTitle3, 'sub': l10n.heroSub3},
    ];
    final cats = repo.categoriesTr;
    final l10nMap = <String, String>{
      'textile': l10n.textile, 'silver': l10n.silver, 'wood': l10n.wood,
      'edible': l10n.edible, 'jewelry': l10n.jewelry,
    };
    _categories = cats.map((c) => {
      'id': c.id, 'label': l10nMap[c.id] ?? c.name, 'emoji': c.emoji,
    }).toList();

    // Surfaces
    final cardBg   = isDark ? AppColors.darkCard    : Colors.white;
    final pageBg   = isDark ? AppColors.darkBg      : AppColors.cream;
    final subtleHr = isDark ? AppColors.gold.withAlpha(30) : AppColors.gold.withAlpha(22);

    return Scaffold(
      backgroundColor: pageBg,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/chatbot'),
        backgroundColor: AppColors.gold,
        child: const Icon(Icons.chat_rounded, color: Colors.white),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          // ── App Bar ──────────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: pageBg,
            elevation: 0,
            scrolledUnderElevation: 0,
            toolbarHeight: 64,
            title: Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('✦', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  l10n.appTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: isDark ? AppColors.cream : AppColors.charcoal,
                  ),
                ),
                Text(
                  'Handcrafted in Cambodia',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.gold,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ]),
            ]),
            actions: [
              // Cart icon with badge
              Consumer(
                builder: (context, ref, _) {
                  final cart = ref.watch(cartProvider);
                  return Stack(children: [
                    IconButton(
                      icon: Icon(Icons.shopping_cart_outlined,
                          color: isDark ? AppColors.cream : AppColors.charcoal),
                      onPressed: () => context.push('/cart'),
                    ),
                    if (cart.isNotEmpty)
                      Positioned(
                        top: 8, right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${cart.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ]);
                },
              ),
              IconButton(
                icon: Icon(Icons.chat_bubble_outlined,
                    color: isDark ? AppColors.cream : AppColors.charcoal),
                onPressed: () => context.push('/chat'),
              ),
              const SizedBox(width: 4),
            ],
          ),

          // ── Search ────────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: ProductSearchBar(
                isDark: isDark,
                cardBg: cardBg,
                subtleBorder: subtleHr,
                hintText: l10n.searchGifts,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 22)),

          // ── Hero Carousel ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 220,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(children: [
                    PageView.builder(
                      controller: _heroController,
                      itemCount: _heroItems.length,
                      itemBuilder: (context, i) {
                        final item = _heroItems[i];
                        return Stack(fit: StackFit.expand, children: [
                          CachedNetworkImage(imageUrl: item['image']!, fit: BoxFit.cover),
                          // Two-layer gradient: bottom-up dark + subtle gold tint at top
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.gold.withAlpha(30),
                                  Colors.transparent,
                                  Colors.black.withAlpha(175),
                                ],
                                stops: const [0.0, 0.35, 1.0],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 28, left: 22, right: 70,
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              // Eyebrow label
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.gold,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  'FEATURED',
                                  style: const TextStyle(
                                    color: Colors.white, fontSize: 9,
                                    fontWeight: FontWeight.w800, letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['title']!,
                                style: const TextStyle(
                                  color: Colors.white, fontSize: 22,
                                  fontWeight: FontWeight.w900, height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['sub']!,
                                style: TextStyle(
                                  color: Colors.white.withAlpha(200), fontSize: 13, height: 1.4,
                                ),
                              ),
                            ]),
                          ),
                        ]);
                      },
                    ),
                    Positioned(
                      bottom: 16, right: 18,
                      child: SmoothPageIndicator(
                        controller: _heroController,
                        count: _heroItems.length,
                        effect: const WormEffect(
                          dotColor: Colors.white38,
                          activeDotColor: AppColors.gold,
                          dotHeight: 6, dotWidth: 6,
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Categories ────────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _SectionHeader(title: l10n.categories)),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  return GestureDetector(
                    onTap: () => context.push('/category/${cat['id']}'),
                    child: Container(
                      width: 78,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: subtleHr, width: 1.2),
                        boxShadow: isDark ? null : [
                          BoxShadow(
                            color: AppColors.gold.withAlpha(18),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(cat['emoji']!, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 5),
                        Text(
                          cat['label']!,
                          style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.cream : AppColors.charcoal,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Thin gold divider ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Expanded(child: Divider(color: subtleHr, thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('✦', style: TextStyle(color: AppColors.gold.withAlpha(120), fontSize: 12)),
                ),
                Expanded(child: Divider(color: subtleHr, thickness: 1)),
              ]),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Featured Products ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SectionHeader(title: l10n.featured, action: l10n.seeAll),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: featured.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: SizedBox(width: 185, child: ProductCard(product: featured[i])),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Collections ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SectionHeader(title: l10n.collections, action: l10n.seeAll),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 190,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: collections.length,
                itemBuilder: (context, i) {
                  final col = collections[i];
                  return GestureDetector(
                    onTap: () => context.push('/collection/${col.id}'),
                    child: Container(
                      width: 230,
                      margin: const EdgeInsets.only(right: 14),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(fit: StackFit.expand, children: [
                          CachedNetworkImage(imageUrl: col.coverImage, fit: BoxFit.cover),
                          // Richer gradient: warm amber tone at bottom
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  AppColors.earthLight.withAlpha(230),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.7],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 14, right: 14, bottom: 14,
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.gold,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  col.tag.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white, fontSize: 9,
                                    fontWeight: FontWeight.w800, letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                col.name,
                                style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w800,
                                  fontSize: 17, height: 1.25,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ]),
                          ),
                        ]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Artisans ──────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SectionHeader(title: l10n.meetArtisans),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 108,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: artisans.length,
                itemBuilder: (context, i) {
                  final a = artisans[i];
                  return GestureDetector(
                    onTap: () => context.push('/artisan/${a.id}'),
                    child: Container(
                      width: 76,
                      margin: const EdgeInsets.only(right: 16),
                      child: Column(children: [
                        // Gold-ring avatar
                        Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.gold, AppColors.goldLight, AppColors.goldDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundImage: CachedNetworkImageProvider(a.avatar),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          a.name,
                          style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.cream : AppColors.charcoal,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ── Reusable section header ─────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  const _SectionHeader({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gold accent bar
          Container(
            width: 3.5, height: 18,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: isDark ? AppColors.cream : AppColors.charcoal,
              ),
            ),
          ),
          if (action != null)
            Text(
              action!,
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }
}