import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_repository.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';

class ProductSearchBar extends StatefulWidget {
  final bool isDark;
  final Color cardBg;
  final Color subtleBorder;
  final String hintText;
  const ProductSearchBar({
    super.key,
    required this.isDark,
    required this.cardBg,
    required this.subtleBorder,
    required this.hintText,
  });

  @override
  State<ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<ProductSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  OverlayEntry? _overlay;
  List<Product> _results = [];
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _hideOverlay();
    });
  }

  @override
  void dispose() {
    _hideOverlay();
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _controller.text.trim().toLowerCase();
    if (query.isEmpty) {
      _hideOverlay();
      return;
    }
    final all = MockRepository.instance.productsTr;
    _results = all.where((p) => p.name.toLowerCase().contains(query)).toList();
    _showOverlay();
  }

  void _showOverlay() {
    _hideOverlay();
    _overlay = OverlayEntry(
      builder: (context) => _SearchDropdown(
        results: _results,
        isDark: widget.isDark,
        layerLink: _layerLink,
        onTap: (product) {
          _hideOverlay();
          _controller.clear();
          _focusNode.unfocus();
          context.push('/product/${product.id}');
        },
      ),
    );
    Overlay.of(context).insert(_overlay!);
    setState(() => _showDropdown = true);
  }

  void _hideOverlay() {
    _overlay?.remove();
    _overlay = null;
    if (mounted) setState(() => _showDropdown = false);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: widget.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: widget.subtleBorder),
          boxShadow: widget.isDark
              ? null
              : [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: TextStyle(fontSize: 14, color: widget.isDark ? AppColors.cream : AppColors.charcoal),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: AppColors.warmGray, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: AppColors.gold, size: 20),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    color: AppColors.warmGray,
                    onPressed: () {
                      _controller.clear();
                      _hideOverlay();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}

class _SearchDropdown extends StatelessWidget {
  final List<Product> results;
  final bool isDark;
  final LayerLink layerLink;
  final Function(Product) onTap;

  const _SearchDropdown({
    required this.results,
    required this.isDark,
    required this.layerLink,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Stack(children: [
      Positioned(
        top: 0, left: 0, right: 0, bottom: 0,
        child: GestureDetector(
          onTap: () {}, // absorb taps outside
          child: Container(color: Colors.transparent),
        ),
      ),
      CompositedTransformFollower(
        link: layerLink,
        showWhenUnlinked: false,
        offset: const Offset(0, 52),
        child: Material(
          elevation: 12,
          borderRadius: BorderRadius.circular(16),
          color: Colors.transparent,
          child: Container(
            width: screenWidth - 32,
            constraints: const BoxConstraints(maxHeight: 320),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 120 : 30),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: results.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 32, color: AppColors.warmGray.withAlpha(120)),
                        const SizedBox(height: 8),
                        Text('No products found',
                            style: TextStyle(color: AppColors.warmGray, fontSize: 14)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(8),
                    shrinkWrap: true,
                    itemCount: results.length,
                    separatorBuilder: (_, __) => Divider(
                        height: 1, thickness: 0.5,
                        color: isDark ? AppColors.darkSurface : AppColors.lightGray),
                    itemBuilder: (context, i) {
                      final p = results[i];
                      return InkWell(
                        onTap: () => onTap(p),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          child: Row(children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: p.images.first,
                                width: 42, height: 42, fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(
                                  width: 42, height: 42,
                                  color: isDark ? AppColors.darkSurface : AppColors.lightGray,
                                  child: const Icon(Icons.image, size: 18, color: AppColors.warmGray),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name,
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600, fontSize: 14,
                                        color: isDark ? AppColors.cream : AppColors.charcoal,
                                      )),
                                  const SizedBox(height: 2),
                                  Text('\$${p.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 13)),
                                ],
                              ),
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    ]);
  }
}
