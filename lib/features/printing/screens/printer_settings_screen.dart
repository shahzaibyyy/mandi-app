import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../core/utils/snackbar_utils.dart';
import '../../../data/providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../services/bluetooth_printer_service.dart';

class PrinterScanState {
  const PrinterScanState({
    this.loading = false,
    this.devices = const [],
    this.error,
  });

  final bool loading;
  final List<BluetoothInfo> devices;
  final String? error;

  PrinterScanState copyWith({
    bool? loading,
    List<BluetoothInfo>? devices,
    String? error,
    bool clearError = false,
  }) {
    return PrinterScanState(
      loading: loading ?? this.loading,
      devices: devices ?? this.devices,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PrinterScanController extends Notifier<PrinterScanState> {
  BluetoothPrinterService get _printer =>
      ref.read(bluetoothPrinterServiceProvider);

  @override
  PrinterScanState build() => const PrinterScanState();

  Future<void> loadPaired() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final permitted = await _printer.requestPermissions();
      if (!permitted) {
        state = state.copyWith(
          loading: false,
          error: 'Bluetooth permission was denied.',
        );
        return;
      }
      final on = await _printer.isBluetoothOn();
      if (!on) {
        state = state.copyWith(
          loading: false,
          error: 'Turn on Bluetooth, then scan again.',
        );
        return;
      }
      final devices = await _printer.pairedDevices();
      state = state.copyWith(loading: false, devices: devices);
    } catch (error) {
      state = state.copyWith(loading: false, error: error.toString());
    }
  }
}

final printerScanControllerProvider =
    NotifierProvider.autoDispose<PrinterScanController, PrinterScanState>(
      PrinterScanController.new,
    );

class PrinterSettingsScreen extends ConsumerStatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  ConsumerState<PrinterSettingsScreen> createState() =>
      _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends ConsumerState<PrinterSettingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(printerScanControllerProvider.notifier).loadPaired(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scan = ref.watch(printerScanControllerProvider);
    final settings = ref.watch(settingsControllerProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Printer')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text(settings.printerName ?? 'No printer selected'),
              subtitle: Text(
                settings.printerMacAddress ??
                    'Pair a 58mm/80mm ESC/POS printer in Android Bluetooth settings, then select it here.',
              ),
              trailing: const Icon(Icons.print_outlined),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            // ignore: deprecated_member_use
            value: settings.paperWidthMm,
            decoration: const InputDecoration(labelText: 'Paper width'),
            items: const [
              DropdownMenuItem(value: 58, child: Text('58 mm (32 chars)')),
              DropdownMenuItem(value: 80, child: Text('80 mm (48 chars)')),
            ],
            onChanged: (width) async {
              if (width == null) return;
              try {
                await ref
                    .read(settingsControllerProvider.notifier)
                    .save(settings.copyWith(paperWidthMm: width));
              } catch (error) {
                if (context.mounted) SnackbarUtils.error(context, error);
              }
            },
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Scan paired devices',
            icon: Icons.bluetooth_searching,
            isLoading: scan.loading,
            onPressed: scan.loading
                ? null
                : () => ref.read(printerScanControllerProvider.notifier).loadPaired(),
          ),
          const SizedBox(height: 12),
          if (scan.loading) const LoadingIndicator(message: 'Reading paired printers…'),
          if (scan.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(scan.error!, style: const TextStyle(color: Colors.red)),
            ),
          if (!scan.loading && scan.devices.isEmpty && scan.error == null)
            const EmptyState(
              icon: Icons.bluetooth_disabled,
              title: 'No paired printers',
              message:
                  'Open Android Bluetooth settings, pair the thermal printer, then tap scan.',
            ),
          for (final device in scan.devices)
            Card(
              child: ListTile(
                leading: const Icon(Icons.bluetooth),
                title: Text(device.name),
                subtitle: Text(device.macAdress),
                selected: settings.printerMacAddress == device.macAdress,
                trailing: settings.printerMacAddress == device.macAdress
                    ? const Icon(Icons.check_circle)
                    : null,
                onTap: () async {
                  try {
                    final printer = ref.read(bluetoothPrinterServiceProvider);
                    final connected = await printer.connect(device.macAdress);
                    await ref.read(settingsControllerProvider.notifier).save(
                          settings.copyWith(
                            printerMacAddress: device.macAdress,
                            printerName: device.name,
                          ),
                        );
                    if (!context.mounted) return;
                    SnackbarUtils.success(
                      context,
                      connected
                          ? 'Connected to ${device.name}'
                          : 'Saved ${device.name}. Connect when printing.',
                    );
                  } catch (error) {
                    if (context.mounted) SnackbarUtils.error(context, error);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}