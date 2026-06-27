import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesNotifier extends Notifier<Set<String>> {
  final _supabase = Supabase.instance.client;

  @override
  Set<String> build() {
    _fetch();
    return {};
  }

  Future<void> _fetch() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final data = await _supabase
          .from('favorites')
          .select('product_id')
          .eq('user_id', userId);
      state = (data as List).map((r) => r['product_id'] as String).toSet();
    } catch (_) {}
  }

  Future<void> toggle(String productId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final updated = {...state};
    if (updated.contains(productId)) {
      updated.remove(productId);
      try {
        await _supabase
            .from('favorites')
            .delete()
            .eq('user_id', userId)
            .eq('product_id', productId);
      } catch (_) {}
    } else {
      updated.add(productId);
      try {
        await _supabase.from('favorites').insert({
          'user_id': userId,
          'product_id': productId,
        });
      } catch (_) {}
    }
    state = updated;
  }

  bool isFavorite(String id) => state.contains(id);
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);
