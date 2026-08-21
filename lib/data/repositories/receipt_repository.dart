import '../../core/constants/app_constants.dart';
import '../../core/utils/receipt_number_generator.dart';
import '../local/hive_service.dart';
import '../models/receipt.dart';
import 'settings_repository.dart';

class ReceiptRepository {
  ReceiptRepository(this._hive, this._settings);

  final HiveService _hive;
  final SettingsRepository _settings;

  List<Receipt> getAll() {
    final items = _hive.receiptsBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Receipt? getById(String id) => _hive.receiptsBox.get(id);

  /// Increments [AppSettings.lastReceiptSequence] first so a crash cannot
  /// reuse a number, then persists the receipt.
  Future<Receipt> create(Receipt receipt) async {
    final settings = _settings.get();
    final nextSequence = settings.lastReceiptSequence + 1;
    final number = ReceiptNumberGenerator.format(
      prefix: settings.receiptNumberPrefix,
      sequence: nextSequence,
      padWidth: AppConstants.receiptNumberPadWidth,
    );

    await _settings.save(
      settings.copyWith(lastReceiptSequence: nextSequence),
    );

    receipt.receiptNumber = number;
    await _hive.receiptsBox.put(receipt.id, receipt);
    return receipt;
  }

  Future<void> update(Receipt receipt) async {
    await _hive.receiptsBox.put(receipt.id, receipt);
  }

  Future<void> markPrinted(String id) async {
    final receipt = getById(id);
    if (receipt == null) return;
    receipt.printCount += 1;
    receipt.lastPrintedAt = DateTime.now();
    await update(receipt);
  }
}