import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/cart_item_entity.dart';

/// Menyimpan keranjang di perangkat supaya tidak hilang saat app ditutup
/// atau saat user diarahkan ke login (Lazy Auth).
class LocalCartService {
  static const _key = 'cart_items';

  Future<List<CartItemEntity>> readItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    final list = jsonDecode(raw) as List;
    return list.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return CartItemEntity(
        menuId: m['menu_id'] as String,
        name: m['name'] as String,
        price: m['price'] as int,
        imageUrl: m['image_url'] as String?,
        quantity: m['quantity'] as int,
        koya: m['koya'] as String,
        sambal: m['sambal'] as String,
      );
    }).toList();
  }

  Future<void> writeItems(List<CartItemEntity> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      items
          .map((i) => {
                'menu_id': i.menuId,
                'name': i.name,
                'price': i.price,
                'image_url': i.imageUrl,
                'quantity': i.quantity,
                'koya': i.koya,
                'sambal': i.sambal,
              })
          .toList(),
    );
    await prefs.setString(_key, encoded);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
