import 'package:get/get.dart';
import '../controllers/post_menu_controller.dart';

class PostMenuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PostMenuController(), fenix: true);
  }
}
