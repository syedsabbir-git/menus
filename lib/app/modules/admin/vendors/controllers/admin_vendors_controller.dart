import 'package:get/get.dart';
import '../../../../data/models/restaurant_model.dart';
import '../../../../data/repositories/restaurant_repo.dart';

class AdminVendorsController extends GetxController {
  final restaurants = <RestaurantModel>[].obs;
  final isLoading = true.obs;

  final _repo = RestaurantRepo();

  @override
  void onReady() {
    super.onReady();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    try {
      restaurants.value = await _repo.fetchAll();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }
}
