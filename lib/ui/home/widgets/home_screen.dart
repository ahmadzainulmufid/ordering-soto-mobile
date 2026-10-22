import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../cart/view_models/cart_viewmodel.dart';
import '../../cart/widgets/cart_bottom_sheet.dart';
import '../view_models/home_viewmodel.dart';
import 'menu_card_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeViewModel>();
    final cart = context.watch<CartViewModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.warmCreamBg,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Soto Ayam Lamongan',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppTheme.darkBrownText,
          ),
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                cart.selectedTable == null
                    ? 'Pilih meja'
                    : 'Meja #${cart.selectedTable!.number}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: home.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari menu...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody(context, home, cart)),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: cart.totalCount == 0
          ? null
          : FloatingActionButton.extended(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              onPressed: () => _openCart(context),
              icon: const Icon(Icons.shopping_basket_outlined),
              label: Text(
                '${cart.totalCount} item  •  ${formatRupiah(cart.totalPrice)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
    );
  }

  Widget _buildBody(BuildContext context, HomeViewModel home, CartViewModel cart) {
    if (home.isLoading && home.menus.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (home.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(home.error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: home.loadMenus,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (home.menus.isEmpty) {
      return const Center(child: Text('Menu tidak ditemukan'));
    }

    return RefreshIndicator(
      onRefresh: home.loadMenus,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: home.menus.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final menu = home.menus[index];
          return MenuCardWidget(
            menu: menu,
            onAdd: () => context.read<CartViewModel>().addMenu(menu),
          );
        },
      ),
    );
  }

  void _openCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CartBottomSheet(),
    );
  }
}