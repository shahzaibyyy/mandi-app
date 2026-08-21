import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Mandi Receipts\nمنڈی رسید',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),
          ),
          _tile(context, Icons.home_outlined, 'Home', '/'),
          _tile(context, Icons.receipt_long, 'New Receipt', '/receipts/new'),
          _tile(context, Icons.history, 'Receipt History', '/receipts'),
          _tile(context, Icons.storefront_outlined, 'Markets', '/markets'),
          _tile(context, Icons.sell_outlined, 'Fee Types', '/fee-types'),
          _tile(context, Icons.print_outlined, 'Printer', '/printer'),
          _tile(context, Icons.settings_outlined, 'Settings', '/settings'),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String label, String route) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      onTap: () {
        Navigator.of(context).pop();
        context.go(route);
      },
    );
  }
}