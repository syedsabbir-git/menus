import 'package:get/get.dart';

import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

import '../modules/auth/login/bindings/login_binding.dart';
import '../modules/auth/login/views/login_view.dart';
import '../modules/auth/register/bindings/register_binding.dart';
import '../modules/auth/register/views/register_view.dart';

import '../modules/customer/shell/bindings/customer_shell_binding.dart';
import '../modules/customer/shell/views/customer_shell_view.dart';
import '../modules/customer/restaurant_detail/bindings/restaurant_detail_binding.dart';
import '../modules/customer/restaurant_detail/views/restaurant_detail_view.dart';
import '../modules/customer/cart/bindings/cart_binding.dart';
import '../modules/customer/cart/views/cart_view.dart';
import '../modules/customer/checkout/bindings/checkout_binding.dart';
import '../modules/customer/checkout/views/checkout_view.dart';

import '../modules/vendor/dashboard/bindings/vendor_dashboard_binding.dart';
import '../modules/vendor/dashboard/views/vendor_dashboard_view.dart';
import '../modules/vendor/menu_management/bindings/menu_management_binding.dart';
import '../modules/vendor/menu_management/views/menu_management_view.dart';
import '../modules/vendor/orders/bindings/vendor_orders_binding.dart';
import '../modules/vendor/orders/views/vendor_orders_view.dart';
import '../modules/vendor/post_menu/bindings/post_menu_binding.dart';
import '../modules/vendor/post_menu/views/post_menu_view.dart';

import '../modules/admin/dashboard/bindings/admin_dashboard_binding.dart';
import '../modules/admin/dashboard/views/admin_dashboard_view.dart';
import '../modules/admin/vendors/bindings/admin_vendors_binding.dart';
import '../modules/admin/vendors/views/admin_vendors_view.dart';
import '../modules/admin/users/bindings/admin_users_binding.dart';
import '../modules/admin/users/views/admin_users_view.dart';

import '../core/middleware/role_middleware.dart';
import 'app_routes.dart';

class AppPages {
  static final _customer = [RoleMiddleware(requiredRole: 'customer')];
  static final _vendor   = [RoleMiddleware(requiredRole: 'vendor')];
  static final _admin    = [RoleMiddleware(requiredRole: 'admin')];

  static final routes = [
    GetPage(name: Routes.SPLASH, page: () => const SplashView(), binding: SplashBinding()),
    GetPage(name: Routes.LOGIN,  page: () => const LoginView(),  binding: LoginBinding()),
    GetPage(name: Routes.REGISTER, page: () => const RegisterView(), binding: RegisterBinding()),

    // Customer
    GetPage(
      name: Routes.CUSTOMER_SHELL,
      page: () => const CustomerShellView(),
      binding: CustomerShellBinding(),
      middlewares: _customer,
    ),
    GetPage(
      name: Routes.RESTAURANT_DETAIL,
      page: () => const RestaurantDetailView(),
      binding: RestaurantDetailBinding(),
      middlewares: _customer,
    ),
    GetPage(
      name: Routes.CART,
      page: () => const CartView(),
      binding: CartBinding(),
      middlewares: _customer,
    ),
    GetPage(
      name: Routes.CHECKOUT,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
      middlewares: _customer,
    ),

    // Vendor
    GetPage(
      name: Routes.VENDOR_DASHBOARD,
      page: () => const VendorDashboardView(),
      binding: VendorDashboardBinding(),
      middlewares: _vendor,
    ),
    GetPage(
      name: Routes.MENU_MANAGEMENT,
      page: () => const MenuManagementView(),
      binding: MenuManagementBinding(),
      middlewares: _vendor,
    ),
    GetPage(
      name: Routes.VENDOR_ORDERS,
      page: () => const VendorOrdersView(),
      binding: VendorOrdersBinding(),
      middlewares: _vendor,
    ),
    GetPage(
      name: Routes.POST_MENU,
      page: () => const PostMenuView(),
      binding: PostMenuBinding(),
      middlewares: _vendor,
    ),

    // Admin
    GetPage(
      name: Routes.ADMIN_DASHBOARD,
      page: () => const AdminDashboardView(),
      binding: AdminDashboardBinding(),
      middlewares: _admin,
    ),
    GetPage(
      name: Routes.ADMIN_VENDORS,
      page: () => const AdminVendorsView(),
      binding: AdminVendorsBinding(),
      middlewares: _admin,
    ),
    GetPage(
      name: Routes.ADMIN_USERS,
      page: () => const AdminUsersView(),
      binding: AdminUsersBinding(),
      middlewares: _admin,
    ),
  ];
}
