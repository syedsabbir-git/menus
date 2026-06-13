import 'package:get/get.dart';
import '../controllers/menu_management_controller.dart';

class MenuManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MenuManagementController>(() => MenuManagementController());
  }
}
