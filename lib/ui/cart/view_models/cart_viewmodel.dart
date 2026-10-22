import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../domain/entities/cart_item_entity.dart';
import '../../../domain/entities/menu_entity.dart';
import '../../../domain/entities/table_entity.dart';
import '../../../domain/repositories/i_cart_repository.dart';
import '../../../domain/repositories/i_table_repository.dart';
import '../../../domain/usecases/checkout_dine_in_usecase.dart';

enum CheckoutOutcome { success, needsLogin, failed }

class CartViewModel extends ChangeNotifier {
  final ICartRepository _cartRepository;
  final CheckoutDineInUseCase _checkoutUseCase;
  final ITableRepository _tableRepository;

  CartViewModel(
    this._cartRepository,
    this._checkoutUseCase,
    this._tableRepository,
  ) {
    load();
    loadTables();
  }

  List<CartItemEntity> _items = [];
  List<TableEntity> _tables = [];
  TableEntity? _selectedTable;
  bool _isLoadingTables = false;
  bool _isSubmitting = false;
  String? _error;
  String? _lastOrderCode;

  List<CartItemEntity> get items => List.unmodifiable(_items);
  List<TableEntity> get tables => _tables;
  TableEntity? get selectedTable => _selectedTable;
  bool get isLoadingTables => _isLoadingTables;
  bool get isEmpty => _items.isEmpty;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  String? get lastOrderCode => _lastOrderCode;

  int get totalCount => _items.fold(0, (sum, i) => sum + i.quantity);
  int get totalPrice => _items.fold(0, (sum, i) => sum + i.subtotal);

  Future<void> load() async {
    _items = await _cartRepository.getItems();
    notifyListeners();
  }

  Future<void> loadTables() async {
    _isLoadingTables = true;
    notifyListeners();
    try {
      _tables = await _tableRepository.getTables();
      // Pilihan sebelumnya hilang dari daftar (meja dinonaktifkan) -> reset.
      if (_selectedTable != null &&
          !_tables.any((t) => t.id == _selectedTable!.id)) {
        _selectedTable = null;
      }
    } catch (_) {
      _tables = [];
    }
    _isLoadingTables = false;
    notifyListeners();
  }

  void selectTableById(String? id) {
    if (id == null) return;
    for (final t in _tables) {
      if (t.id == id) {
        _selectedTable = t;
        notifyListeners();
        return;
      }
    }
  }

  /// Dipakai nanti untuk hasil scan QR meja.
  void selectTable(TableEntity table) {
    _selectedTable = table;
    notifyListeners();
  }

  Future<void> addMenu(MenuEntity menu) async {
    await _cartRepository.addItem(
      CartItemEntity(
        menuId: menu.id,
        name: menu.name,
        price: menu.price,
        imageUrl: menu.imageUrl,
      ),
    );
    await load();
  }

  Future<void> increment(CartItemEntity item) async {
    await _cartRepository.updateQuantity(item.lineKey, item.quantity + 1);
    await load();
  }

  Future<void> decrement(CartItemEntity item) async {
    await _cartRepository.updateQuantity(item.lineKey, item.quantity - 1);
    await load();
  }

  Future<void> remove(CartItemEntity item) async {
    await _cartRepository.removeItem(item.lineKey);
    await load();
  }

  Future<void> changeKoya(CartItemEntity item, String koya) {
    if (item.koya == koya) return Future.value();
    return _replace(item, item.copyWith(koya: koya));
  }

  Future<void> changeSambal(CartItemEntity item, String sambal) {
    if (item.sambal == sambal) return Future.value();
    return _replace(item, item.copyWith(sambal: sambal));
  }

  // lineKey ikut berubah saat kustomisasi berubah, jadi hapus lalu tambah.
  // addItem otomatis menggabungkan jika sudah ada baris yang sama.
  Future<void> _replace(CartItemEntity old, CartItemEntity updated) async {
    await _cartRepository.removeItem(old.lineKey);
    await _cartRepository.addItem(updated);
    await load();
  }

  Future<CheckoutOutcome> checkout() async {
    final table = _selectedTable;
    if (table == null) {
      _error = 'Pilih nomor meja terlebih dahulu';
      notifyListeners();
      return CheckoutOutcome.failed;
    }

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      _lastOrderCode = await _checkoutUseCase(tableId: table.id);
      _items = [];
      return CheckoutOutcome.success;
    } on NotAuthenticatedException {
      return CheckoutOutcome.needsLogin;
    } on ApiException catch (e) {
      _error = e.message;
      return CheckoutOutcome.failed;
    } catch (_) {
      _error = 'Gagal mengirim pesanan';
      return CheckoutOutcome.failed;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}