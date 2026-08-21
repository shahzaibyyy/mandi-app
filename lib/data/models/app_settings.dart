import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 4)
class AppSettings extends HiveObject {
  AppSettings({
    required this.companyHeaderName,
    this.defaultMarketId,
    required this.defaultTaxPercent,
    required this.receiptNumberPrefix,
    required this.lastReceiptSequence,
    this.printerMacAddress,
    this.printerName,
    required this.paperWidthMm,
    this.whatsappNumber,
    this.defaultReceiverName,
  });

  factory AppSettings.defaults() {
    return AppSettings(
      companyHeaderName: AppConstants.defaultCompanyHeader,
      defaultTaxPercent: AppConstants.defaultTaxPercent,
      receiptNumberPrefix: AppConstants.receiptNumberPrefix,
      lastReceiptSequence: 0,
      paperWidthMm: AppConstants.defaultPaperWidthMm,
    );
  }

  @HiveField(0)
  String companyHeaderName;

  @HiveField(1)
  String? defaultMarketId;

  @HiveField(2)
  double defaultTaxPercent;

  @HiveField(3)
  String receiptNumberPrefix;

  @HiveField(4)
  int lastReceiptSequence;

  @HiveField(5)
  String? printerMacAddress;

  @HiveField(6)
  String? printerName;

  @HiveField(7)
  int paperWidthMm;

  @HiveField(8)
  String? whatsappNumber;

  @HiveField(9)
  String? defaultReceiverName;

  AppSettings copyWith({
    String? companyHeaderName,
    String? defaultMarketId,
    bool clearDefaultMarketId = false,
    double? defaultTaxPercent,
    String? receiptNumberPrefix,
    int? lastReceiptSequence,
    String? printerMacAddress,
    bool clearPrinter = false,
    String? printerName,
    int? paperWidthMm,
    String? whatsappNumber,
    bool clearWhatsappNumber = false,
    String? defaultReceiverName,
    bool clearDefaultReceiverName = false,
  }) {
    return AppSettings(
      companyHeaderName: companyHeaderName ?? this.companyHeaderName,
      defaultMarketId: clearDefaultMarketId
          ? defaultMarketId
          : (defaultMarketId ?? this.defaultMarketId),
      defaultTaxPercent: defaultTaxPercent ?? this.defaultTaxPercent,
      receiptNumberPrefix: receiptNumberPrefix ?? this.receiptNumberPrefix,
      lastReceiptSequence: lastReceiptSequence ?? this.lastReceiptSequence,
      printerMacAddress: clearPrinter
          ? printerMacAddress
          : (printerMacAddress ?? this.printerMacAddress),
      printerName: clearPrinter ? printerName : (printerName ?? this.printerName),
      paperWidthMm: paperWidthMm ?? this.paperWidthMm,
      whatsappNumber: clearWhatsappNumber
          ? whatsappNumber
          : (whatsappNumber ?? this.whatsappNumber),
      defaultReceiverName: clearDefaultReceiverName
          ? defaultReceiverName
          : (defaultReceiverName ?? this.defaultReceiverName),
    );
  }
}