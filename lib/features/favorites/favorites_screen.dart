import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_repository.dart';
import '../../state/favorites_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/empty_state.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favIds = ref.watch(favoritesProvider);
    final all = MockRepository.instance.products;
    final favs = all.where((p) => favIds.contains(p.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Gifts')),
      body: favs.isEmpty
          ? const EmptyState(icon: Icons.favorite_border, title: 'No saved gifts yet', subtitle: 'Tap the heart on any item to save it here')
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.7),
        itemCount: favs.length,
        itemBuilder: (context, i) => ProductCard(product: favs[i], width: double.infinity),
      ),
    );
  }
}