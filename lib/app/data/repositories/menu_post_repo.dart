import '../models/daily_menu_post_model.dart';
import '../services/supabase_service.dart';
import '../../core/constants/supabase_tables.dart';

class MenuPostRepo {
  final _client = SupabaseService.to.client;

  // Vendor: insert a post + its items in sequence
  Future<DailyMenuPost> createPost({
    required String restaurantId,
    required MealType mealType,
    required List<String> menuItemIds,
    String? deliveryWindow,
    String? note,
  }) async {
    final postRow = await _client
        .from(SupabaseTables.dailyMenuPosts)
        .insert({
          'restaurant_id': restaurantId,
          'meal_type': mealType.name,
          'delivery_window': deliveryWindow,
          'note': note,
          'posted_by': _client.auth.currentUser!.id,
        })
        .select()
        .single();

    final postId = postRow['id'] as String;

    if (menuItemIds.isNotEmpty) {
      await _client.from(SupabaseTables.dailyMenuPostItems).insert(
            menuItemIds.map((id) => {'post_id': postId, 'menu_item_id': id}).toList(),
          );
    }

    // Refetch with joined data
    return fetchPostById(postId);
  }

  Future<DailyMenuPost> fetchPostById(String postId) async {
    final row = await _client
        .from(SupabaseTables.dailyMenuPosts)
        .select(
          'id, restaurant_id, meal_type, delivery_window, note, posted_at, posted_by, '
          'restaurants(name), '
          'daily_menu_post_items(menu_item_id, menu_items(id, name, price, description, image_url, category, is_available_today, restaurant_id))',
        )
        .eq('id', postId)
        .single();
    return DailyMenuPost.fromMap(row);
  }

  // Customer + vendor: today's posts for a specific restaurant
  Future<List<DailyMenuPost>> fetchTodaysPostsForRestaurant(String restaurantId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();

    final rows = await _client
        .from(SupabaseTables.dailyMenuPosts)
        .select(
          'id, restaurant_id, meal_type, delivery_window, note, posted_at, posted_by, '
          'restaurants(name), '
          'daily_menu_post_items(menu_item_id, menu_items(id, name, price, description, image_url, category, is_available_today, restaurant_id))',
        )
        .eq('restaurant_id', restaurantId)
        .gte('posted_at', startOfDay)
        .lte('posted_at', endOfDay)
        .order('posted_at', ascending: false);

    return (rows as List).map((r) => DailyMenuPost.fromMap(r)).toList();
  }

  // Customer home: today's posts across ALL restaurants
  Future<List<DailyMenuPost>> fetchAllTodaysPosts() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();

    final rows = await _client
        .from(SupabaseTables.dailyMenuPosts)
        .select(
          'id, restaurant_id, meal_type, delivery_window, note, posted_at, posted_by, '
          'restaurants(name), '
          'daily_menu_post_items(menu_item_id, menu_items(id, name, price, description, image_url, category, is_available_today, restaurant_id))',
        )
        .gte('posted_at', startOfDay)
        .lte('posted_at', endOfDay)
        .order('posted_at', ascending: false);

    return (rows as List).map((r) => DailyMenuPost.fromMap(r)).toList();
  }

  Future<void> deletePost(String postId) async {
    await _client
        .from(SupabaseTables.dailyMenuPosts)
        .delete()
        .eq('id', postId);
  }
}
