import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/snackbar_utils.dart';
import '../../../data/models/fee_type.dart';
import '../../../data/models/market.dart';
import '../../../data/providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';

class FeeTypeFormSheet extends ConsumerStatefulWidget {
  const FeeTypeFormSheet({super.key, required this.markets, this.existing});

  final List<Market> markets;
  final FeeType? existing;

  @override
  ConsumerState<FeeTypeFormSheet> createState() => _FeeTypeFormSheetState();
}

class _FeeTypeFormSheetState extends ConsumerState<FeeTypeFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _unit = TextEditingController();
  final _rate = TextEditingController();
  String? _marketId;
  var _active = true;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _name.text = existing.name;
      _unit.text = existing.unitLabel;
      _rate.text = existing.defaultRate.toString();
      _marketId = existing.marketId;
      _active = existing.isActive;
    } else {
      _unit.text = 'crate';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _unit.dispose();
    _rate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.existing == null ? 'Add fee type' : 'Edit fee type',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Name',
                controller: _name,
                requiredField: true,
                hintText: 'e.g. Entry Fee',
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Unit label',
                controller: _unit,
                requiredField: true,
                hintText: 'crate, kg, vehicle',
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Default rate',
                controller: _rate,
                requiredField: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                // ignore: deprecated_member_use
                value: _marketId,
                decoration: const InputDecoration(labelText: 'Applies to'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All markets'),
                  ),
                  for (final market in widget.markets)
                    DropdownMenuItem(
                      value: market.id,
                      child: Text(market.name),
                    ),
                ],
                onChanged: (id) => setState(() => _marketId = id),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                value: _active,
                onChanged: (value) => setState(() => _active = value),
              ),
              AppButton(
                label: 'Save',
                isLoading: _saving,
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final rate = double.tryParse(_rate.text.trim());
    if (rate == null) {
      SnackbarUtils.error(context, 'Enter a valid rate');
      return;
    }
    setState(() => _saving = true);
    try {
      final fee = FeeType(
        id: widget.existing?.id ?? const Uuid().v4(),
        marketId: _marketId,
        name: _name.text.trim(),
        unitLabel: _unit.text.trim(),
        defaultRate: rate,
        isActive: _active,
      );
      await ref.read(feeTypesControllerProvider.notifier).save(fee);
      if (!mounted) return;
      Navigator.of(context).pop();
      SnackbarUtils.success(context, 'Fee type saved');
    } catch (error) {
      if (mounted) SnackbarUtils.error(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}