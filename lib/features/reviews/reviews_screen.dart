import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../data/mock_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/rating_stars.dart';

class ReviewsScreen extends StatelessWidget {
  final String productId;
  const ReviewsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final reviews = MockRepository.instance.reviewsForProduct(productId);
    final avgRating = reviews.isEmpty ? 0.0 : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: CustomScrollView(slivers: [
        // Rating summary
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Column(children: [
              Text(avgRating.toStringAsFixed(1), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.gold)),
              RatingStars(rating: avgRating),
              Text('${reviews.length} reviews', style: const TextStyle(color: AppColors.warmGray, fontSize: 12)),
            ]),
            const SizedBox(width: 24),
            Expanded(child: Column(children: [5, 4, 3, 2, 1].map((star) {
              final count = reviews.where((r) => r.rating == star).length;
              final pct = reviews.isEmpty ? 0.0 : count / reviews.length;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(children: [
                  Text('$star', style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 8),
                  Expanded(child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: pct, color: AppColors.gold, backgroundColor: AppColors.lightGray, minHeight: 8),
                  )),
                ]),
              );
            }).toList())),
          ]),
        )),

        // Write review CTA
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton.icon(
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Write a Review'),
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.gold,
              side: const BorderSide(color: AppColors.gold),
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
        )),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Review cards
        SliverList(delegate: SliverChildBuilderDelegate((context, i) {
          final r = reviews[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  CircleAvatar(backgroundImage: CachedNetworkImageProvider(r.userAvatar), radius: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.userName, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(r.date, style: const TextStyle(color: AppColors.warmGray, fontSize: 12)),
                  ])),
                  RatingStars(rating: r.rating.toDouble(), size: 14),
                ]),
                const SizedBox(height: 10),
                Text(r.comment, style: const TextStyle(height: 1.5)),
                if (r.photoUrl != null) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(imageUrl: r.photoUrl!, height: 120, fit: BoxFit.cover),
                  ),
                ],
              ]),
            )),
          );
        }, childCount: reviews.length)),
      ]),
    );
  }
}