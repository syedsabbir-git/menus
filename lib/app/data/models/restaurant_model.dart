class RestaurantModel {
  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final String? imageUrl;
  final bool isOpen;
  final DateTime createdAt;

  RestaurantModel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.isOpen,
    required this.createdAt,
  });

  factory RestaurantModel.fromMap(Map<String, dynamic> map) {
    return RestaurantModel(
      id: map['id'] as String,
      ownerId: map['owner_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      imageUrl: map['image_url'] as String?,
      isOpen: map['is_open'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'is_open': isOpen,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
