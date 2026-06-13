import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../data/models/restaurant_model.dart';
import '../../../../data/repositories/restaurant_repo.dart';
import '../../../../data/repositories/order_repo.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../data/services/storage_service.dart';

class VendorDashboardController extends GetxController {
  RestaurantModel? restaurant;
  bool isLoading = true;
  bool isToggling = false;
  int pendingOrderCount = 0;

  final _repo = RestaurantRepo();
  final _orderRepo = OrderRepo();
  RealtimeChannel? _countChannel;

  @override
  void onReady() {
    super.onReady();
    fetchRestaurant();
  }

  @override
  void onClose() {
    if (_countChannel != null) {
      SupabaseService.to.client.removeChannel(_countChannel!);
    }
    super.onClose();
  }

  // ── Fetch ─────────────────────────────────────────────────────────────────

  Future<void> fetchRestaurant() async {
    isLoading = true;
    update();
    try {
      final userId = StorageService.to.userId!;
      restaurant = await _repo.fetchByOwnerId(userId);
      if (restaurant != null) {
        await _fetchPendingCount();
        _subscribeRealtime();
      }
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> _fetchPendingCount() async {
    try {
      pendingOrderCount = await _orderRepo.fetchPendingCount(restaurant!.id);
      update();
    } catch (_) {
      // Non-critical: leave count as-is on failure
    }
  }

  // ── Toggle open/closed ────────────────────────────────────────────────────

  Future<void> toggleOpen() async {
    if (restaurant == null || isToggling) return;
    isToggling = true;
    update();
    try {
      final newStatus = !restaurant!.isOpen;
      await _repo.updateOpenStatus(restaurant!.id, newStatus);
      await fetchRestaurant();
      AppSnackBar.success(
        newStatus ? 'Restaurant is now open.' : 'Restaurant is now closed.',
      );
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
    } finally {
      isToggling = false;
      update();
    }
  }

  // ── Realtime ──────────────────────────────────────────────────────────────

  void _subscribeRealtime() {
    // Cancel any existing subscription before re-subscribing
    if (_countChannel != null) {
      SupabaseService.to.client.removeChannel(_countChannel!);
    }

    _countChannel = SupabaseService.to.client
        .channel('vendor_dashboard_${restaurant!.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: SupabaseTables.orders,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'restaurant_id',
            value: restaurant!.id,
          ),
          callback: (_) => _fetchPendingCount(),
        )
        .subscribe();
  }
}
