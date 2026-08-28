import 'dart:typed_data';

import '../../../data/models/app_settings.dart';
import '../../../data/models/receipt.dart';
import '../../printing/services/receipt_bitmap_builder.dart';
import 'receipt_template.dart';

/// Classic receipt layout — delegates to the original [ReceiptBitmapBuilder].
class ReceiptTemplateV1 implements ReceiptTemplate {
  ReceiptTemplateV1({ReceiptBitmapBuilder? builder})
    : _builder = builder ?? ReceiptBitmapBuilder();

  final ReceiptBitmapBuilder _builder;

  @override
  Future<Uint8List> buildPng({
    required Receipt receipt,
    required AppSettings settings,
    String? marketCityDistrict,
    String? companyHeaderName,
    required int widthPx,
  }) {
    return _builder.buildPng(
      receipt: receipt,
      settings: settings,
      marketCityDistrict: marketCityDistrict,
      companyHeaderName: companyHeaderName,
      widthPx: widthPx,
    );
  }
}
