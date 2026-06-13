import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/order_repo.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../routes/app_routes.dart';
import '../../../customer/restaurant_detail/controllers/restaurant_detail_controller.dart';

class CheckoutController extends GetxController {
  final addressController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isLoading = false;

  late final RestaurantDetailController _detailCtrl;
  final _orderRepo = OrderRepo();

  @override
  void onInit() {
    super.onInit();
    _detailCtrl = Get.arguments as RestaurantDetailController;
  }

  Future<void> placeOrder() async {
    if (!formKey.currentState!.validate()) return;
    isLoading = true;
    update();
    try {
      final userId = StorageService.to.userId!;
      final restaurantId = _detailCtrl.cart.first.menuItem.restaurantId;
      final orderItems = _detailCtrl.cart
          .map((c) => {
                'menu_item_id': c.menuItem.id,
                'quantity': c.quantity,
                'unit_price': c.menuItem.price,
              })
          .toList();

      await _orderRepo.placeOrder(
        customerId: userId,
        restaurantId: restaurantId,
        total: _detailCtrl.cartTotal,
        deliveryAddress: addressController.text.trim(),
        items: orderItems,
      );

      AppSnackBar.success('Order placed! We\'ll notify you when it\'s confirmed.');
      Get.offAllNamed(Routes.CUSTOMER_ORDERS);
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
    } finally {
      isLoading = false;
      update();
    }
  }

  @override
  void onClose() {
    addressController.dispose();
    super.onClose();
  }
}
