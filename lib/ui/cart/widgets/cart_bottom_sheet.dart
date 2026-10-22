import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/cart_item_entity.dart';
import '../../login/widgets/login_modal_sheet.dart';
import '../view_models/cart_viewmodel.dart';

const _koyaOptions = ['Normal Koya', 'Ekstra Koya', 'Tanpa Koya'];
const _sambalOptions = ['Sambal Pisah', 'Sambal Campur', 'Tanpa Sambal'];

class CartBottomSheet extends StatelessWidget {
  const CartBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartViewModel>();
    final maxHeight = MediaQuery.of(context).size.height * 0.88;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppTheme.warmCreamBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar atas
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Keranjang & Info Meja
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cart.selectedTable == null
                      ? 'Pesanan Anda'
                      : 'Pesanan Meja #${cart.selectedTable!.number}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.darkBrownText,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Makan di Tempat',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Pilih meja (data dari GET /tables)
            DropdownButtonFormField<String>(
              value: cart.selectedTable?.id,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Nomor Meja',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.table_restaurant_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              hint: Text(
                cart.isLoadingTables
                    ? 'Memuat meja...'
                    : (cart.tables.isEmpty
                        ? 'Belum ada meja yang terdaftar'
                        : '-- Pilih Meja --'),
              ),
              items: cart.tables
                  .map((t) => DropdownMenuItem(
                        value: t.id,
                        child: Text('Meja ${t.number}'),
                      ))
                  .toList(),
              onChanged: cart.selectTableById,
            ),
            const SizedBox(height: 12),

            // Daftar item
            if (cart.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text('Keranjang masih kosong')),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _CartItemTile(item: cart.items[i]),
                ),
              ),
            const SizedBox(height: 20),

            // Total & tombol konfirmasi (Lazy Auth)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      formatRupiah(cart.totalPrice),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentYellow,
                    foregroundColor: AppTheme.darkBrownText,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: (cart.isEmpty || cart.isSubmitting)
                      ? null
                      : () => _onCheckout(context),
                  child: cart.isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Lanjut Pembayaran',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onCheckout(BuildContext context) async {
    // Ambil semua yang dibutuhkan sebelum sheet ditutup / await.
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final cart = context.read<CartViewModel>();

    final outcome = await cart.checkout();

    switch (outcome) {
      case CheckoutOutcome.success:
      case CheckoutOutcome.failed:
        if (outcome == CheckoutOutcome.success) navigator.pop();
        _showResult(messenger, cart, outcome);
        break;

      case CheckoutOutcome.needsLogin:
        // Lazy Auth: tutup keranjang, minta login, lalu kirim ulang pesanan.
        navigator.pop();
        showModalBottomSheet(
          context: navigator.context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => LoginModalSheet(
            onLoggedIn: () async {
              final result = await cart.checkout();
              _showResult(messenger, cart, result);
            },
          ),
        );
        break;
    }
  }

  void _showResult(
    ScaffoldMessengerState messenger,
    CartViewModel cart,
    CheckoutOutcome outcome,
  ) {
    final success = outcome == CheckoutOutcome.success;
    final text = success
        ? 'Pesanan terkirim ke dapur! Kode: ${cart.lastOrderCode}'
        : (cart.error ?? 'Gagal mengirim pesanan');

    messenger.showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: success ? AppTheme.primaryGreen : Colors.red.shade700,
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItemEntity item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartViewModel>();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkBrownText,
                  ),
                ),
              ),
              Text(
                formatRupiah(item.subtotal),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          const Text(
            'Kustomisasi Kuah & Koya:',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          _ChipGroup(
            options: _koyaOptions,
            selected: item.koya,
            onSelected: (v) => cart.changeKoya(item, v),
          ),
          const SizedBox(height: 8),
          _ChipGroup(
            options: _sambalOptions,
            selected: item.sambal,
            onSelected: (v) => cart.changeSambal(item, v),
          ),
          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => cart.decrement(item),
                icon: Icon(
                  item.quantity == 1
                      ? Icons.delete_outline
                      : Icons.remove_circle_outline,
                ),
              ),
              Text(
                '${item.quantity}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => cart.increment(item),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipGroup extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const _ChipGroup({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: options.map((option) {
        return ChoiceChip(
          label: Text(option, style: const TextStyle(fontSize: 11)),
          selected: selected == option,
          selectedColor: AppTheme.accentYellow,
          onSelected: (_) => onSelected(option),
        );
      }).toList(),
    );
  }
}