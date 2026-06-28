import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_repository.dart';
import '../../models/artisan.dart';
import '../../models/product.dart';
import '../../state/favorites_provider.dart';
import '../../state/cart_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/rating_stars.dart';
import '../../l10n/generated/app_localizations.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});
  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  int _currentImage = 0;
  final repo = MockRepository.instance;

  // Favourite bounce
  late final AnimationController _favController;
  late final Animation<double> _favScale;

  // Cart button state
  bool _addedToCart = false;

  @override
  void initState() {
    super.initState();
    _favController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _favScale = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _favController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _favController.dispose();
    super.dispose();
  }

  void _toggleFav(String id) {
    ref.read(favoritesProvider.notifier).toggle(id);
    _favController.forward().then((_) => _favController.reverse());
  }

  void _addToCart(String id) {
    HapticFeedback.lightImpact();
    ref.read(cartProvider.notifier).add(id);
    setState(() => _addedToCart = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _addedToCart = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n    = AppLocalizations.of(context);
    final product = repo.productsTr.firstWhere((p) => p.id == widget.productId);
    final artisan = repo.artisanByIdTr(product.artisanId);
    final isFav   = ref.watch(favoritesProvider).contains(product.id);
    final cart = ref.watch(cartProvider);
    final cartQty = cart[product.id] ?? 0;
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.cream,
      body: Stack(
        children: [
          // ── Scrollable content ──────────────────────────────────────────
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _ImageCarousel(
                  product: product,
                  isFav: isFav,
                  isDark: isDark,
                  favScale: _favScale,
                  currentImage: _currentImage,
                  pageController: _pageController,
                  onPageChanged: (i) => setState(() => _currentImage = i),
                  onFavTap: () => _toggleFav(product.id),
                  onBack: () => context.pop(),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 22),

                      // Name + price row
                      _NamePriceRow(product: product, isDark: isDark),
                      const SizedBox(height: 10),

                      // Rating
                      _RatingRow(product: product),
                      const SizedBox(height: 20),

                      // Description
                      _InfoCard(text: product.description, isDark: isDark),
                      const SizedBox(height: 24),

                      // Artisan
                      if (artisan != null) ...[
                        _ArtisanCard(artisan: artisan, isDark: isDark),
                        const SizedBox(height: 24),
                      ],

                      // Details
                      _SectionTitle(title: l10n.details, isDark: isDark),
                      const SizedBox(height: 10),
                      _DetailsCard(
                        materials: product.materials,
                        dimensions: product.dimensions,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 24),

                      // Story
                      _SectionTitle(title: l10n.theStory, isDark: isDark),
                      const SizedBox(height: 10),
                      _StoryCard(story: product.story, isDark: isDark),
                      const SizedBox(height: 24),

                      // Tags
                      _SectionTitle(title: l10n.tags, isDark: isDark),
                      const SizedBox(height: 10),
                      _Tags(tags: product.tags, isDark: isDark),
                      const SizedBox(height: 24),

                      // Gallery
                      _GalleryButton(productId: product.id),

                      // Extra space for bottom bar
                      SizedBox(height: 110 + MediaQuery.of(context).padding.bottom),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Fixed bottom action bar ──────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _BottomBar(
              product: product,
              isDark: isDark,
              cartQty: cartQty,
              addedToCart: _addedToCart,
              onAddToCart: () => _addToCart(product.id),
              onOrder: () => context.push('/booking/${product.id}'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Image Carousel ───────────────────────────────────────────────────────────
class _ImageCarousel extends StatelessWidget {
  final Product product;
  final bool isFav;
  final bool isDark;
  final Animation<double> favScale;
  final int currentImage;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onFavTap;
  final VoidCallback onBack;

  const _ImageCarousel({
    required this.product,
    required this.isFav,
    required this.isDark,
    required this.favScale,
    required this.currentImage,
    required this.pageController,
    required this.onPageChanged,
    required this.onFavTap,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Stack(
        children: [
          // Photos
          PageView.builder(
            controller: pageController,
            itemCount: product.images.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, i) => Hero(
              tag: 'product-image-${product.id}',
              child: CachedNetworkImage(
                imageUrl: product.images[i],
                width: double.infinity,
                height: 400,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: isDark ? AppColors.darkCard : AppColors.lightGray),
              ),
            ),
          ),

          // Top scrim (for button legibility)
          Positioned(
            top: 0, left: 0, right: 0, height: 130,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withAlpha(140), Colors.transparent],
                ),
              ),
            ),
          ),

          // Bottom scrim
          Positioned(
            bottom: 0, left: 0, right: 0, height: 130,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withAlpha(160), Colors.transparent],
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: _CircleIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: onBack,
              isDark: isDark,
            ),
          ),

          // Favourite button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: ScaleTransition(
              scale: favScale,
              child: _CircleIconButton(
                icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                iconColor: isFav ? Colors.redAccent : Colors.white,
                onTap: onFavTap,
                isDark: isDark,
              ),
            ),
          ),

          // Image count pill — top center
          if (product.images.length > 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 14,
              left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(110),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    '${currentImage + 1} / ${product.images.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

          // Dot indicators — bottom center
          if (product.images.length > 1)
            Positioned(
              bottom: 18, left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(product.images.length, (i) =>
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: currentImage == i ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: currentImage == i ? AppColors.gold : Colors.white.withAlpha(140),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Floating circle icon button ──────────────────────────────────────────────
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;
  final bool isDark;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(100),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withAlpha(40), width: 1),
        ),
        child: Icon(icon, size: 18, color: iconColor ?? Colors.white),
      ),
    );
  }
}

// ── Name + price row ─────────────────────────────────────────────────────────
class _NamePriceRow extends StatelessWidget {
  final Product product;
  final bool isDark;
  const _NamePriceRow({required this.product, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            product.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.4,
              color: isDark ? AppColors.cream : AppColors.charcoal,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.gold, AppColors.goldDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withAlpha(70),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Rating row ───────────────────────────────────────────────────────────────
class _RatingRow extends StatelessWidget {
  final Product product;
  const _RatingRow({required this.product});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => context.push('/reviews/${product.id}'),
      child: Row(children: [
        RatingStars(rating: product.rating),
        const SizedBox(width: 6),
        Text(
          product.rating.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        Text(
          ' (${product.reviewCount})',
          style: const TextStyle(color: AppColors.warmGray, fontSize: 13),
        ),
        const Spacer(),
        Text(
          l10n.seeAllReviews,
          style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const Icon(Icons.chevron_right_rounded, color: AppColors.gold, size: 18),
      ]),
    );
  }
}

// ── Section title with gold accent bar ──────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 3.5, height: 18,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
          color: isDark ? AppColors.cream : AppColors.charcoal,
        ),
      ),
    ]);
  }
}

// ── Description card ─────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final String text;
  final bool isDark;
  const _InfoCard({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.gold.withAlpha(25) : AppColors.gold.withAlpha(20),
        ),
        boxShadow: isDark ? null : [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.5,
          height: 1.65,
          color: isDark ? AppColors.cream.withAlpha(210) : AppColors.warmGray,
        ),
      ),
    );
  }
}

// ── Artisan card ─────────────────────────────────────────────────────────────
class _ArtisanCard extends StatelessWidget {
  final Artisan artisan;
  final bool isDark;
  const _ArtisanCard({required this.artisan, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => context.push('/artisan/${artisan.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.gold.withAlpha(30) : AppColors.gold.withAlpha(25),
          ),
          boxShadow: isDark ? null : [
            BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.gold, AppColors.goldLight, AppColors.goldDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundImage: CachedNetworkImageProvider(artisan.avatar),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              l10n.madeBy(artisan.name),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: isDark ? AppColors.cream : AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 3),
            Row(children: [
              Icon(Icons.location_on_outlined, size: 12, color: AppColors.gold),
              const SizedBox(width: 3),
              Text(
                artisan.region,
                style: const TextStyle(fontSize: 12, color: AppColors.warmGray),
              ),
            ]),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gold.withAlpha(isDark ? 40 : 22),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(l10n.view, style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(width: 2),
              const Icon(Icons.chevron_right_rounded, color: AppColors.gold, size: 14),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Details card ─────────────────────────────────────────────────────────────
class _DetailsCard extends StatelessWidget {
  final String materials;
  final String dimensions;
  final bool isDark;
  const _DetailsCard({
    required this.materials,
    required this.dimensions,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final divider = Divider(
      color: isDark ? AppColors.darkSurface : AppColors.lightGray,
      height: 1, thickness: 1,
    );
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.gold.withAlpha(25) : AppColors.gold.withAlpha(20),
        ),
        boxShadow: isDark ? null : [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(children: [
        _SpecRow(label: l10n.materials, value: materials, isDark: isDark, icon: Icons.texture_rounded),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: divider),
        _SpecRow(label: l10n.dimensions, value: dimensions, isDark: isDark, icon: Icons.straighten_rounded),
      ]),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final IconData icon;
  const _SpecRow({required this.label, required this.value, required this.isDark, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: AppColors.gold.withAlpha(isDark ? 40 : 22),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: AppColors.gold),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.warmGray, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
              color: isDark ? AppColors.cream : AppColors.charcoal)),
        ])),
      ]),
    );
  }
}

// ── Story card ───────────────────────────────────────────────────────────────
class _StoryCard extends StatelessWidget {
  final String story;
  final bool isDark;
  const _StoryCard({required this.story, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.gold.withAlpha(25) : AppColors.gold.withAlpha(20),
        ),
        boxShadow: isDark ? null : [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Decorative open-quote
        Text(
          '\u201C',
          style: TextStyle(
            fontSize: 48,
            height: 0.6,
            color: AppColors.gold.withAlpha(180),
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          story,
          style: TextStyle(
            fontSize: 14.5,
            height: 1.7,
            fontStyle: FontStyle.italic,
            color: isDark ? AppColors.cream.withAlpha(210) : AppColors.warmGray,
          ),
        ),
      ]),
    );
  }
}

// ── Tags ─────────────────────────────────────────────────────────────────────
class _Tags extends StatelessWidget {
  final List<String> tags;
  final bool isDark;
  const _Tags({required this.tags, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: tags.map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightGray.withAlpha(180),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: AppColors.gold.withAlpha(isDark ? 60 : 40),
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('✦', style: TextStyle(color: AppColors.gold.withAlpha(160), fontSize: 9)),
          const SizedBox(width: 5),
          Text(
            tag,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.cream : AppColors.charcoal,
            ),
          ),
        ]),
      )).toList(),
    );
  }
}

// ── Gallery button ────────────────────────────────────────────────────────────
class _GalleryButton extends StatelessWidget {
  final String productId;
  const _GalleryButton({required this.productId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OutlinedButton.icon(
      onPressed: () => context.push('/gallery/$productId'),
      icon: const Icon(Icons.photo_library_outlined),
      label: Text(l10n.viewGallery),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.gold,
        side: const BorderSide(color: AppColors.gold, width: 1.5),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

// ── Bottom action bar ─────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final Product product;
  final bool isDark;
  final int cartQty;
  final bool addedToCart;
  final VoidCallback onAddToCart;
  final VoidCallback onOrder;

  const _BottomBar({
    required this.product,
    required this.isDark,
    required this.cartQty,
    required this.addedToCart,
    required this.onAddToCart,
    required this.onOrder,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 14 + bottomPad),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.gold.withAlpha(30) : AppColors.lightGray,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 60 : 20),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(children: [

        Expanded(
          flex: 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: 52,
            decoration: BoxDecoration(
              color: addedToCart
                  ? Colors.green.withAlpha(isDark ? 60 : 30)
                  : (isDark ? AppColors.darkCard : AppColors.lightGray.withAlpha(200)),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: addedToCart ? Colors.green : AppColors.gold.withAlpha(isDark ? 80 : 60),
                width: 1.5,
              ),
            ),
            child: TextButton(
              onPressed: onAddToCart,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: EdgeInsets.zero,
              ),
              child: Stack(alignment: Alignment.center, children: [
                AnimatedOpacity(
                  opacity: addedToCart ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.shopping_bag_outlined, size: 18,
                        color: isDark ? AppColors.cream : AppColors.charcoal),
                    const SizedBox(width: 6),
                    Text(
                      cartQty > 0 ? '${l10n.addToCart} ($cartQty)' : l10n.addToCart,
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.cream : AppColors.charcoal,
                      ),
                    ),
                  ]),
                ),
                AnimatedOpacity(
                  opacity: addedToCart ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.check_circle_rounded, size: 18, color: Colors.green),
                    const SizedBox(width: 6),
                    Text(l10n.added, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.green)),
                  ]),
                ),
              ]),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          flex: 2,
          child: SizedBox(
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gold, Color(0xFFB5840A), AppColors.goldDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withAlpha(90),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onOrder,
                icon: const Icon(Icons.card_giftcard_rounded, size: 18),
                label: Text(l10n.orderAsGift, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}