import 'product.dart';

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
}
