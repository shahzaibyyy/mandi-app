import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/license/controllers/license_controller.dart';

class MandiApp extends ConsumerStatefulWidget {
  const MandiApp({super.key});

  @override
  ConsumerState<MandiApp> createState() => _MandiAppState();
}

class _MandiAppState extends ConsumerState<MandiApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(licenseControllerProvider.notifier).onAppStart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final licenseReady = ref.watch(licenseReadyProvider);
    if (!licenseReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp.router(
      title: 'Mandi Receipts',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
