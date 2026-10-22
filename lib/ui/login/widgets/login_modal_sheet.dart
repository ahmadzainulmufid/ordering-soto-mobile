import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../view_models/login_viewmodel.dart';

class LoginModalSheet extends StatefulWidget {
  /// Dipanggil setelah login berhasil dan sheet sudah ditutup
  /// (mis. untuk mengirim ulang pesanan).
  final Future<void> Function()? onLoggedIn;

  const LoginModalSheet({super.key, this.onLoggedIn});

  @override
  State<LoginModalSheet> createState() => _LoginModalSheetState();
}

class _LoginModalSheetState extends State<LoginModalSheet> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final vm = context.read<LoginViewModel>();
    final navigator = Navigator.of(context);
    final onLoggedIn = widget.onLoggedIn;

    final ok = await vm.login(
      identifier: _identifierController.text.trim(),
      password: _passwordController.text,
    );

    if (!ok) return;
    navigator.pop();
    await onLoggedIn?.call();
  }

  void _goToRegister() {
    Navigator.pop(context);
    AppRoute.router.push(AppRoute.register);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Masuk untuk Melanjutkan Pesanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.darkBrownText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pesanan kamu sudah tersimpan. Silakan masuk agar status soto bisa dilacak langsung dari HP.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _identifierController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email atau nomor WhatsApp',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            if (vm.error != null) ...[
              const SizedBox(height: 12),
              Text(
                vm.error!,
                style: TextStyle(fontSize: 12, color: Colors.red.shade700),
              ),
            ],
            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: vm.isLoading ? null : _submit,
              child: vm.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Masuk & Pesan Sekarang',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
            ),
            const SizedBox(height: 12),

            TextButton(
              onPressed: _goToRegister,
              child: const Text(
                'Belum punya akun? Daftar Cepat',
                style: TextStyle(
                  color: AppTheme.darkBrownText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}