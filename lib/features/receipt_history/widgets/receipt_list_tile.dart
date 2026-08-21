import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/receipt.dart';

class ReceiptListTile extends StatelessWidget {
  const ReceiptListTile({super.key, required this.receipt});

  final Receipt receipt;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(receipt.receiptNumber),
        subtitle: Text(
          '${receipt.receiverName} · ${receipt.marketNameSnapshot}\n${DateFormatter.dateTime(receipt.createdAt)}',
        ),
        isThreeLine: true,
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