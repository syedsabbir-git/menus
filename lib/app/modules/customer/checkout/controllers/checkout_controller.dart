import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/order_repo.dart';
import '../../../../data/repositories/auth_repo.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../routes/app_routes.dart';
import '../../../customer/cart/controllers/cart_controller.dart';

class CheckoutController extends GetxController {
  final addressController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isLoading = false;

  late final CartController _cartCtrl;
  final _orderRepo = OrderRepo();
  final _authRepo = AuthRepo();

  String? _customerName;
  String? _customerPhone;

  @override
  void onInit() {
    super.onInit();
    _cartCtrl = Get.arguments as CartController;
    _fetchCustomerProfile();
  }

  // Fetch in the background while the user fills the address field
  Future<void> _fetchCustomerProfile() async {
    try {
      final userId = StorageService.to.userId!;
      final profile = await _authRepo.fetchProfile(userId);
      _customerName = profile?['full_name'] as String?;
      _customerPhone = profile?['phone'] as String?;
    } catch (_) {
      // Non-critical: order will be placed without denormalized customer info
    }
  }

  Future<void> placeOrder() async {
    if (!formKey.currentState!.validate()) return;
    isLoading = true;
    update();
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
        customerName: _customerName,
        customerPhone: _customerPhone,
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
