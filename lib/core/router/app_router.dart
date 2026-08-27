import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/dashboard/screens/home_screen.dart';
import '../../features/fee_types/screens/manage_fee_types_screen.dart';
import '../../features/license/controllers/license_controller.dart';
import '../../features/license/screens/activation_screen.dart';
import '../../features/markets/screens/add_edit_market_screen.dart';
import '../../features/markets/screens/market_list_screen.dart';
import '../../features/printing/screens/printer_settings_screen.dart';
import '../../features/receipt_creation/screens/create_receipt_screen.dart';
import '../../features/receipt_history/screens/receipt_detail_screen.dart';
import '../../features/receipt_history/screens/receipt_list_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

final routerRefreshProvider = Provider<ValueNotifier<int>>((ref) {
  final notifier = ValueNotifier(0);
  ref.listen(authControllerProvider, (_, _) => notifier.value++);
  ref.listen(licenseControllerProvider, (_, _) => notifier.value++);
  ref.onDispose(notifier.dispose);
  return notifier;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(routerRefreshProvider);
  return GoRouter(
    initialLocation: '/activate',
    refreshListenable: refresh,
    redirect: (context, state) {
      final license = ref.read(licenseControllerProvider);
      if (!license.isReady) return null;

      final location = state.matchedLocation;
      final onActivate = location == '/activate';
      if (!license.isLicensed) {
        return onActivate ? null : '/activate';
      }

      final loggedIn = ref.read(authControllerProvider);
      final onLogin = location == '/login';
      if (!loggedIn && !onLogin) return '/login';
      if (loggedIn && (onLogin || onActivate)) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/activate',
        name: 'activate',
        builder: (context, state) => const ActivationScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/receipts',
        name: 'receipts',
        builder: (context, state) => const ReceiptListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'createReceipt',
            builder: (context, state) => const CreateReceiptScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'receiptDetail',
            builder: (context, state) => ReceiptDetailScreen(
              receiptId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/printer',
        name: 'printer',
        builder: (context, state) => const PrinterSettingsScreen(),
      ),
      GoRoute(
        path: '/markets',
        name: 'markets',
        builder: (context, state) => const MarketListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'addMarket',
            builder: (context, state) => const AddEditMarketScreen(),
          ),
          GoRoute(
            path: ':id/edit',
            name: 'editMarket',
            builder: (context, state) => AddEditMarketScreen(
              marketId: state.pathParameters['id'],
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/fee-types',
        name: 'feeTypes',
        builder: (context, state) => const ManageFeeTypesScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: Center(child: Text(state.error.toString())),
    ),
  );
});
