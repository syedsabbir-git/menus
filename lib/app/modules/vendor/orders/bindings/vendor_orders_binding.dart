import 'package:get/get.dart';
import '../controllers/vendor_orders_controller.dart';

class VendorOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorOrdersController>(() => VendorOrdersController());
  }
}
