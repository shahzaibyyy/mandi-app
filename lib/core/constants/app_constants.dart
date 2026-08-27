class AppConstants {
  AppConstants._();

  static const String appName = 'Mandi Receipts';
  static const String appVersion = '1.0.0';

  static const String marketsBox = 'markets';
  static const String feeTypesBox = 'fee_types';
  static const String receiptsBox = 'receipts';
  static const String settingsBox = 'app_settings';
  static const String settingsKey = 'settings';

  static const double defaultTaxPercent = 16.0;
  static const String currencySymbol = 'Rs';
  static const String receiptNumberPrefix = 'MND-';
  static const int receiptNumberPadWidth = 6;
  static const int defaultPaperWidthMm = 58;

  static const String defaultCompanyHeader =
      'پنجاب کیٹل مارکیٹ مینجمنٹ اینڈ ڈویلپمنٹ کمپنی';
  static const String helplineNumber = '1233';
  static const String defaultWhatsappNumber = '+92 323 1233000';
  static const String poweredBy = 'Powered by PCMMDC';
  static const String logoAsset = 'assets/images/pcmmdc_logo.png';

  static const String receiptDashLine = '--------------------------------';
  static const String labelDivision = 'ڈویژن';
  static const String labelMarket = 'مارکیٹ';
  static const String labelContractor = 'نام ٹھیکیدار';
  static const String labelOperator = 'نام آپریٹر';
  static const String labelReceiptNo = 'رسید نمبر';
  static const String labelDateTime = 'تاریخ و وقت';
  static const String labelFeeReceipt = 'فیس رسید';
  static const String labelIssuedBy = 'جاری کردہ توسط';
  static const String labelPaid = 'ادا شدہ';
  static const String labelUnpaid = 'غیر ادا شدہ';
  static const String labelHelpline = 'ہیلپ لائن';
  static const String labelWhatsapp = 'واٹس ایپ';
  static const String labelGps = 'GPS مقام';
  static const String labelThanks = 'شکریہ';
  static const String labelTotal = 'کل';
  static const String labelTotalAmount = 'کل رقم';

  static const String loginEmail = 'mandi@mailinator.com';
  static const String loginPassword = 'Mandi@123';
  static const String licenseSupportPhone = '+92 323 1233000';
  static const int licenseDaysPerMonth = 30;

  /// Fallback when device GPS is unavailable (matches original PCMMDC slip).
  static const double defaultLatitude = 31.721045;
  static const double defaultLongitude = 73.927004;
}