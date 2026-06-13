import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSnackBar({required String message, bool isError = false}) {
  Get.snackbar(
    isError ? 'Error' : 'Success',
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
    borderRadius: 12,
    duration: const Duration(seconds: 3),
  );
}
