import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/snackbar_utils.dart';
import '../../../data/providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_text_field.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _company;
  late final TextEditingController _tax;
  late final TextEditingController _prefix;
  late final TextEditingController _receiver;
  late final TextEditingController _whatsapp;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsControllerProvider);
    _company = TextEditingController(text: settings.companyHeaderName);
    _tax = TextEditingController(text: settings.defaultTaxPercent.toString());
    _prefix = TextEditingController(text: settings.receiptNumberPrefix);
    _receiver = TextEditingController(text: settings.defaultReceiverName ?? '');
    _whatsapp = TextEditingController(text: settings.whatsappNumber ?? '');
  }

  @override
  void dispose() {
    _company.dispose();
    _tax.dispose();
    _prefix.dispose();
    _receiver.dispose();
    _whatsapp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final markets = ref.watch(marketsControllerProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppTextField(
            label: 'Company / department header',
            controller: _company,
            requiredField: true,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Default tax % (PST)',
            controller: _tax,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Receipt number prefix',
            controller: _prefix,
            hintText: 'MND-',
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Default receiver name',
            controller: _receiver,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Phone / WhatsApp number',
            controller: _whatsapp,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: switch (settings.receiptTemplateVersion) {
              'v2' => 'v2',
              'v3' => 'v3',
              'v4' => 'v4',
              'v5' => 'v5',
              _ => 'v1',
            },
            decoration: const InputDecoration(labelText: 'Receipt style'),
            items: const [
              DropdownMenuItem(value: 'v1', child: Text('Classic (v1)')),
              DropdownMenuItem(value: 'v2', child: Text('Compact (v2)')),
              DropdownMenuItem(value: 'v3', child: Text('Original (v3)')),
              DropdownMenuItem(value: 'v4', child: Text('Original clear (v4)')),
              DropdownMenuItem(value: 'v5', child: Text('Original clear (v5)')),
            ],
            onChanged: (version) async {
              if (version == null) return;
              try {
                await ref.read(settingsControllerProvider.notifier).save(
                      settings.copyWith(receiptTemplateVersion: version),
                    );
              } catch (error) {
                if (context.mounted) SnackbarUtils.error(context, error);
              }
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            // ignore: deprecated_member_use
            value: markets.any((m) => m.id == settings.defaultMarketId)
                ? settings.defaultMarketId
                : null,
            decoration: const InputDecoration(labelText: 'Default market'),
            items: [
              const DropdownMenuItem(value: null, child: Text('None')),
              for (final market in markets)
                DropdownMenuItem(value: market.id, child: Text(market.name)),
            ],
            onChanged: (id) async {
              try {
                await ref.read(settingsControllerProvider.notifier).save(
                      settings.copyWith(
                        defaultMarketId: id,
                        clearDefaultMarketId: id == null,
                      ),
                    );
              } catch (error) {
                if (context.mounted) SnackbarUtils.error(context, error);
              }
            },
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: const Text('Printer'),
              subtitle: Text(
                settings.printerName == null
                    ? 'Not configured'
                    : '${settings.printerName} · ${settings.paperWidthMm}mm',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/printer'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last receipt sequence: ${settings.lastReceiptSequence}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Save settings',
            isLoading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final tax = double.tryParse(_tax.text.trim());
    if (_company.text.trim().isEmpty) {
      SnackbarUtils.error(context, 'Company header is required');
      return;
    }
    if (tax == null) {
      SnackbarUtils.error(context, 'Enter a valid tax percent');
      return;
    }
    setState(() => _saving = true);
    try {
      final current = ref.read(settingsControllerProvider);
      await ref.read(settingsControllerProvider.notifier).save(
            current.copyWith(
              companyHeaderName: _company.text.trim(),
              defaultTaxPercent: tax,
              receiptNumberPrefix: _prefix.text.trim().isEmpty
                  ? current.receiptNumberPrefix
                  : _prefix.text.trim(),
              defaultReceiverName: _receiver.text.trim().isEmpty
                  ? null
                  : _receiver.text.trim(),
              clearDefaultReceiverName: _receiver.text.trim().isEmpty,
              whatsappNumber: _whatsapp.text.trim().isEmpty
                  ? null
                  : _whatsapp.text.trim(),
              clearWhatsappNumber: _whatsapp.text.trim().isEmpty,
            ),
          );
      if (!mounted) return;
      SnackbarUtils.success(context, 'Settings saved');
    } catch (error) {
      if (mounted) SnackbarUtils.error(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}