import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../domain/entities/menu_entity.dart';
import '../../../domain/repositories/i_menu_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final IMenuRepository _menuRepository;

  HomeViewModel(this._menuRepository) {
    loadMenus();
  }

  List<MenuEntity> _menus = [];
  bool _isLoading = false;
  String? _error;
  Timer? _debounce;

  List<MenuEntity> get menus => _menus;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMenus() => _run(() => _menuRepository.getMenus());

  /// Dipanggil setiap teks pencarian berubah (di-debounce 400 ms).
  void onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final q = query.trim();
      if (q.isEmpty) {
        loadMenus();
      } else {
        _run(() => _menuRepository.searchMenus(q));
      }
    });
  }

  Future<void> _run(Future<List<MenuEntity>> Function() fetch) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _menus = await fetch();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Gagal memuat menu';
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}