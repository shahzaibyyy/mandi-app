import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class ReceiptTotalsBar extends StatelessWidget {
  const ReceiptTotalsBar({
    super.key,
    required this.subtotal,
    required this.taxPercent,
    required this.taxAmount,
    required this.total,
  });

  final double subtotal;
  final double taxPercent;
  final double taxAmount;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primaryDark,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Column(
            children: [
              _row('Subtotal', CurrencyFormatter.format(subtotal)),
              const SizedBox(height: 6),
              _row(
                'PST ${CurrencyFormatter.plain(taxPercent)}%',
                CurrencyFormatter.format(taxAmount),
              ),
              const Divider(color: Colors.white54),
              _row('Total / کل رقم', CurrencyFormatter.format(total), bold: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      fontSize: bold ? 18 : 15,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}