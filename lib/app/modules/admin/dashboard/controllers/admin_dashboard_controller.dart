import 'package:get/get.dart';
import '../../../../data/repositories/restaurant_repo.dart';
import '../../../../data/repositories/auth_repo.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/helpers.dart';

class AdminDashboardController extends GetxController {
  int totalRestaurants = 0;
  int openRestaurants = 0;
  int totalUsers = 0;
  int totalVendors = 0;
  bool isLoading = true;

  final _restaurantRepo = RestaurantRepo();
  final _authRepo = AuthRepo();

  @override
  void onReady() {
    super.onReady();
    fetchStats();
  }

  Future<void> fetchStats() async {
    isLoading = true;
    update();
    try {
      final restaurants = await _restaurantRepo.fetchAll();
      final profiles = await _authRepo.fetchAllProfiles();

      totalRestaurants = restaurants.length;
      openRestaurants = restaurants.where((r) => r.isOpen).length;
      totalUsers = profiles.length;
      totalVendors = profiles.where((p) => p['role'] == 'vendor').length;
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
    } finally {
      isLoading = false;
      update();
    }
  }
}
