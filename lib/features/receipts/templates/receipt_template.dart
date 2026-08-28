import 'dart:typed_data';

import '../../../data/models/app_settings.dart';
import '../../../data/models/receipt.dart';

abstract class ReceiptTemplate {
  Future<Uint8List> buildPng({
    required Receipt receipt,
    required AppSettings settings,
    String? marketCityDistrict,
    String? companyHeaderName,
    required int widthPx,
  });
}
