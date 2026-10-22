import '../entities/cart_item_entity.dart';

abstract class ICartRepository {
  Future<List<CartItemEntity>> getItems();
  Future<void> addItem(CartItemEntity item);
  Future<void> updateQuantity(String lineKey, int quantity);
  Future<void> removeItem(String lineKey);
  Future<void> clear();

  Future<String> submitOrder({
    required String tableId,
    required String customerName,
    required String customerPhone,
    required List<CartItemEntity> items,
  });
}