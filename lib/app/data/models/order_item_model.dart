class OrderItemModel {
  final String id;
  final String orderId;
  final String menuItemId;
  final int quantity;
  final double unitPrice;
  final String? menuItemName; // populated via menu_items join

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    required this.quantity,
    required this.unitPrice,
    this.menuItemName,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    final menuItem = map['menu_item'] as Map<String, dynamic>?;
    return OrderItemModel(
      id: map['id'] as String,
      orderId: map['order_id'] as String,
      menuItemId: map['menu_item_id'] as String,
      quantity: map['quantity'] as int,
      unitPrice: (map['unit_price'] as num).toDouble(),
      menuItemName: menuItem?['name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'menu_item_id': menuItemId,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }

  double get subtotal => unitPrice * quantity;
}
