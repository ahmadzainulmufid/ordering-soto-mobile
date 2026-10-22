class MenuEntity {
  final String id;
  final String name;
  final String description;
  final int price;
  final String? imageUrl;
  final String? categoryId;
  final bool isAvailable;

  const MenuEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.categoryId,
    this.isAvailable = true,
  });
}
