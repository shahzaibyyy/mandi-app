import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/snackbar_utils.dart';
import '../../../data/models/market.dart';
import '../../../data/providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';

class AddEditMarketScreen extends ConsumerStatefulWidget {
  const AddEditMarketScreen({super.key, this.marketId});

  final String? marketId;

  @override
  ConsumerState<AddEditMarketScreen> createState() => _AddEditMarketScreenState();
}

class _AddEditMarketScreenState extends ConsumerState<AddEditMarketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _header = TextEditingController();
  final _address = TextEditingController();
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.marketId == null
        ? null
        : ref.read(marketRepositoryProvider).getById(widget.marketId!);
    if (existing != null) {
      _name.text = existing.name;
      _city.text = existing.cityDistrict;
      _header.text = existing.companyHeaderName;
      _address.text = existing.address ?? '';
    } else {
      _header.text = ref.read(settingsControllerProvider).companyHeaderName;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _header.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.marketId != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit market' : 'Add market')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(
              label: 'Market name',
              controller: _name,
              requiredField: true,
              hintText: 'e.g. Sheikhupura',
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Division',
              controller: _city,
              requiredField: true,
              hintText: 'e.g. Lahore',
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Company / department header',
              controller: _header,
              requiredField: true,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Address (optional)',
              controller: _address,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: isEdit ? 'Save changes' : 'Create market',
              isLoading: _saving,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final existing = widget.marketId == null
          ? null
          : ref.read(marketRepositoryProvider).getById(widget.marketId!);
      final market = Market(
        id: existing?.id ?? const Uuid().v4(),
        name: _name.text.trim(),
        cityDistrict: _city.text.trim(),
        companyHeaderName: _header.text.trim(),
        address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        createdAt: existing?.createdAt ?? DateTime.now(),
      );
      await ref.read(marketsControllerProvider.notifier).save(market);
      if (!mounted) return;
      SnackbarUtils.success(context, 'Market saved');
      context.pop();
    } catch (error) {
      if (mounted) SnackbarUtils.error(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}