import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/checkout_controller.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/utils/validators.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Delivery Details', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              AppTextField(
                hint: 'Hall name, room number, or address',
                label: 'Delivery Address',
                controller: controller.addressController,
                maxLines: 2,
                validator: (v) => Validators.required(v, fieldName: 'Delivery address'),
              ),
              const SizedBox(height: 32),
              Obx(() => PrimaryButton(
                    label: 'Place Order',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.placeOrder,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
