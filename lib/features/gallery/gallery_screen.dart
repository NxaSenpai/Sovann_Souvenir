import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../data/mock_repository.dart';
import '../../theme/app_colors.dart';

class GalleryScreen extends StatefulWidget {
  final String productId;
  const GalleryScreen({super.key, required this.productId});
  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int _selected = 0;
  late PageController _pageController;

  // Extra "making-of" gallery images
  final _makingOf = [
    'https://picsum.photos/seed/making1/600/400',
    'https://picsum.photos/seed/making2/600/400',
    'https://picsum.photos/seed/making3/600/400',
    'https://picsum.photos/seed/making4/600/400',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    final product = MockRepository.instance.products.firstWhere((p) => p.id == widget.productId);
    final allImages = [...product.images, ..._makingOf];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(product.name, style: const TextStyle(color: Colors.white)),
      ),
      body: Column(children: [
        // Full-screen viewer
        Expanded(
          child: PhotoViewGallery.builder(
            pageController: _pageController,
            itemCount: allImages.length,
            onPageChanged: (i) => setState(() => _selected = i),
            builder: (context, i) => PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(allImages[i]),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3,
            ),
            loadingBuilder: (context, event) => const Center(
                child: CircularProgressIndicator(color: AppColors.gold)),
          ),
        ),

        // Thumbnail strip
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            itemCount: allImages.length,
            itemBuilder: (context, i) {
              final isSelected = i == _selected;
              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(i,
                      duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? AppColors.gold : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CachedNetworkImage(
                      imageUrl: allImages[i],
                      width: 60, height: 60, fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Label: making-of vs product
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            _selected < product.images.length ? 'Product Photos' : 'Making-of',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      ]),
    );
  }
}