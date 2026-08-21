import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../data/models/market.dart';
import '../controllers/receipt_filter_controller.dart';

class ReceiptFilterBar extends ConsumerWidget {
  const ReceiptFilterBar({super.key, required this.markets});

  final List<Market> markets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(receiptFilterControllerProvider);
    final controller = ref.read(receiptFilterControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search receipt no. or receiver',
            ),
            onChanged: controller.setQuery,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  // ignore: deprecated_member_use
                  value: filter.marketId,
                  decoration: const InputDecoration(labelText: 'Market'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All markets')),
                    for (final market in markets)
                      DropdownMenuItem(
                        value: market.id,
                        child: Text(market.name),
                      ),
                  ],
                  onChanged: controller.setMarket,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: filter.isPaid == null
                      ? 'all'
                      : (filter.isPaid! ? 'paid' : 'unpaid'),
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'paid', child: Text('Paid')),
                    DropdownMenuItem(value: 'unpaid', child: Text('Unpaid')),
                  ],
                  onChanged: (value) {
                    if (value == 'paid') {
                      controller.setPaid(true);
                    } else if (value == 'unpaid') {
                      controller.setPaid(false);
                    } else {
                      controller.setPaid(null);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: filter.from ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (picked != null) controller.setFrom(picked);
                  },
                  child: Text(
                    filter.from == null
                        ? 'From date'
                        : DateFormatter.date(filter.from!),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: filter.to ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (picked != null) controller.setTo(picked);
                  },
                  child: Text(
                    filter.to == null
                        ? 'To date'
                        : DateFormatter.date(filter.to!),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Clear filters',
                onPressed: controller.clear,
                icon: const Icon(Icons.filter_alt_off_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }
}