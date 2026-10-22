import '../../domain/entities/menu_entity.dart';

class MenuDto {
  final String id;
  final String name;
  final String description;
  final int price;
  final String? imageUrl;
  final String? categoryId;
  final bool isAvailable;

  const MenuDto({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.categoryId,
    this.isAvailable = true,
  });

  factory MenuDto.fromJson(Map<String, dynamic> json) {
    return MenuDto(
      id: json['id'].toString(),
      name: (json['name'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      price: (json['price'] as num?)?.toInt() ?? 0,
      imageUrl: json['image_url'] as String?,
      categoryId: json['category_id']?.toString(),
      // Web mengecek `== true || == 1`, jadi bisa bool atau 0/1.
      isAvailable: json['is_available'] == null
          ? true
          : (json['is_available'] == true || json['is_available'] == 1),
    );
  }

  MenuEntity toEntity() {
    return MenuEntity(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      categoryId: categoryId,
      isAvailable: isAvailable,
    );
  }
}