import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../../core/constants/supabase_tables.dart';

class AuthRepo {
  final _svc = SupabaseService.to;

  User? get currentUser => _svc.auth.currentUser;

  Future<AuthResponse> signIn({required String email, required String password}) {
    return _svc.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) {
    return _svc.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'phone': phone},
    );
  }

  Future<void> signOut() => _svc.auth.signOut();

  /// Returns the role string from the profiles table for the given user id.
  Future<String> fetchProfileRole(String userId) async {
    final data = await _svc.client
        .from(SupabaseTables.profiles)
        .select('role')
        .eq('id', userId)
        .single();
    return data['role'] as String? ?? 'customer';
  }

  Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    return _svc.client
        .from(SupabaseTables.profiles)
        .select()
        .eq('id', userId)
        .maybeSingle();
  }
}
