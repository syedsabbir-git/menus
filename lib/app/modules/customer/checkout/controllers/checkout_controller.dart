import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/order_repo.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../routes/app_routes.dart';
import '../../../customer/cart/controllers/cart_controller.dart';

class CheckoutController extends GetxController {
  final addressController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;

  late final CartController _cartCtrl;
  final _orderRepo = OrderRepo();

  @override
  void onInit() {
    super.onInit();
    _cartCtrl = Get.arguments as CartController;
  }

  Future<void> placeOrder() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      final userId = StorageService.to.userId!;
      final restaurantId = _cartCtrl.items.first.menuItem.restaurantId;
      final orderItems = _cartCtrl.items
          .map((c) => {
                'menu_item_id': c.menuItem.id,
                'quantity': c.quantity,
                'unit_price': c.menuItem.price,
              })
          .toList();

      await _orderRepo.placeOrder(
        customerId: userId,
        restaurantId: restaurantId,
        total: _cartCtrl.total,
        deliveryAddress: addressController.text.trim(),
        items: orderItems,
      );

      showSnackBar(message: 'Order placed successfully!');
      Get.offAllNamed(Routes.CUSTOMER_ORDERS);
    } catch (e) {
      showSnackBar(message: e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    addressController.dispose();
    super.onClose();
  }
}
