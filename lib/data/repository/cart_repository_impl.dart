import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/i_cart_repository.dart';
import '../model/order_request_dto.dart';
import '../services/local_cart_service.dart';
import '../services/order_api_service.dart';

class CartRepositoryImpl implements ICartRepository {
  final LocalCartService _local;
  final OrderApiService _orderApi;

  CartRepositoryImpl(this._local, this._orderApi);

  @override
  Future<List<CartItemEntity>> getItems() => _local.readItems();

  @override
  Future<void> addItem(CartItemEntity item) async {
    final items = await _local.readItems();
    final index = items.indexWhere((i) => i.lineKey == item.lineKey);
    if (index >= 0) {
      items[index] = items[index].copyWith(
        quantity: items[index].quantity + item.quantity,
      );
    } else {
      items.add(item);
    }
    await _local.writeItems(items);
  }

  @override
  Future<void> updateQuantity(String lineKey, int quantity) async {
    final items = await _local.readItems();
    final index = items.indexWhere((i) => i.lineKey == lineKey);
    if (index < 0) return;

    if (quantity <= 0) {
      items.removeAt(index);
    } else {
      items[index] = items[index].copyWith(quantity: quantity);
    }
    await _local.writeItems(items);
  }

  @override
  Future<void> removeItem(String lineKey) async {
    final items = await _local.readItems();
    items.removeWhere((i) => i.lineKey == lineKey);
    await _local.writeItems(items);
  }

  @override
  Future<void> clear() => _local.clear();

  @override
  Future<String> submitOrder({
    required String tableId,
    required String customerName,
    required String customerPhone,
    required List<CartItemEntity> items,
  }) {
    return _orderApi.createOrder(
      OrderRequestDto(
        customerName: customerName,
        customerPhone: customerPhone,
        tableId: tableId,
        items: items,
      ),
    );
  }
}