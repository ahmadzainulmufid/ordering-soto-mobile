import 'package:go_router/go_router.dart';

import '../../ui/home/widgets/home_screen.dart';
import '../../ui/register/widgets/register_screen.dart';

class AppRoute {
  static const String home = '/';
  static const String register = '/register';

  /// Dipakai saat scan QR meja: /table/<token>
  static const String tableByToken = '/table/:token';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: tableByToken,
        builder: (context, state) => const HomeScreen(),
        // TODO: ambil state.pathParameters['token'] lalu resolve meja
        // lewat GET /tables/qr/:token di HomeViewModel.
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
    ],
  );
}
