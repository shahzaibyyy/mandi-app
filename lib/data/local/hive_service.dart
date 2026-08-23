import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../models/app_settings.dart';
import '../models/fee_type.dart';
import '../models/market.dart';
import '../models/receipt.dart';
import '../models/receipt_line_item.dart';

class HiveService {
  HiveService._();

  static final HiveService instance = HiveService._();

  late Box<Market> marketsBox;
  late Box<FeeType> feeTypesBox;
  late Box<Receipt> receiptsBox;
  late Box<AppSettings> settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MarketAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(FeeTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ReceiptLineItemAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ReceiptAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(AppSettingsAdapter());
    }

    marketsBox = await Hive.openBox<Market>(AppConstants.marketsBox);
    feeTypesBox = await Hive.openBox<FeeType>(AppConstants.feeTypesBox);
    receiptsBox = await Hive.openBox<Receipt>(AppConstants.receiptsBox);
    settingsBox = await Hive.openBox<AppSettings>(AppConstants.settingsBox);

    if (settingsBox.get(AppConstants.settingsKey) == null) {
      await settingsBox.put(AppConstants.settingsKey, AppSettings.defaults());
    } else {
      final current = settingsBox.get(AppConstants.settingsKey)!;
      var changed = false;
      if (current.companyHeaderName == 'Market Committee') {
        current.companyHeaderName = AppConstants.defaultCompanyHeader;
        changed = true;
      }
      if (current.whatsappNumber == null || current.whatsappNumber!.isEmpty) {
        current.whatsappNumber = AppConstants.defaultWhatsappNumber;
        changed = true;
      }
      if (changed) {
        await settingsBox.put(AppConstants.settingsKey, current);
      }
    }
  }
}