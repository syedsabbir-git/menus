import 'package:get/get.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/restaurant_model.dart';
import '../../../../data/repositories/order_repo.dart';
import '../../../../core/enums/order_status.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/error_handler.dart';

class VendorOrdersController extends GetxController {
  late final RestaurantModel restaurant;
  List<OrderModel> orders = [];
  bool isLoading = true;

  final _repo = OrderRepo();

  @override
  void onInit() {
    super.onInit();
    restaurant = Get.arguments as RestaurantModel;
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    isLoading = true;
    update();
    try {
      orders = await _repo.fetchRestaurantOrders(restaurant.id);
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    try {
      await _repo.updateStatus(orderId, status.value);
      fetchOrders();
      AppSnackBar.success('Order status updated to "${status.label}".');
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
    }
  }
}
