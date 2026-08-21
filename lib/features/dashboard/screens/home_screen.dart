import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/receipt.dart';
import '../../../data/providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/empty_state.dart';
import '../widgets/dashboard_stat_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receipts = ref.watch(receiptsControllerProvider);
    final today = DateTime.now();
    final todays = receipts
        .where((receipt) => DateFormatter.isSameDay(receipt.createdAt, today))
        .toList();
    final collected = todays
        .where((receipt) => receipt.isPaid)
        .fold<double>(0, (sum, receipt) => sum + receipt.totalAmount);
    final recent = receipts.take(5).toList();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Mandi Receipts'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Today',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DashboardStatCard(
                  label: 'Collected',
                  value: CurrencyFormatter.format(collected),
                  icon: Icons.payments_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DashboardStatCard(
                  label: 'Receipts',
                  value: '${todays.length}',
                  icon: Icons.receipt_long_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'New Receipt',
            icon: Icons.add,
            onPressed: () => context.push('/receipts/new'),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Recent receipts',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/receipts'),
                child: const Text('View all'),
              ),
            ],
          ),
          if (recent.isEmpty)
            const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No receipts yet',
              message: 'Issue your first mandi entry-fee receipt.',
            )
          else
            for (final receipt in recent) _RecentTile(receipt: receipt),
        ],
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  const _RecentTile({required this.receipt});

  final Receipt receipt;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(receipt.receiptNumber),
        subtitle: Text(
          '${receipt.receiverName} · ${receipt.marketNameSnapshot}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(receipt.totalAmount),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              receipt.isPaid ? 'PAID' : 'UNPAID',
              style: TextStyle(
                color: receipt.isPaid ? AppColors.paid : AppColors.unpaid,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        onTap: () => context.push('/receipts/${receipt.id}'),
      ),
    );
  }
}