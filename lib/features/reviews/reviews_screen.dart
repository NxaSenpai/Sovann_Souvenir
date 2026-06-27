import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/mock_repository.dart';
import '../../models/review.dart';
import '../../theme/app_colors.dart';
import '../../widgets/rating_stars.dart';
import '../../l10n/generated/app_localizations.dart';

class ReviewsScreen extends StatefulWidget {
  final String productId;
  const ReviewsScreen({super.key, required this.productId});
  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  List<Review> _reviews = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _loading = true);
    try {
      final data = await Supabase.instance.client
          .from('reviews')
          .select('*, profiles(full_name, avatar_url)')
          .eq('product_id', widget.productId)
          .order('created_at', ascending: false);
      _reviews = (data as List).map((j) => Review.fromJson(j)).toList();
    } catch (_) {
      _reviews = MockRepository.instance.reviewsForProduct(widget.productId);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avgRating = _reviews.isEmpty
        ? 0.0 : _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.cream,
      appBar: AppBar(
        title: Text(l10n.reviews),
        backgroundColor: isDark ? AppColors.darkBg : AppColors.cream,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : CustomScrollView(slivers: [
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(children: [
                  Column(children: [
                    Text(avgRating.toStringAsFixed(1), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.gold)),
                    RatingStars(rating: avgRating),
                    Text(l10n.reviewsCount(_reviews.length), style: const TextStyle(color: AppColors.warmGray, fontSize: 12)),
                  ]),
                  const SizedBox(width: 24),
                  Expanded(child: Column(children: [5, 4, 3, 2, 1].map((star) {
                    final count = _reviews.where((r) => r.rating == star).length;
                    final pct = _reviews.isEmpty ? 0.0 : count / _reviews.length;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(children: [
                        Text('$star', style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 8),
                        Expanded(child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct, color: AppColors.gold,
                            backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightGray, minHeight: 8,
                          ),
                        )),
                      ]),
                    );
                  }).toList())),
                ]),
              )),

              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit_outlined), label: Text(l10n.writeReview),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gold, side: const BorderSide(color: AppColors.gold),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => _showWriteReviewSheet(context, isDark),
                ),
              )),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              if (_reviews.isEmpty)
                SliverToBoxAdapter(child: Center(child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(children: [
                    Icon(Icons.rate_review_outlined, size: 48, color: AppColors.warmGray.withAlpha(100)),
                    const SizedBox(height: 12),
                    Text('No reviews yet', style: TextStyle(color: AppColors.warmGray, fontSize: 15)),
                  ]),
                )))
              else
                SliverList(delegate: SliverChildBuilderDelegate(
                  (context, i) => _reviewCard(_reviews[i], isDark),
                  childCount: _reviews.length,
                )),
              SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).padding.bottom + 32)),
            ]),
    );
  }

  Widget _reviewCard(Review r, bool isDark) {
    // Parse photo URLs (stored as JSON array string or single URL)
    final photos = _parsePhotos(r.photoUrl);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(isDark ? 60 : 10), blurRadius: 6)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: r.userAvatar.isNotEmpty ? CachedNetworkImageProvider(r.userAvatar) : null,
              backgroundColor: AppColors.gold.withAlpha(40),
              child: r.userAvatar.isEmpty
                  ? Text(r.userName.isNotEmpty ? r.userName[0].toUpperCase() : '?',
                      style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.userName, style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? AppColors.cream : AppColors.charcoal)),
              Text(_formatDate(r.date), style: const TextStyle(color: AppColors.warmGray, fontSize: 12)),
            ])),
            RatingStars(rating: r.rating.toDouble(), size: 14),
          ]),
          if (r.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(r.comment, style: TextStyle(height: 1.5, color: isDark ? AppColors.cream : AppColors.charcoal)),
          ],
          if (photos.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _showFullGallery(context, photos, i),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: photos[i], width: 160, height: 160,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(width: 160, height: 160,
                          color: isDark ? AppColors.darkSurface : AppColors.lightGray),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  List<String> _parsePhotos(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    if (raw.startsWith('[')) {
      try { return (jsonDecode(raw) as List).cast<String>(); } catch (_) {}
    }
    return [raw]; // legacy single URL
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${months[dt.month-1]} ${dt.year}';
    } catch (_) { return dateStr; }
  }

  void _showFullGallery(BuildContext context, List<String> photos, int initialIndex) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: [
          PhotoViewGallery.builder(
            itemCount: photos.length,
            pageController: PageController(initialPage: initialIndex),
            builder: (_, i) => PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(photos[i]),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3,
            ),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
          SafeArea(child: Positioned(
            top: 8, left: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          )),
        ]),
      ),
    ));
  }

  void _showWriteReviewSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _WriteReviewSheet(productId: widget.productId, isDark: isDark, onSubmitted: _loadReviews),
    );
  }
}

class _WriteReviewSheet extends StatefulWidget {
  final String productId; final bool isDark; final VoidCallback onSubmitted;
  const _WriteReviewSheet({required this.productId, required this.isDark, required this.onSubmitted});
  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  int _rating = 5;
  final _commentCtrl = TextEditingController();
  final _photos = <File>[];
  bool _submitting = false;

  @override
  void dispose() { _commentCtrl.dispose(); super.dispose(); }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (picked != null) setState(() => _photos.add(File(picked.path)));
  }

  Future<void> _submit() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    setState(() => _submitting = true);

    try {
      // Upload all photos
      final urls = <String>[];
      for (final photo in _photos) {
        final path = 'reviews/${widget.productId}/${DateTime.now().millisecondsSinceEpoch}_${urls.length}.jpg';
        await Supabase.instance.client.storage.from('avatars').upload(path, photo);
        urls.add(Supabase.instance.client.storage.from('avatars').getPublicUrl(path));
      }

      await Supabase.instance.client.from('reviews').insert({
        'product_id': widget.productId,
        'user_id': userId,
        'rating': _rating,
        'comment': _commentCtrl.text.trim(),
        'photo_url': urls.isNotEmpty ? jsonEncode(urls) : null,
      });

      // Update product review_count and rating
      final reviewsData = await Supabase.instance.client
          .from('reviews').select('rating').eq('product_id', widget.productId);
      final newCount = (reviewsData as List).length;
      final newAvg = newCount > 0
          ? reviewsData.fold(0.0, (s, r) => s + (r['rating'] as num).toDouble()) / newCount : 0.0;
      await Supabase.instance.client.from('products').update({
        'review_count': newCount,
        'rating': double.parse(newAvg.toStringAsFixed(2)),
      }).eq('id', widget.productId);

      if (mounted) { Navigator.pop(context); widget.onSubmitted(); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 36, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('Write a Review', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.cream : AppColors.charcoal)),
              const SizedBox(height: 20),

              // Star rating
              Row(mainAxisAlignment: MainAxisAlignment.center, children:
                List.generate(5, (i) => GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Icon(i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 42, color: AppColors.gold),
                )),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _commentCtrl, maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Share your experience...',
                  filled: true, fillColor: isDark ? AppColors.darkCard : const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),

              // Photo picker
              Wrap(spacing: 8, runSpacing: 8, children: [
                ..._photos.asMap().entries.map((e) => Stack(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(e.value, width: 72, height: 72, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: -4, right: -4,
                    child: GestureDetector(
                      onTap: () => setState(() => _photos.removeAt(e.key)),
                      child: Container(
                        width: 20, height: 20,
                        decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ])),
                if (_photos.length < 5)
                  GestureDetector(
                    onTap: _pickPhoto,
                    child: Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.gold.withAlpha(80), width: 1.5),
                      ),
                      child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.add_photo_alternate_outlined, color: AppColors.gold, size: 22),
                        SizedBox(height: 2),
                        Text('Photo', style: TextStyle(fontSize: 9, color: AppColors.warmGray)),
                      ]),
                    ),
                  ),
              ]),

              const SizedBox(height: 24),
              SizedBox(width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold, foregroundColor: Colors.white, elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _submitting
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Submit Review', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
