import 'package:get/get.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/restaurant_model.dart';
import '../../../../data/repositories/order_repo.dart';
import '../../../../core/enums/order_status.dart';

class VendorOrdersController extends GetxController {
  late final RestaurantModel restaurant;
  final orders = <OrderModel>[].obs;
  final isLoading = true.obs;

  final _repo = OrderRepo();

  @override
  void onInit() {
    super.onInit();
    restaurant = Get.arguments as RestaurantModel;
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    try {
      orders.value = await _repo.fetchRestaurantOrders(restaurant.id);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    await _repo.updateStatus(orderId, status.value);
    fetchOrders();
  }
}
