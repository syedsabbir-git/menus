import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends GetxService {
  static SupabaseService get to => Get.find();

  SupabaseClient get client => Supabase.instance.client;
  GoTrueClient get auth => client.auth;
}
