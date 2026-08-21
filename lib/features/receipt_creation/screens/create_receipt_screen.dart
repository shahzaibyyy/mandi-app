import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../printing/services/print_controller.dart';
import '../controllers/receipt_form_controller.dart';
import '../widgets/after_save_sheet.dart';
import '../widgets/fee_line_item_form.dart';
import '../widgets/receipt_totals_bar.dart';

class CreateReceiptScreen extends ConsumerStatefulWidget {
  const CreateReceiptScreen({super.key});

  @override
  ConsumerState<CreateReceiptScreen> createState() =>
      _CreateReceiptScreenState();
}

class _CreateReceiptScreenState extends ConsumerState<CreateReceiptScreen> {
  late final TextEditingController _receiver;
  late final TextEditingController _contractor;

  @override
  void initState() {
    super.initState();
    final form = ref.read(receiptFormControllerProvider);
    _receiver = TextEditingController(text: form.receiverName);
    _contractor = TextEditingController(text: form.contractorName);
  }

  @override
  void dispose() {
    _receiver.dispose();
    _contractor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(receiptFormControllerProvider);
    final markets = ref.watch(marketsControllerProvider);
    final feeTypes = ref
        .watch(feeTypesControllerProvider.notifier)
        .forMarket(form.marketId);
    final marketIds = {for (final market in markets) market.id};
    final selectedMarketId = marketIds.contains(form.marketId)
        ? form.marketId
        : null;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('New Receipt')),
      body: markets.isEmpty
          ? EmptyState(
              icon: Icons.storefront_outlined,
              title: 'No markets yet',
              message: 'Add a mandi first, then you can issue receipts.',
              actionLabel: 'Add market',
              onAction: () => context.go('/markets/new'),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: selectedMarketId,
                  decoration: const InputDecoration(
                    labelText: 'Market / منڈی',
                  ),
                  items: [
                    for (final market in markets)
                      DropdownMenuItem(
                        value: market.id,
                        child: Text('${market.name} (${market.cityDistrict})'),
                      ),
                  ],
                  onChanged: (id) => ref
                      .read(receiptFormControllerProvider.notifier)
                      .setMarket(id),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Receiver name / وصول کنندہ',
                  controller: _receiver,
                  requiredField: true,
                  textInputAction: TextInputAction.next,
                  onChanged: ref
                      .read(receiptFormControllerProvider.notifier)
                      .setReceiverName,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Contractor name / ٹھیکیدار (optional)',
                  controller: _contractor,
                  textInputAction: TextInputAction.next,
                  onChanged: ref
                      .read(receiptFormControllerProvider.notifier)
                      .setContractorName,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Fee line items',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: feeTypes.isEmpty
                          ? () => context.push('/fee-types')
                          : () => ref
                                .read(receiptFormControllerProvider.notifier)
                                .addLineItem(
                                  feeType: feeTypes.length == 1
                                      ? feeTypes.first
                                      : null,
                                ),
                      icon: const Icon(Icons.add),
                      label: Text(
                        feeTypes.isEmpty ? 'Add fee types' : 'Add item',
                      ),
                    ),
                  ],
                ),
                if (form.lineItems.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Add one or more fees to this receipt.'),
                  ),
                for (final item in form.lineItems)
                  FeeLineItemForm(key: ValueKey(item.id), item: item, feeTypes: feeTypes),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Payment status'),
                  subtitle: Text(
                    form.isPaid ? 'PAID / ادا شدہ' : 'UNPAID / غیر ادا',
                  ),
                  activeThumbColor: AppColors.paid,
                  value: form.isPaid,
                  onChanged: ref
                      .read(receiptFormControllerProvider.notifier)
                      .setPaid,
                ),
                ReceiptTotalsBar(
                  subtotal: form.subtotal,
                  taxPercent: form.taxPercent,
                  taxAmount: form.taxAmount,
                  total: form.total,
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Save receipt',
                  icon: Icons.save_outlined,
                  isLoading: form.isSaving,
                  onPressed: form.isSaving ? null : _save,
                ),
              ],
            ),
    );
  }

  Future<void> _save() async {
    final controller = ref.read(receiptFormControllerProvider.notifier);
    try {
      final receipt = await controller.save();
      if (!mounted) return;
      final action = await showModalBottomSheet<String>(
        context: context,
        builder: (_) => AfterSaveSheet(receipt: receipt),
      );
      if (!mounted) return;
      if (action == 'print') {
        final result = await printAndRecord(ref, receipt: receipt);
        if (!mounted) return;
        if (result.success) {
          SnackbarUtils.success(context, 'Printed ${receipt.receiptNumber}');
        } else {
          SnackbarUtils.error(context, result.message ?? 'Print failed');
        }
      } else {
        SnackbarUtils.success(context, 'Saved ${receipt.receiptNumber}');
      }
      controller.hydrateFromSettings();
      final form = ref.read(receiptFormControllerProvider);
      _receiver.text = form.receiverName;
      _contractor.text = form.contractorName;
    } catch (error) {
      if (mounted) SnackbarUtils.error(context, error);
    }
  }
}