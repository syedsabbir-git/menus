import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/auth_repo.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../routes/app_routes.dart';

class CustomerProfileController extends GetxController {
  String fullName = '';
  String email = '';
  String phone = '';
  String deliveryAddress = '';
  bool isLoading = true;
  bool isSaving = false;

  final addressController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final _repo = AuthRepo();

  @override
  void onReady() {
    super.onReady();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading = true;
    update();
    try {
      final userId = StorageService.to.userId!;
      final data = await _repo.fetchProfile(userId);
      if (data != null) {
        fullName = data['full_name'] as String? ?? '';
        phone = data['phone'] as String? ?? '';
        deliveryAddress = data['delivery_address'] as String? ?? '';
        addressController.text = deliveryAddress;
      }
      email = SupabaseService.to.auth.currentUser?.email ?? '';
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> saveAddress() async {
    if (!formKey.currentState!.validate()) return;
    isSaving = true;
    update();
    try {
      final userId = StorageService.to.userId!;
      await _repo.updateProfile(userId, {
        'delivery_address': addressController.text.trim(),
      });
      deliveryAddress = addressController.text.trim();
      AppSnackBar.success('Delivery address updated.');
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
    } finally {
      isSaving = false;
      update();
    }
  }

  Future<void> logout() async {
    await SupabaseService.to.auth.signOut();
    await StorageService.to.clearSession();
    Get.offAllNamed(Routes.LOGIN);
  }

  @override
  void onClose() {
    addressController.dispose();
    super.onClose();
  }
}
