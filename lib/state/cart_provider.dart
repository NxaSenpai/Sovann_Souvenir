import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shopping cart — product ID → quantity. Persisted to SharedPreferences.
class CartNotifier extends Notifier<Map<String, int>> {
  static const _key = 'cart';

  @override
  Map<String, int> build() {
    _load();
    return {};
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      state = decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state));
  }

  void add(String productId) {
    state = {...state, productId: (state[productId] ?? 0) + 1};
    _save();
  }

  void remove(String productId) {
    if (!state.containsKey(productId)) return;
    final updated = Map<String, int>.from(state);
    if (updated[productId]! <= 1) {
      updated.remove(productId);
    } else {
      updated[productId] = updated[productId]! - 1;
    }
    state = updated;
    _save();
  }

  void deleteItem(String productId) {
    state = Map<String, int>.from(state)..remove(productId);
    _save();
  }

  void clearAll() {
    state = {};
    _save();
  }

  int count(String id) => state[id] ?? 0;
  int get totalItems => state.values.fold(0, (a, b) => a + b);
  bool get isEmpty => state.isEmpty;
}

final cartProvider = NotifierProvider<CartNotifier, Map<String, int>>(
  CartNotifier.new,
);
