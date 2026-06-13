import 'package:get/get.dart';
import '../../../../data/models/restaurant_model.dart';
import '../../../../data/repositories/restaurant_repo.dart';

class CustomerHomeController extends GetxController {
  final restaurants = <RestaurantModel>[].obs;
  final isLoading = true.obs;
  final error = ''.obs;

  final _repo = RestaurantRepo();

  @override
  void onReady() {
    super.onReady();
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    isLoading.value = true;
    error.value = '';
    try {
      restaurants.value = await _repo.fetchAll();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
