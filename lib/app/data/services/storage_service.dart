import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/storage_keys.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();

  final _box = GetStorage();

  String? get userRole => _box.read<String>(StorageKeys.userRole);
  String? get userId => _box.read<String>(StorageKeys.userId);

  Future<void> saveSession({required String role, required String userId}) async {
    await _box.write(StorageKeys.userRole, role);
    await _box.write(StorageKeys.userId, userId);
  }

  Future<void> clearSession() async {
    await _box.remove(StorageKeys.userRole);
    await _box.remove(StorageKeys.userId);
  }
}
