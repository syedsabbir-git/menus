import '../models/menu_item_model.dart';
import '../services/supabase_service.dart';
import '../../core/constants/supabase_tables.dart';

class MenuRepo {
  final _svc = SupabaseService.to;

  Future<List<MenuItemModel>> fetchTodaysMenu(String restaurantId) async {
    final data = await _svc.client
        .from(SupabaseTables.menuItems)
        .select()
        .eq('restaurant_id', restaurantId)
        .eq('is_available_today', true);
    return (data as List).map((e) => MenuItemModel.fromMap(e)).toList();
  }

  Future<List<MenuItemModel>> fetchAllByRestaurant(String restaurantId) async {
    final data = await _svc.client
        .from(SupabaseTables.menuItems)
        .select()
        .eq('restaurant_id', restaurantId)
        .order('category');
    return (data as List).map((e) => MenuItemModel.fromMap(e)).toList();
  }

  Future<void> upsertItem(Map<String, dynamic> data) async {
    await _svc.client.from(SupabaseTables.menuItems).upsert(data);
  }

  Future<void> toggleAvailability(String id, bool available) async {
    await _svc.client
        .from(SupabaseTables.menuItems)
        .update({'is_available_today': available})
        .eq('id', id);
  }

  Future<void> deleteItem(String id) async {
    await _svc.client.from(SupabaseTables.menuItems).delete().eq('id', id);
  }
}
