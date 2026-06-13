import 'package:get/get.dart';
import '../controllers/customer_shell_controller.dart';
import '../../home/controllers/customer_home_controller.dart';
import '../../orders/controllers/customer_orders_controller.dart';
import '../../profile/controllers/customer_profile_controller.dart';

class CustomerShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CustomerShellController());
    Get.put(CustomerHomeController());
    Get.put(CustomerOrdersController());
    Get.put(CustomerProfileController());
  }
}
