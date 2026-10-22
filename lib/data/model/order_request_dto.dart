import '../../domain/entities/cart_item_entity.dart';

/// Payload sama dengan yang dikirim frontend web (OrderUserController).
class OrderRequestDto {
  final String customerName;
  final String customerPhone;
  final String tableId;
  final String orderType;
  final String paymentMethod;
  final String notes;
  final List<CartItemEntity> items;

  const OrderRequestDto({
    required this.customerName,
    required this.customerPhone,
    required this.tableId,
    required this.items,
    this.orderType = 'dine_in',
    this.paymentMethod = 'cash',
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'customer_phone': customerPhone.isEmpty ? '-' : customerPhone,
      'order_type': orderType,
      'table_id': int.tryParse(tableId),
      'delivery_address': '',
      'payment_method': paymentMethod,
      'notes': notes,
      'items': items
          .map((i) => {
                // Backend memakai ID numerik (web mengirim angka).
                'product_id': int.tryParse(i.menuId) ?? i.menuId,
                'quantity': i.quantity,
                'notes': i.notes,
              })
          .toList(),
    };
  }
}