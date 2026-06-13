import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/restaurant_model.dart';
import '../../../../data/repositories/order_repo.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/enums/order_status.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/error_handler.dart';

class VendorOrdersController extends GetxController {
  late final RestaurantModel restaurant;

  List<OrderModel> orders = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;

  OrderStatus? statusFilter;
  bool newestFirst = true;

  static const int _pageSize = OrderRepo.defaultPageSize;
  int _currentPage = 0;

  final _repo = OrderRepo();
  final scrollController = ScrollController();
  late final RealtimeChannel _ordersChannel;

  @override
  void onInit() {
    super.onInit();
    restaurant = Get.arguments as RestaurantModel;
    scrollController.addListener(_onScroll);
    fetchOrders();
    _subscribeRealtime();
  }

  @override
  void onClose() {
    SupabaseService.to.client.removeChannel(_ordersChannel);
    scrollController.dispose();
    super.onClose();
  }

  // ── Scroll ────────────────────────────────────────────────────────────────

  void _onScroll() {
    final pos = scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) loadMore();
  }

  // ── Fetch ─────────────────────────────────────────────────────────────────

  Future<void> fetchOrders() async {
    _currentPage = 0;
    hasMore = true;
    isLoading = true;
    update();
    try {
      final result = await _repo.fetchRestaurantOrders(
        restaurant.id,
        page: 0,
        pageSize: _pageSize,
        newestFirst: newestFirst,
        statusFilter: statusFilter?.value,
      );
      orders = result;
      hasMore = result.length == _pageSize;
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore || isLoading) return;
    isLoadingMore = true;
    update();
    try {
      _currentPage++;
      final result = await _repo.fetchRestaurantOrders(
        restaurant.id,
        page: _currentPage,
        pageSize: _pageSize,
        newestFirst: newestFirst,
        statusFilter: statusFilter?.value,
      );
      orders.addAll(result);
      hasMore = result.length == _pageSize;
    } catch (e) {
      _currentPage--;
      AppSnackBar.error(ErrorHandler.parse(e));
    } finally {
      isLoadingMore = false;
      update();
    }
  }

  // ── Filter / sort ─────────────────────────────────────────────────────────

  void setStatusFilter(OrderStatus? status) {
    if (statusFilter == status) return;
    statusFilter = status;
    fetchOrders();
  }

  void toggleSort() {
    newestFirst = !newestFirst;
    fetchOrders();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> acceptOrder(String orderId) async {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    final original = orders[idx];
    orders[idx] = original.copyWith(status: OrderStatus.confirmed);
    update();
    try {
      await _repo.acceptOrder(orderId);
      AppSnackBar.success('Order accepted.');
    } catch (e) {
      orders[idx] = original;
      update();
      AppSnackBar.error(ErrorHandler.parse(e));
    }
  }

  Future<void> rejectOrder(String orderId, {String? reason}) async {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    final original = orders[idx];
    orders[idx] = original.copyWith(
      status: OrderStatus.cancelled,
      rejectionReason: reason,
    );
    update();
    try {
      await _repo.rejectOrder(orderId, reason: reason);
      AppSnackBar.success('Order rejected.');
    } catch (e) {
      orders[idx] = original;
      update();
      AppSnackBar.error(ErrorHandler.parse(e));
    }
  }

  // ── Realtime ──────────────────────────────────────────────────────────────

  void _subscribeRealtime() {
    _ordersChannel = SupabaseService.to.client
        .channel('vendor_orders_${restaurant.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseTables.orders,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'restaurant_id',
            value: restaurant.id,
          ),
          callback: _onNewOrder,
        )
        .subscribe();
  }

  Future<void> _onNewOrder(PostgresChangePayload payload) async {
    final record = payload.newRecord;
    final id = record['id'] as String?;
    if (id == null || orders.any((o) => o.id == id)) return;

    // New orders always arrive as 'pending'; skip if vendor is on a different filter
    if (statusFilter != null && statusFilter != OrderStatus.pending) return;

    // Customer name/phone are denormalized onto the order row — no extra query needed
    OrderModel order = OrderModel.fromMap(record);

    try {
      // Fetch items so the vendor sees what was ordered immediately
      final items = await _repo.fetchOrderItems(id);
      order = order.withItems(items);
    } catch (_) {
      // Degrade: show order without items, vendor can pull-to-refresh
    }

    newestFirst ? orders.insert(0, order) : orders.add(order);
    update();
    AppSnackBar.info('New order received!');
  }
}
