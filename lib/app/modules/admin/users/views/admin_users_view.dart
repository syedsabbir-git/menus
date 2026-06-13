import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_users_controller.dart';
import '../../../../core/widgets/empty_state.dart';

class AdminUsersView extends GetView<AdminUsersController> {
  const AdminUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: const EmptyState(
        message: 'User management coming soon.',
        icon: Icons.people_outline,
      ),
    );
  }
}
