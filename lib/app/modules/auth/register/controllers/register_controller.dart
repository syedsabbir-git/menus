import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/auth_repo.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/error_handler.dart';

class RegisterController extends GetxController {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
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

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    isLoading = true;
    update();
    try {
      await _repo.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        fullName: nameController.text.trim(),
        phone: phoneController.text.trim(),
      );
      AppSnackBar.success('Account created! Please sign in.');
      Get.back();
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
    } finally {
      isLoading = false;
      update();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
