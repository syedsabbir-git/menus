import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customer_shell_controller.dart';
import '../../home/views/customer_home_view.dart';
import '../../orders/views/customer_orders_view.dart';
import '../../profile/views/customer_profile_view.dart';
import '../../../../core/theme/app_colors.dart';

class CustomerShellView extends GetView<CustomerShellController> {
  const CustomerShellView({super.key});

  static const _pages = [
    CustomerHomeView(),
    CustomerOrdersView(),
    CustomerProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomerShellController>(
      builder: (_) => Scaffold(
        body: IndexedStack(
          index: controller.selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.selectedIndex,
          onTap: controller.changeTab,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          backgroundColor: Theme.of(context).colorScheme.surface,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_outlined),
              activeIcon: Icon(Icons.restaurant_menu),
              label: 'Restaurants',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
