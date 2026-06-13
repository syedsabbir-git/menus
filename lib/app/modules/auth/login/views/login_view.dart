import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../routes/app_routes.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.restaurant_menu, size: 56, color: AppColors.primary),
                const SizedBox(height: 24),
                Text('Welcome back!', style: AppTextStyles.h1),
                const SizedBox(height: 8),
                Text('Sign in to order food from your campus restaurants.',
                    style: AppTextStyles.bodySecondary),
                const SizedBox(height: 40),
                AppTextField(
                  hint: 'you@university.edu',
                  label: 'Email',
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                Obx(() => AppTextField(
                      hint: '••••••••',
                      label: 'Password',
                      controller: controller.passwordController,
                      obscureText: controller.obscurePassword.value,
                      validator: Validators.password,
                      suffixIcon: IconButton(
                        icon: Icon(controller.obscurePassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    )),
                const SizedBox(height: 32),
                Obx(() => PrimaryButton(
                      label: 'Sign In',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.login,
                    )),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?", style: AppTextStyles.bodySecondary),
                    TextButton(
                      onPressed: () => Get.toNamed(Routes.REGISTER),
                      child: const Text('Register', style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
