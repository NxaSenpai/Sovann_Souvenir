class OrderItem {
  final String productId;
  final String? productName;
  final String? productImage;
  final int quantity;
  final double price;

  const OrderItem({
    required this.productId,
    this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String?,
      productImage: json['product_image'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['price_at_time'] as num?)?.toDouble() ?? 0,
    );
  }
}

class CustomerOrder {
  final String id;
  final String status;
  final double total;
  final bool giftWrap;
  final String? personalMessage;
  final String? deliveryDate;
  final String? timeSlot;
  final DateTime createdAt;
  final List<OrderItem> items;

  const CustomerOrder({
    required this.id,
    required this.status,
    required this.total,
    required this.giftWrap,
    this.personalMessage,
    this.deliveryDate,
    this.timeSlot,
    required this.createdAt,
    this.items = const [],
  });

  factory CustomerOrder.fromJson(Map<String, dynamic> json) {
    return CustomerOrder(
      id: json['id'] as String,
      status: json['status'] as String? ?? 'pending',
      total: (json['total'] as num?)?.toDouble() ?? 0,
      giftWrap: json['gift_wrap'] as bool? ?? false,
      personalMessage: json['personal_message'] as String?,
      deliveryDate: json['delivery_date'] as String?,
      timeSlot: json['time_slot'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      items: (json['order_items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending':    return 'Pending';
      case 'confirmed':  return 'Confirmed';
      case 'processing': return 'Processing';
      case 'shipped':    return 'Shipped';
      case 'delivered':  return 'Delivered';
      case 'cancelled':  return 'Cancelled';
      default:           return status;
    }
  }
}
