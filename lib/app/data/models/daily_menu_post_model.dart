import 'menu_item_model.dart';

enum MealType { breakfast, lunch, dinner }

extension MealTypeX on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
    }
  }

  String get emoji {
    switch (this) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
    }
  }

  static MealType fromString(String value) {
    return MealType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MealType.dinner,
    );
  }
}

class DailyMenuPost {
  final String id;
  final String restaurantId;
  final String? restaurantName;
  final MealType mealType;
  final String? deliveryWindow;
  final String? note;
  final DateTime postedAt;
  final String postedBy;
  final List<MenuItemModel> items;

  DailyMenuPost({
    required this.id,
    required this.restaurantId,
    this.restaurantName,
    required this.mealType,
    this.deliveryWindow,
    this.note,
    required this.postedAt,
    required this.postedBy,
    this.items = const [],
  });

  factory DailyMenuPost.fromMap(Map<String, dynamic> map) {
    final restaurantData = map['restaurants'] as Map<String, dynamic>?;
    final rawItems = map['daily_menu_post_items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map((e) {
          final mi = (e as Map<String, dynamic>)['menu_items'];
          if (mi == null) return null;
          return MenuItemModel.fromMap(mi as Map<String, dynamic>);
        })
        .whereType<MenuItemModel>()
        .toList();

    return DailyMenuPost(
      id: map['id'] as String,
      restaurantId: map['restaurant_id'] as String,
      restaurantName: restaurantData?['name'] as String?,
      mealType: MealTypeX.fromString(map['meal_type'] as String),
      deliveryWindow: map['delivery_window'] as String?,
      note: map['note'] as String?,
      postedAt: DateTime.parse(map['posted_at'] as String),
      postedBy: map['posted_by'] as String,
      items: items,
    );
  }
}
