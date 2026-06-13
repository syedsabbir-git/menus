import '../../core/enums/order_status.dart';
import 'order_item_model.dart';

class OrderModel {
  final String id;
  final String customerId;
  final String restaurantId;
  final OrderStatus status;
  final double total;
  final String deliveryAddress;
  final DateTime createdAt;
  // Denormalized at order-creation time — no profile join needed
  final String? customerName;
  final String? customerPhone;
  final String? rejectionReason;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.restaurantId,
    required this.status,
    required this.total,
    required this.deliveryAddress,
    required this.createdAt,
    this.customerName,
    this.customerPhone,
    this.rejectionReason,
    this.items = const [],
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
      customerName: map['customer_name'] as String?,
      customerPhone: map['customer_phone'] as String?,
      rejectionReason: map['rejection_reason'] as String?,
    );
  }

  /// Returns a copy with items attached (items come from a separate batch query).
  OrderModel withItems(List<OrderItemModel> items) {
    return OrderModel(
      id: id,
      customerId: customerId,
      restaurantId: restaurantId,
      status: status,
      total: total,
      deliveryAddress: deliveryAddress,
      createdAt: createdAt,
      customerName: customerName,
      customerPhone: customerPhone,
      rejectionReason: rejectionReason,
      items: items,
    );
  }

  OrderModel copyWith({
    OrderStatus? status,
    String? rejectionReason,
    List<OrderItemModel>? items,
  }) {
    return OrderModel(
      id: id,
      customerId: customerId,
      restaurantId: restaurantId,
      status: status ?? this.status,
      total: total,
      deliveryAddress: deliveryAddress,
      createdAt: createdAt,
      customerName: customerName,
      customerPhone: customerPhone,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      items: items ?? this.items,
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
