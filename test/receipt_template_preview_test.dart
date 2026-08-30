import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_fee_collector/core/constants/app_constants.dart';
import 'package:mandi_fee_collector/data/models/app_settings.dart';
import 'package:mandi_fee_collector/data/models/receipt.dart';
import 'package:mandi_fee_collector/data/models/receipt_line_item.dart';
import 'package:mandi_fee_collector/features/receipts/templates/receipt_template_v3.dart';
import 'package:mandi_fee_collector/features/receipts/templates/receipt_template_v4.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final loader = FontLoader('NotoNaskhArabic');
    loader.addFont(rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf'));
    loader.addFont(rootBundle.load('assets/fonts/NotoNaskhArabic-SemiBold.ttf'));
    loader.addFont(rootBundle.load('assets/fonts/NotoNaskhArabic-Bold.ttf'));
    await loader.load();
  });

  test('v3 and v4 render 58mm PNGs', () async {
    final receipt = Receipt(
      id: 'preview',
      receiptNumber: 'MND-260829',
      marketId: 'm1',
      marketNameSnapshot: 'ماڈل مویشی منڈی',
      receiverName: 'Ahmer Ali',
      contractorName: null,
      lineItems: [
        ReceiptLineItem(
          feeTypeName: 'بڑے جانور',
          unitLabel: 'جانور',
          quantity: 1,
          unitRate: 1500,
          amount: 1500,
        ),
      ],
      subtotal: 1500,
      taxPercent: 16,
      taxAmount: 240,
      totalAmount: 1740,
      isPaid: true,
      latitude: AppConstants.defaultLatitude,
      longitude: AppConstants.defaultLongitude,
      createdAt: DateTime(2026, 8, 29, 12, 17, 34),
    );
    final settings = AppSettings.defaults();
    const widthPx = 384;

    final v3 = await ReceiptTemplateV3().buildPng(
      receipt: receipt,
      settings: settings,
      marketCityDistrict: 'شیخوپورہ',
      widthPx: widthPx,
    );
    final v4 = await ReceiptTemplateV4().buildPng(
      receipt: receipt,
      settings: settings,
      marketCityDistrict: 'شیخوپورہ',
      widthPx: widthPx,
    );

    expect(v3.length, greaterThan(1000));
    expect(v4.length, greaterThan(1000));
    expect(v3.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10]);
    expect(v4.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10]);

    final dir = Directory('/tmp/receipt-previews')..createSync(recursive: true);
    File('${dir.path}/v3.png').writeAsBytesSync(v3);
    File('${dir.path}/v4.png').writeAsBytesSync(v4);
  });
}
