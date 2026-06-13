abstract class Routes {
  static const SPLASH = '/';
  static const LOGIN = '/login';
  static const REGISTER = '/register';

  // Customer
  static const CUSTOMER_SHELL = '/customer';
  static const CUSTOMER_HOME = '/customer/home';
  static const RESTAURANT_DETAIL = '/customer/restaurant';
  static const CART = '/customer/cart';
  static const CHECKOUT = '/customer/checkout';
  static const CUSTOMER_ORDERS = '/customer/orders';
  static const CUSTOMER_PROFILE = '/customer/profile';

  // Vendor
  static const VENDOR_DASHBOARD = '/vendor/dashboard';
  static const MENU_MANAGEMENT = '/vendor/menu';
  static const VENDOR_ORDERS = '/vendor/orders';
  static const VENDOR_PROFILE = '/vendor/profile';

  // Admin
  static const ADMIN_DASHBOARD = '/admin/dashboard';
  static const ADMIN_VENDORS = '/admin/vendors';
  static const ADMIN_USERS = '/admin/users';
}
