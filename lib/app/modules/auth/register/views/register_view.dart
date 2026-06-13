import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Join Menus', style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Text('Order food from your campus restaurants.', style: AppTextStyles.bodySecondary),
                const SizedBox(height: 32),
                AppTextField(
                  hint: 'Full Name',
                  label: 'Name',
                  controller: controller.nameController,
                  validator: (v) => Validators.required(v, fieldName: 'Name'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  hint: '+8801XXXXXXXXX',
                  label: 'Phone',
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                const SizedBox(height: 16),
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
                      label: 'Create Account',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.register,
                    )),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?', style: AppTextStyles.bodySecondary),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Sign In', style: TextStyle(color: AppColors.primary)),
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
