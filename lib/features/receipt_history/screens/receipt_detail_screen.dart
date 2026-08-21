import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../printing/services/print_controller.dart';
import '../../printing/services/receipt_share_formatter.dart';

class ReceiptDetailScreen extends ConsumerWidget {
  const ReceiptDetailScreen({super.key, required this.receiptId});

  final String receiptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receipt = ref.watch(receiptByIdProvider(receiptId));
    final settings = ref.watch(settingsControllerProvider);
    final market = receipt == null
        ? null
        : ref.watch(marketRepositoryProvider).getById(receipt.marketId);

    if (receipt == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Receipt')),
        body: const EmptyState(
          icon: Icons.receipt_long,
          title: 'Receipt not found',
          message: 'It may have been removed from this device.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(receipt.receiptNumber),
        actions: [
          IconButton(
            tooltip: 'Share',
            onPressed: () {
              final text = ReceiptShareFormatter.toText(
                receipt: receipt,
                settings: settings,
                cityDistrict: market?.cityDistrict,
              );
              SharePlus.instance.share(ShareParams(text: text));
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    settings.companyHeaderName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(receipt.marketNameSnapshot),
                  if (market != null) Text(market.cityDistrict),
                  const Divider(),
                  _kv('Receiver', receipt.receiverName),
                  if (receipt.contractorName != null)
                    _kv('Contractor', receipt.contractorName!),
                  _kv('Receipt No', receipt.receiptNumber),
                  _kv('Date', DateFormatter.dateTime(receipt.createdAt)),
                  _kv(
                    'Status',
                    receipt.isPaid ? 'PAID / ادا شدہ' : 'UNPAID / غیر ادا',
                    valueColor: receipt.isPaid ? AppColors.paid : AppColors.unpaid,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (final item in receipt.lineItems) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.feeTypeName} (${item.unitLabel})',
                          ),
                        ),
                        Text(CurrencyFormatter.format(item.amount)),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${CurrencyFormatter.plain(item.quantity)} × ${CurrencyFormatter.format(item.unitRate)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  const Divider(),
                  _kv('Subtotal', CurrencyFormatter.format(receipt.subtotal)),
                  _kv(
                    'PST ${CurrencyFormatter.plain(receipt.taxPercent)}%',
                    CurrencyFormatter.format(receipt.taxAmount),
                  ),
                  _kv(
                    'Total',
                    CurrencyFormatter.format(receipt.totalAmount),
                    bold: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (settings.whatsappNumber != null)
            _kv('Phone/WhatsApp', settings.whatsappNumber!),
          if (receipt.latitude != null && receipt.longitude != null)
            _kv(
              'GPS',
              '${receipt.latitude!.toStringAsFixed(6)}, ${receipt.longitude!.toStringAsFixed(6)}',
            ),
          _kv('Print count', '${receipt.printCount}'),
          if (receipt.lastPrintedAt != null)
            _kv(
              'Last printed',
              DateFormatter.dateTime(receipt.lastPrintedAt!),
            ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Reprint',
            icon: Icons.print,
            onPressed: () async {
              final result = await printAndRecord(ref, receipt: receipt);
              if (!context.mounted) return;
              if (result.success) {
                SnackbarUtils.success(context, 'Printed ${receipt.receiptNumber}');
              } else {
                SnackbarUtils.error(context, result.message ?? 'Print failed');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _kv(String label, String value, {Color? valueColor, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}