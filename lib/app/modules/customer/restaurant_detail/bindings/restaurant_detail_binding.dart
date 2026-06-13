import 'package:get/get.dart';
import '../controllers/restaurant_detail_controller.dart';

class RestaurantDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RestaurantDetailController>(() => RestaurantDetailController());
  }
}
