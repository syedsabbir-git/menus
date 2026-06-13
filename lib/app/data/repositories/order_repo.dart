import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../services/supabase_service.dart';
import '../../core/constants/supabase_tables.dart';

class OrderRepo {
  final _svc = SupabaseService.to;

  Future<OrderModel> placeOrder({
    required String customerId,
    required String restaurantId,
    required double total,
    required String deliveryAddress,
    required List<Map<String, dynamic>> items,
  }) async {
    final orderData = await _svc.client
        .from(SupabaseTables.orders)
        .insert({
          'customer_id': customerId,
          'restaurant_id': restaurantId,
          'status': 'pending',
          'total': total,
          'delivery_address': deliveryAddress,
        })
        .select()
        .single();

    final orderId = orderData['id'] as String;
    final orderItems = items.map((i) => {...i, 'order_id': orderId}).toList();
    await _svc.client.from(SupabaseTables.orderItems).insert(orderItems);

    return OrderModel.fromMap(orderData);
  }

  Future<List<OrderModel>> fetchCustomerOrders(String customerId) async {
    final data = await _svc.client
        .from(SupabaseTables.orders)
        .select()
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => OrderModel.fromMap(e)).toList();
  }

  Future<List<OrderModel>> fetchRestaurantOrders(String restaurantId) async {
    final data = await _svc.client
        .from(SupabaseTables.orders)
        .select()
        .eq('restaurant_id', restaurantId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => OrderModel.fromMap(e)).toList();
  }

  Future<List<OrderItemModel>> fetchOrderItems(String orderId) async {
    final data = await _svc.client
        .from(SupabaseTables.orderItems)
        .select()
        .eq('order_id', orderId);
    return (data as List).map((e) => OrderItemModel.fromMap(e)).toList();
  }

  Future<void> updateStatus(String orderId, String status) async {
    await _svc.client
        .from(SupabaseTables.orders)
        .update({'status': status})
        .eq('id', orderId);
  }
}
