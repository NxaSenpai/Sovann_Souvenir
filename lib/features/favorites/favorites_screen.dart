import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_repository.dart';
import '../../state/favorites_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/empty_state.dart';
import '../../l10n/generated/app_localizations.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final favIds = ref.watch(favoritesProvider);
    final all = MockRepository.instance.products;
    final favs = all.where((p) => favIds.contains(p.id)).toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.savedGifts)),
      body: favs.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border,
              title: l10n.noSavedGifts,
              subtitle: l10n.tapHeartToSave,
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemCount: favs.length,
              itemBuilder: (context, i) =>
                  ProductCard(product: favs[i]),
            ),
    );
  }
}
