import 'package:get/get.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repo.dart';
import '../../../../data/services/storage_service.dart';

class CustomerOrdersController extends GetxController {
  final orders = <OrderModel>[].obs;
  final isLoading = true.obs;

  final _repo = OrderRepo();

  @override
  void onReady() {
    super.onReady();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    try {
      final userId = StorageService.to.userId!;
      orders.value = await _repo.fetchCustomerOrders(userId);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }
}
