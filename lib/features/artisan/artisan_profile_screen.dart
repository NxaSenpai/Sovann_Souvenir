import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/product_card.dart';

class ArtisanProfileScreen extends StatelessWidget {
  final String artisanId;
  const ArtisanProfileScreen({super.key, required this.artisanId});

  @override
  Widget build(BuildContext context) {
    final repo = MockRepository.instance;
    final artisan = repo.artisanById(artisanId)!;
    final products = repo.products.where((p) => p.artisanId == artisanId).toList();

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          leading: IconButton(
            icon: const CircleAvatar(backgroundColor: Colors.white70, child: Icon(Icons.arrow_back, color: Colors.black)),
            onPressed: () => context.pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(fit: StackFit.expand, children: [
              CachedNetworkImage(imageUrl: artisan.coverImage, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                )),
              ),
            ]),
          ),
        ),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(radius: 36, backgroundImage: CachedNetworkImageProvider(artisan.avatar)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(artisan.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                Text(artisan.craft, style: const TextStyle(color: AppColors.gold, fontSize: 14)),
                Text(artisan.region, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 13)),
                Text('${artisan.yearsOfExperience} years of experience', style: const TextStyle(fontSize: 12)),
              ])),
            ]),
            const SizedBox(height: 20),
            const Text('Their Story', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            Text(artisan.story, style: TextStyle(height: 1.6, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Message Artisan'),
              onPressed: () => context.push('/chat/${artisan.id}'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
            ),
            const SizedBox(height: 24),
            const Text('Their Crafts', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: ProductCard(product: products[i]),
                ),
              ),
            ),
          ]),
        )),
      ]),
    );
  }
}