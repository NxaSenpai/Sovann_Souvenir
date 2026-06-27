import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesNotifier extends Notifier<Set<String>> {
  static const _key = 'favorite_ids';

  @override
  Set<String> build() {
    _load();
    return {};
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key) ?? [];
    state = ids.toSet();
  }

  Future<void> toggle(String id) async {
    final updated = {...state};
    if (updated.contains(id)) { updated.remove(id); }
    else { updated.add(id); }
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, updated.toList());
  }

  bool isFavorite(String id) => state.contains(id);
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);