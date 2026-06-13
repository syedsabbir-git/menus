import 'package:get/get.dart';
import '../data/services/supabase_service.dart';
import '../data/services/storage_service.dart';
import '../core/controllers/theme_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SupabaseService(), permanent: true);
    Get.put(StorageService(), permanent: true);
    Get.put(ThemeController(), permanent: true);
  }
}
