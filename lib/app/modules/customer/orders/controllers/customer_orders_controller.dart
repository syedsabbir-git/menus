import 'package:get/get.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repo.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/error_handler.dart';

class CustomerOrdersController extends GetxController {
  List<OrderModel> orders = [];
  bool isLoading = true;

  final _repo = OrderRepo();

  @override
  void onReady() {
    super.onReady();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    isLoading = true;
    update();
    try {
      final userId = StorageService.to.userId!;
      orders = await _repo.fetchCustomerOrders(userId);
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
    } finally {
      isLoading = false;
      update();
    }
  }
}
