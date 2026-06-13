import 'package:get/get.dart';
import '../../../../data/models/cart_item_model.dart';
import '../../../customer/restaurant_detail/controllers/restaurant_detail_controller.dart';

class CartController extends GetxController {
  late final RestaurantDetailController _detailCtrl;

  List<CartItemModel> get items => _detailCtrl.cart;
  double get total => _detailCtrl.cartTotal;

  @override
  void onInit() {
    super.onInit();
    _detailCtrl = Get.arguments as RestaurantDetailController;
  }
}
