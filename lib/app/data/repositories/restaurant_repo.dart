import '../models/restaurant_model.dart';
import '../services/supabase_service.dart';
import '../../core/constants/supabase_tables.dart';

class RestaurantRepo {
  final _svc = SupabaseService.to;

  Future<List<RestaurantModel>> fetchAll() async {
    final data = await _svc.client
        .from(SupabaseTables.restaurants)
        .select()
        .order('name');
    return (data as List).map((e) => RestaurantModel.fromMap(e)).toList();
  }

  Future<RestaurantModel?> fetchById(String id) async {
    final data = await _svc.client
        .from(SupabaseTables.restaurants)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return RestaurantModel.fromMap(data);
  }

  Future<RestaurantModel?> fetchByOwnerId(String ownerId) async {
    final data = await _svc.client
        .from(SupabaseTables.restaurants)
        .select()
        .eq('owner_id', ownerId)
        .maybeSingle();
    if (data == null) return null;
    return RestaurantModel.fromMap(data);
  }

  Future<void> updateOpenStatus(String id, bool isOpen) async {
    await _svc.client
        .from(SupabaseTables.restaurants)
        .update({'is_open': isOpen})
        .eq('id', id);
  }
}
