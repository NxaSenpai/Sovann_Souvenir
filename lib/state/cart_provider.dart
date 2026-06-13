import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

const _kCartKey = 'cart_items';

class CartNotifier extends AsyncNotifier<List<CartItem>> {
  @override
  Future<List<CartItem>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kCartKey);
    if (stored == null || stored.isEmpty) return [];
    try {
      return CartItem.listFromJson(stored);
    } catch (_) {
      return [];
    }
  }

  List<CartItem> get _items => state.value ?? [];

  Future<void> _persist(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCartKey, CartItem.listToJson(items));
  }

  Future<void> addItem(CartItem item) async {
    final items = [..._items, item];
    state = AsyncValue.data(items);
    await _persist(items);
    _scheduleAutoConfirm(item);
  }

  Future<void> removeItem(String id) async {
    final items = _items.where((item) => item.id != id).toList();
    state = AsyncValue.data(items);
    await _persist(items);
  }

  Future<void> markConfirmed(String id) async {
    final items = _items.map((item) {
      if (item.id == id) return item.copyWith(status: CartItemStatus.confirmed);
      return item;
    }).toList();
    state = AsyncValue.data(items);
    await _persist(items);
  }

  void _scheduleAutoConfirm(CartItem item) {
    Timer(const Duration(minutes: 5), () {
      markConfirmed(item.id);
    });
  }
}

final cartProvider = AsyncNotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);
