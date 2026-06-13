import 'dart:convert';
import 'product.dart';
import '../data/mock_repository.dart';

enum CartItemStatus { pending, confirmed }

class CartItem {
  final String id;
  final Product product;
  final bool giftWrap;
  final String personalMessage;
  final DateTime? deliveryDate;
  final String timeSlot;
  final double totalPrice;
  final CartItemStatus status;
  final DateTime createdAt;

  const CartItem({
    required this.id,
    required this.product,
    required this.giftWrap,
    required this.personalMessage,
    this.deliveryDate,
    required this.timeSlot,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  CartItem copyWith({CartItemStatus? status}) => CartItem(
    id: id,
    product: product,
    giftWrap: giftWrap,
    personalMessage: personalMessage,
    deliveryDate: deliveryDate,
    timeSlot: timeSlot,
    totalPrice: totalPrice,
    status: status ?? this.status,
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': product.id,
    'giftWrap': giftWrap,
    'personalMessage': personalMessage,
    'deliveryDate': deliveryDate?.toIso8601String(),
    'timeSlot': timeSlot,
    'totalPrice': totalPrice,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final product = MockRepository.instance.products
        .firstWhere((p) => p.id == json['productId']);
    return CartItem(
      id: json['id'],
      product: product,
      giftWrap: json['giftWrap'],
      personalMessage: json['personalMessage'] ?? '',
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
      timeSlot: json['timeSlot'] ?? '',
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: CartItemStatus.values.firstWhere(
        (s) => s.name == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  static String listToJson(List<CartItem> items) =>
      json.encode(items.map((e) => e.toJson()).toList());

  static List<CartItem> listFromJson(String jsonStr) {
    final list = json.decode(jsonStr) as List;
    return list.map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}
