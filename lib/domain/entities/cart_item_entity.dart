class CartItemEntity {
  final String menuId;
  final String name;
  final int price;
  final String? imageUrl;
  final int quantity;
  final String koya;
  final String sambal;

  const CartItemEntity({
    required this.menuId,
    required this.name,
    required this.price,
    this.imageUrl,
    this.quantity = 1,
    this.koya = 'Normal Koya',
    this.sambal = 'Sambal Pisah',
  });

  int get subtotal => price * quantity;

  /// Dua item dianggap baris yang sama jika menu dan kustomisasinya sama.
  String get lineKey => '$menuId|$koya|$sambal';

  /// Catatan untuk dapur, dikirim sebagai notes ke backend.
  String get notes => 'Koya: $koya; Sambal: $sambal';

  CartItemEntity copyWith({int? quantity, String? koya, String? sambal}) {
    return CartItemEntity(
      menuId: menuId,
      name: name,
      price: price,
      imageUrl: imageUrl,
      quantity: quantity ?? this.quantity,
      koya: koya ?? this.koya,
      sambal: sambal ?? this.sambal,
    );
  }
}
