import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/auth_repo.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/utils/helpers.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final obscurePassword = true.obs;

  final _repo = AuthRepo();

  void togglePasswordVisibility() => obscurePassword.toggle();

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final response = await _repo.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final user = response.user;
      if (user == null) {
        showSnackBar(message: 'Login failed. Please try again.', isError: true);
        return;
      }

      final role = await _repo.fetchProfileRole(user.id);
      await StorageService.to.saveSession(role: role, userId: user.id);

      switch (role) {
        case 'vendor':
          Get.offAllNamed(Routes.VENDOR_DASHBOARD);
        case 'admin':
          Get.offAllNamed(Routes.ADMIN_DASHBOARD);
        default:
          Get.offAllNamed(Routes.CUSTOMER_HOME);
      }
    } catch (e) {
      showSnackBar(message: e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
