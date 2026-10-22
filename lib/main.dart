import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/dio_client.dart';
import 'core/network/token_storage.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repository/auth_repository_impl.dart';
import 'data/repository/cart_repository_impl.dart';
import 'data/repository/menu_repository_impl.dart';
import 'data/repository/table_repository_impl.dart';
import 'data/services/auth_api_service.dart';
import 'data/services/local_cart_service.dart';
import 'data/services/menu_api_service.dart';
import 'data/services/order_api_service.dart';
import 'data/services/table_api_service.dart';
import 'domain/usecases/checkout_dine_in_usecase.dart';
import 'ui/cart/view_models/cart_viewmodel.dart';
import 'ui/home/view_models/home_viewmodel.dart';
import 'ui/login/view_models/login_viewmodel.dart';
import 'ui/register/view_models/register_viewmodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Dependency injection manual: core -> services -> repository -> usecase.
  final tokenStorage = TokenStorage();
  final dioClient = DioClient(tokenStorage: tokenStorage);

  final authRepository =
      AuthRepositoryImpl(AuthApiService(dioClient), tokenStorage);
  final menuRepository = MenuRepositoryImpl(MenuApiService(dioClient));
  final tableRepository = TableRepositoryImpl(TableApiService(dioClient));
  final cartRepository = CartRepositoryImpl(
    LocalCartService(),
    OrderApiService(dioClient),
  );
  final checkoutUseCase = CheckoutDineInUseCase(authRepository, cartRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel(menuRepository)),
        ChangeNotifierProvider(
          create: (_) =>
              CartViewModel(cartRepository, checkoutUseCase, tableRepository),
        ),
        ChangeNotifierProvider(create: (_) => LoginViewModel(authRepository)),
        ChangeNotifierProvider(
          create: (_) => RegisterViewModel(authRepository),
        ),
      ],
      child: const SotoApp(),
    ),
  );
}

class SotoApp extends StatelessWidget {
  const SotoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Soto Ayam Lamongan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRoute.router,
    );
  }
}