import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';

class FavoritesNotifier extends Notifier<Set<String>> {
  final _supabase = Supabase.instance.client;
  static const _cacheKey = 'favorites_cache';

  @override
  Set<String> build() {
    final auth = ref.watch(authProvider);
    if (auth == AppAuthState.authenticated) {
      _sync();
    } else {
      state = {};
    }
    return {};
  }

  Future<void> _sync() async {
    // 1. Show cached instantly
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getStringList(_cacheKey);
    if (cached != null && cached.isNotEmpty) {
      state = cached.toSet();
    }

    // 2. Fetch real data from Supabase (always wins)
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final data = await _supabase.from('favorites')
          .select('product_id').eq('user_id', userId);
      final ids = (data as List).map((r) => r['product_id'] as String).toSet();
      state = ids;
      await prefs.setStringList(_cacheKey, ids.toList());
    } catch (_) {}
  }

  Future<void> toggle(String productId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final updated = {...state};
    if (updated.contains(productId)) {
      updated.remove(productId);
      try {
        await _supabase.from('favorites').delete()
            .eq('user_id', userId).eq('product_id', productId);
      } catch (_) {}
    } else {
      updated.add(productId);
      try {
        await _supabase.from('favorites').insert({
          'user_id': userId, 'product_id': productId,
        });
      } catch (_) {}
    }
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_cacheKey, updated.toList());
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);
