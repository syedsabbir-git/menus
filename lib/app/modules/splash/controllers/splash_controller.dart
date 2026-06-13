import 'package:get/get.dart';
import '../../../data/repositories/auth_repo.dart';
import '../../../data/services/storage_service.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final repo = AuthRepo();
    final user = repo.currentUser;

    if (user == null) {
      Get.offAllNamed(Routes.LOGIN);
      return;
    }

    try {
      final role = await repo.fetchProfileRole(user.id);
      await StorageService.to.saveSession(role: role, userId: user.id);

      switch (role) {
        case 'vendor':
          Get.offAllNamed(Routes.VENDOR_DASHBOARD);
        case 'admin':
          Get.offAllNamed(Routes.ADMIN_DASHBOARD);
        default:
          Get.offAllNamed(Routes.CUSTOMER_HOME);
      }
    } catch (_) {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
