import '../../core/enums/order_status.dart';

class OrderModel {
  final String id;
  final String customerId;
  final String restaurantId;
  final OrderStatus status;
  final double total;
  final String deliveryAddress;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.restaurantId,
    required this.status,
    required this.total,
    required this.deliveryAddress,
    required this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as String,
      customerId: map['customer_id'] as String,
      restaurantId: map['restaurant_id'] as String,
      status: OrderStatusX.fromString(map['status'] as String? ?? 'pending'),
      total: (map['total'] as num).toDouble(),
      deliveryAddress: map['delivery_address'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'restaurant_id': restaurantId,
      'status': status.value,
      'total': total,
      'delivery_address': deliveryAddress,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
