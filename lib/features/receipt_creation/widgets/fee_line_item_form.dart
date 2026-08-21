import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/fee_type.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/receipt_form_controller.dart';

class FeeLineItemForm extends ConsumerStatefulWidget {
  const FeeLineItemForm({
    super.key,
    required this.item,
    required this.feeTypes,
  });

  final DraftLineItem item;
  final List<FeeType> feeTypes;

  @override
  ConsumerState<FeeLineItemForm> createState() => _FeeLineItemFormState();
}

class _FeeLineItemFormState extends ConsumerState<FeeLineItemForm> {
  late final TextEditingController _qty;
  late final TextEditingController _rate;

  @override
  void initState() {
    super.initState();
    _qty = TextEditingController(
      text: widget.item.quantity == 0 ? '' : widget.item.quantity.toString(),
    );
    _rate = TextEditingController(
      text: widget.item.unitRate == 0 ? '' : widget.item.unitRate.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant FeeLineItemForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.unitRate != widget.item.unitRate &&
        oldWidget.item.feeTypeId != widget.item.feeTypeId) {
      _rate.text = widget.item.unitRate.toString();
    }
  }

  @override
  void dispose() {
    _qty.dispose();
    _rate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(receiptFormControllerProvider.notifier);
    final selected = widget.feeTypes.where((fee) => fee.id == widget.item.feeTypeId);
    final value = selected.isEmpty ? null : selected.first;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<FeeType>(
                    // ignore: deprecated_member_use
                    value: value,
                    decoration: const InputDecoration(labelText: 'Fee type'),
                    items: [
                      for (final fee in widget.feeTypes)
                        DropdownMenuItem(
                          value: fee,
                          child: Text('${fee.name} (${fee.unitLabel})'),
                        ),
                    ],
                    onChanged: (fee) {
                      if (fee != null) {
                        controller.applyFeeType(widget.item.id, fee);
                      }
                    },
                  ),
                ),
                IconButton(
                  tooltip: 'Remove',
                  onPressed: () => controller.removeLineItem(widget.item.id),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label:
                        'Qty (${widget.item.unitLabel.isEmpty ? 'unit' : widget.item.unitLabel})',
                    controller: _qty,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    onChanged: (raw) {
                      controller.updateLineItem(
                        widget.item.copyWith(quantity: double.tryParse(raw) ?? 0),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppTextField(
                    label: 'Unit rate',
                    controller: _rate,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    onChanged: (raw) {
                      controller.updateLineItem(
                        widget.item.copyWith(unitRate: double.tryParse(raw) ?? 0),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Amount: ${CurrencyFormatter.format(widget.item.amount)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}