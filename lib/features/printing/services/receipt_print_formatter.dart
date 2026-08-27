import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image/image.dart' as img;

import '../../../data/models/app_settings.dart';
import '../../../data/models/receipt.dart';
import 'receipt_bitmap_builder.dart';

class ReceiptPrintFormatter {
  ReceiptPrintFormatter({ReceiptBitmapBuilder? bitmapBuilder})
    : _bitmap = bitmapBuilder ?? ReceiptBitmapBuilder();

  final ReceiptBitmapBuilder _bitmap;
  static const _renderScale = 2;

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
      widthPx: widthPx * _renderScale,
    );
    var decoded = img.decodePng(png);
    if (decoded == null) {
      throw Exception('Could not render the Urdu receipt image.');
    }
    if (_renderScale > 1) {
      decoded = img.copyResize(
        decoded,
        width: widthPx,
        interpolation: img.Interpolation.average,
      );
    }
    final binary = _binarize(img.grayscale(decoded));

    final bytes = <int>[];
    bytes.addAll(generator.reset());
    const chunk = 240;
    for (var top = 0; top < binary.height; top += chunk) {
      final height = (top + chunk <= binary.height) ? chunk : binary.height - top;
      final slice = img.copyCrop(
        binary,
        x: 0,
        y: top,
        width: binary.width,
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

  img.Image _binarize(img.Image gray) {
    final out = img.Image(width: gray.width, height: gray.height);
    for (var y = 0; y < gray.height; y++) {
      for (var x = 0; x < gray.width; x++) {
        final l = gray.getPixel(x, y).r;
        out.setPixel(x, y, l < 150 ? img.ColorRgb8(0, 0, 0) : img.ColorRgb8(255, 255, 255));
      }
    }
    return out;
  }
}
