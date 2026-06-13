import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void addItem(CartItem item) {
    state = [...state, item];
    _scheduleAutoConfirm(item);
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void markConfirmed(String id) {
    state = state.map((item) {
      if (item.id == id) return item.copyWith(status: CartItemStatus.confirmed);
      return item;
    }).toList();
  }

  void _scheduleAutoConfirm(CartItem item) {
    Timer(const Duration(minutes: 5), () {
      markConfirmed(item.id);
    });
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);
