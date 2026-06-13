import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/bindings/initial_binding.dart';
import 'app/core/constants/app_constants.dart';
import 'app/core/controllers/theme_controller.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await GetStorage.init();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    // ignore: deprecated_member_use
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Register ThemeController before runApp so themeMode is available during build.
  Get.put(ThemeController(), permanent: true);

  runApp(const MenusApp());
}

class MenusApp extends StatelessWidget {
  const MenusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeController.to.themeMode,
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),
    );
  }
}
