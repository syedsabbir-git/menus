import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../services/supabase_service.dart';
import '../../core/constants/supabase_tables.dart';

class OrderRepo {
  final _svc = SupabaseService.to;

  static const int defaultPageSize = 20;

  // ── Place order ───────────────────────────────────────────────────────────

  Future<OrderModel> placeOrder({
    required String customerId,
    required String restaurantId,
    required double total,
    required String deliveryAddress,
    required List<Map<String, dynamic>> items,
    String? customerName,
    String? customerPhone,
  }) async {
    final payload = <String, dynamic>{
      'customer_id': customerId,
      'restaurant_id': restaurantId,
      'status': 'pending',
      'total': total,
      'delivery_address': deliveryAddress,
    };
    if (customerName != null) payload['customer_name'] = customerName;
    if (customerPhone != null) payload['customer_phone'] = customerPhone;

    final orderData = await _svc.client
        .from(SupabaseTables.orders)
        .insert(payload)
        .select()
        .single();

    final orderId = orderData['id'] as String;
    final orderItems = items.map((i) => {...i, 'order_id': orderId}).toList();
    await _svc.client.from(SupabaseTables.orderItems).insert(orderItems);

    return OrderModel.fromMap(orderData);
  }

  // ── Customer orders ───────────────────────────────────────────────────────

  Future<List<OrderModel>> fetchCustomerOrders(String customerId) async {
    final data = await _svc.client
        .from(SupabaseTables.orders)
        .select()
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => OrderModel.fromMap(e)).toList();
  }

  // ── Vendor orders (paginated) ─────────────────────────────────────────────

  /// Two DB round-trips:
  /// 1. Paginated orders for this restaurant.
  /// 2. All items for those orders, joined to menu_items for names.
  Future<List<OrderModel>> fetchRestaurantOrders(
    String restaurantId, {
    int page = 0,
    int pageSize = defaultPageSize,
    bool newestFirst = true,
    String? statusFilter,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;

    var query = _svc.client
        .from(SupabaseTables.orders)
        .select()
        .eq('restaurant_id', restaurantId);

    if (statusFilter != null) {
      query = query.eq('status', statusFilter);
    }

    final rawOrders = await query
        .order('created_at', ascending: !newestFirst)
        .range(from, to);

    final rows = List<Map<String, dynamic>>.from(rawOrders as List);
    if (rows.isEmpty) return [];

    // Batch-fetch items for all orders in one query, joined to menu names
    final orderIds = rows.map((o) => o['id'] as String).toList();
    final itemRows = await _svc.client
        .from(SupabaseTables.orderItems)
        .select('*, menu_item:${SupabaseTables.menuItems}(name)')
        .inFilter('order_id', orderIds);

    final itemsByOrderId = <String, List<OrderItemModel>>{};
    for (final r in itemRows as List) {
      final row = r as Map<String, dynamic>;
      final oid = row['order_id'] as String;
      itemsByOrderId.putIfAbsent(oid, () => []).add(OrderItemModel.fromMap(row));
    }

    return rows.map((o) {
      final order = OrderModel.fromMap(o);
      final items = itemsByOrderId[o['id'] as String] ?? [];
      return order.withItems(items);
    }).toList();
  }

  // ── Fetch items for a single order ───────────────────────────────────────

  Future<List<OrderItemModel>> fetchOrderItems(String orderId) async {
    final data = await _svc.client
        .from(SupabaseTables.orderItems)
        .select('*, menu_item:${SupabaseTables.menuItems}(name)')
        .eq('order_id', orderId);
    return (data as List)
        .map((e) => OrderItemModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // ── Pending count ─────────────────────────────────────────────────────────

  Future<int> fetchPendingCount(String restaurantId) async {
    final data = await _svc.client
        .from(SupabaseTables.orders)
        .select('id')
        .eq('restaurant_id', restaurantId)
        .eq('status', 'pending');
    return (data as List).length;
  }

  // ── Status updates ────────────────────────────────────────────────────────

  Future<void> acceptOrder(String orderId) async {
    await _svc.client
        .from(SupabaseTables.orders)
        .update({'status': 'confirmed'})
        .eq('id', orderId);
  }

  /// Requires: ALTER TABLE orders ADD COLUMN IF NOT EXISTS rejection_reason TEXT;
  Future<void> rejectOrder(String orderId, {String? reason}) async {
    final payload = <String, dynamic>{'status': 'cancelled'};
    if (reason != null && reason.isNotEmpty) {
      payload['rejection_reason'] = reason;
    }
    await _svc.client
        .from(SupabaseTables.orders)
        .update(payload)
        .eq('id', orderId);
  }

  Future<void> updateStatus(String orderId, String status) async {
    await _svc.client
        .from(SupabaseTables.orders)
        .update({'status': status})
        .eq('id', orderId);
  }
}
