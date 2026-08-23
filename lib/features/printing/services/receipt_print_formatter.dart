import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image/image.dart' as img;

import '../../../data/models/app_settings.dart';
import '../../../data/models/receipt.dart';
import 'receipt_bitmap_builder.dart';

class ReceiptPrintFormatter {
  ReceiptPrintFormatter({ReceiptBitmapBuilder? bitmapBuilder})
    : _bitmap = bitmapBuilder ?? ReceiptBitmapBuilder();

  final ReceiptBitmapBuilder _bitmap;

  Future<List<int>> buildBytes({
    required Receipt receipt,
    required AppSettings settings,
    String? marketCityDistrict,
    String? companyHeaderName,
  }) async {
    final profile = await CapabilityProfile.load();
    final paperSize = settings.paperWidthMm >= 80
        ? PaperSize.mm80
        : PaperSize.mm58;
    final widthPx = settings.paperWidthMm >= 80 ? 576 : 384;
    final generator = Generator(paperSize, profile);

    final png = await _bitmap.buildPng(
      receipt: receipt,
      settings: settings,
      marketCityDistrict: marketCityDistrict,
      companyHeaderName: companyHeaderName,
      widthPx: widthPx,
    );
    final decoded = img.decodePng(png);
    if (decoded == null) {
      throw Exception('Could not render the Urdu receipt image.');
    }
    final gray = img.grayscale(decoded);

    final bytes = <int>[];
    bytes.addAll(generator.reset());
    const chunk = 240;
    for (var top = 0; top < gray.height; top += chunk) {
      final height = (top + chunk <= gray.height) ? chunk : gray.height - top;
      final slice = img.copyCrop(
        gray,
        x: 0,
        y: top,
        width: gray.width,
        height: height,
      );
      bytes.addAll(
        generator.imageRaster(slice, align: PosAlign.center),
      );
    }
    bytes.addAll(generator.feed(2));
    bytes.addAll(generator.cut());
    return bytes;
  }
}