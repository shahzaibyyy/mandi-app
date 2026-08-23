import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../printing/services/print_controller.dart';
import '../../printing/services/receipt_share_formatter.dart';
import '../widgets/urdu_receipt_preview.dart';

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
        appBar: AppBar(title: const Text('رسید')),
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
          UrduReceiptPreview(
            receipt: receipt,
            settings: settings,
            cityDistrict: market?.cityDistrict,
            companyHeaderName: market?.companyHeaderName,
          ),
          const SizedBox(height: 8),
          Text(
            'Print count: ${receipt.printCount}'
            '${receipt.lastPrintedAt == null ? '' : ' · ${DateFormatter.dateTime(receipt.lastPrintedAt!)}'}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
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
}