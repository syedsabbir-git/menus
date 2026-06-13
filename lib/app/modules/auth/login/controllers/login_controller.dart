import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/auth_repo.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/error_handler.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool obscurePassword = true;

  final _repo = AuthRepo();

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    update();
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading = true;
    update();
    try {
      final response = await _repo.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final user = response.user;
      if (user == null) {
        AppSnackBar.error('Login failed. Please try again.');
        return;
      }

      if (user.emailConfirmedAt == null) {
        AppSnackBar.warning(
          'Please check your email and confirm your account before signing in.',
        );
        await _repo.signOut();
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
          Get.offAllNamed(Routes.CUSTOMER_SHELL);
      }
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
    } finally {
      isLoading = false;
      update();
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
