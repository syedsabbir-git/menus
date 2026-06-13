import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/restaurant_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/restaurant_repo.dart';
import '../../../../data/repositories/auth_repo.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/error_handler.dart';

class AdminVendorsController extends GetxController {
  List<RestaurantModel> restaurants = [];
  List<UserModel> vendorUsers = [];
  bool isLoading = true;
  String togglingId = '';

  final _repo = RestaurantRepo();
  final _authRepo = AuthRepo();

  @override
  void onReady() {
    super.onReady();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading = true;
    update();
    try {
      final results = await Future.wait([
        _repo.fetchAll(),
        _authRepo.fetchProfilesByRole('vendor'),
      ]);
      restaurants = results[0] as List<RestaurantModel>;
      vendorUsers = (results[1] as List<Map<String, dynamic>>)
          .map((m) => UserModel.fromMap(m))
          .toList();
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> toggleOpenStatus(RestaurantModel r) async {
    if (togglingId == r.id) return;
    togglingId = r.id;
    update();
    try {
      final newStatus = !r.isOpen;
      await _repo.updateOpenStatus(r.id, newStatus);
      final idx = restaurants.indexWhere((x) => x.id == r.id);
      if (idx != -1) {
        restaurants[idx] = RestaurantModel(
          id: r.id,
          ownerId: r.ownerId,
          name: r.name,
          description: r.description,
          imageUrl: r.imageUrl,
          isOpen: newStatus,
          createdAt: r.createdAt,
        );
      }
      AppSnackBar.success(
          newStatus ? '${r.name} is now open.' : '${r.name} is now closed.');
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
    } finally {
      togglingId = '';
      update();
    }
  }

  Future<void> createRestaurant(Map<String, dynamic> data) async {
    try {
      final created = await _repo.create(data);
      restaurants.add(created);
      update();
      AppSnackBar.success('${created.name} added successfully.');
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
    }
  }

  Future<void> updateRestaurant(String id, Map<String, dynamic> data) async {
    try {
      await _repo.update(id, data);
      await fetchAll();
      AppSnackBar.success('Restaurant updated.');
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
    }
  }

  Future<void> deleteRestaurant(RestaurantModel r) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Restaurant'),
        content: Text('Delete "${r.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _repo.delete(r.id);
      restaurants.removeWhere((x) => x.id == r.id);
      update();
      AppSnackBar.success('${r.name} deleted.');
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
    }
  }
}
