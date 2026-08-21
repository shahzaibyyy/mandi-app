import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/receipt.dart';
import '../../../data/providers.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/empty_state.dart';
import '../controllers/receipt_filter_controller.dart';
import '../widgets/receipt_filter_bar.dart';
import '../widgets/receipt_list_tile.dart';

class ReceiptListScreen extends ConsumerWidget {
  const ReceiptListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receipts = ref.watch(receiptsControllerProvider);
    final filter = ref.watch(receiptFilterControllerProvider);
    final markets = ref.watch(marketsControllerProvider);
    final filtered = _apply(receipts, filter);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Receipt History')),
      body: Column(
        children: [
          ReceiptFilterBar(markets: markets),
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: Icons.history,
                    title: receipts.isEmpty
                        ? 'No receipts stored'
                        : 'No matches',
                    message: receipts.isEmpty
                        ? 'New receipts will appear here, newest first.'
                        : 'Try a different search or filter.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return ReceiptListTile(receipt: filtered[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<Receipt> _apply(List<Receipt> receipts, ReceiptFilter filter) {
    final query = filter.query.trim().toLowerCase();
    return receipts.where((receipt) {
      if (query.isNotEmpty) {
        final haystack =
            '${receipt.receiptNumber} ${receipt.receiverName}'.toLowerCase();
        if (!haystack.contains(query)) return false;
      }
      if (filter.marketId != null && receipt.marketId != filter.marketId) {
        return false;
      }
      if (filter.isPaid != null && receipt.isPaid != filter.isPaid) {
        return false;
      }
      if (filter.from != null) {
        final start = DateTime(
          filter.from!.year,
          filter.from!.month,
          filter.from!.day,
        );
        if (receipt.createdAt.isBefore(start)) return false;
      }
      if (filter.to != null) {
        final end = DateTime(
          filter.to!.year,
          filter.to!.month,
          filter.to!.day,
          23,
          59,
          59,
        );
        if (receipt.createdAt.isAfter(end)) return false;
      }
      return true;
    }).toList();
  }
}