import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_settings.dart';
import '../../../data/models/receipt.dart';
import '../../../data/providers.dart';
import 'bluetooth_printer_service.dart';
import 'receipt_print_formatter.dart';

class PrintResult {
  const PrintResult({required this.success, this.message});

  final bool success;
  final String? message;
}

class ReceiptPrintController {
  ReceiptPrintController(this._printer, this._formatter);

  final BluetoothPrinterService _printer;
  final ReceiptPrintFormatter _formatter;

  Future<PrintResult> printReceipt({
    required Receipt receipt,
    required AppSettings settings,
    String? marketCityDistrict,
    String? companyHeaderName,
  }) async {
    final mac = settings.printerMacAddress;
    if (mac == null || mac.isEmpty) {
      return const PrintResult(
        success: false,
        message: 'No printer selected. Open Printer settings to pair one.',
      );
    }

    final permitted = await _printer.requestPermissions();
    if (!permitted) {
      return const PrintResult(
        success: false,
        message: 'Bluetooth permission is required to print.',
      );
    }

    final bluetoothOn = await _printer.isBluetoothOn();
    if (!bluetoothOn) {
      return const PrintResult(
        success: false,
        message: 'Turn on Bluetooth and try again.',
      );
    }

    final connected = await _printer.ensureConnected(mac);
    if (!connected) {
      return PrintResult(
        success: false,
        message: 'Could not connect to ${settings.printerName ?? mac}.',
      );
    }

    final bytes = await _formatter.buildBytes(
      receipt: receipt,
      settings: settings,
      marketCityDistrict: marketCityDistrict,
      companyHeaderName: companyHeaderName,
    );
    final written = await _printer.writeBytes(bytes);
    if (!written) {
      return const PrintResult(
        success: false,
        message: 'Printer did not accept the receipt data.',
      );
    }
    return const PrintResult(success: true);
  }
}

final receiptPrintFormatterProvider = Provider<ReceiptPrintFormatter>((ref) {
  return ReceiptPrintFormatter();
});

final receiptPrintControllerProvider = Provider<ReceiptPrintController>((ref) {
  return ReceiptPrintController(
    ref.watch(bluetoothPrinterServiceProvider),
    ref.watch(receiptPrintFormatterProvider),
  );
});

Future<PrintResult> printAndRecord(
  WidgetRef ref, {
  required Receipt receipt,
}) async {
  final settings = ref.read(settingsControllerProvider);
  final market = ref.read(marketRepositoryProvider).getById(receipt.marketId);
  final result = await ref.read(receiptPrintControllerProvider).printReceipt(
    receipt: receipt,
    settings: settings,
    marketCityDistrict: market?.cityDistrict,
    companyHeaderName: market?.companyHeaderName,
  );
  if (result.success) {
    await ref.read(receiptsControllerProvider.notifier).markPrinted(receipt.id);
  }
  return result;
}