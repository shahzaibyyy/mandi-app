import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/models/receipt.dart';

/// Renders the PCMMDC-style Urdu thermal receipt as a PNG.
class ReceiptBitmapBuilder {
  Future<Uint8List> buildPng({
    required Receipt receipt,
    required AppSettings settings,
    String? marketCityDistrict,
    String? companyHeaderName,
    required int widthPx,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, widthPx.toDouble(), 4000),
      Paint()..color = Colors.white,
    );

    var y = 8.0;
    final logo = await _logo();
    if (logo != null) {
      const logoW = 96.0;
      final logoH = logoW * logo.height / logo.width;
      final dx = (widthPx - logoW) / 2;
      canvas.drawImageRect(
        logo,
        Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
        Rect.fromLTWH(dx, y, logoW, logoH),
        Paint(),
      );
      y += logoH + 8;
    }

    final company = (companyHeaderName != null && companyHeaderName.isNotEmpty)
        ? companyHeaderName
        : settings.companyHeaderName;
    y = _center(canvas, company, y, widthPx, size: 15, bold: true);
    y += 10;

    y = _kv(canvas, 'ٹاؤن', marketCityDistrict ?? '', y, widthPx);
    y = _kv(canvas, 'مارکیٹ', receipt.marketNameSnapshot, y, widthPx);
    y = _kv(
      canvas,
      'نام ٹھیکیدار',
      receipt.contractorName?.trim().isNotEmpty == true
          ? receipt.contractorName!.trim()
          : '-',
      y,
      widthPx,
    );
    y = _kv(canvas, 'نام آپریٹر', receipt.receiverName, y, widthPx);
    y += 8;

    y = _center(canvas, 'رسید نمبر ${receipt.receiptNumber}', y, widthPx);
    y = _center(
      canvas,
      'تاریخ و وقت ${DateFormatter.receiptPrintDateTime(receipt.createdAt)}',
      y,
      widthPx,
    );
    y = _dash(canvas, y, widthPx);
    y = _center(canvas, 'فیس رسید', y, widthPx, bold: true);
    y += 4;

    y = _tableHeader(canvas, y, widthPx);
    y = _line(canvas, y, widthPx);
    for (final item in receipt.lineItems) {
      y = _tableRow(
        canvas,
        y,
        widthPx,
        name: item.feeTypeName,
        qty: CurrencyFormatter.receipt(item.quantity),
        rate: CurrencyFormatter.receipt(item.unitRate),
        amount: CurrencyFormatter.receipt(item.amount),
      );
    }
    y = _line(canvas, y, widthPx);

    y = _summaryRow(
      canvas,
      y,
      widthPx,
      label: 'PST(${CurrencyFormatter.receipt(receipt.taxPercent)}%)',
      value: CurrencyFormatter.receipt(receipt.taxAmount),
    );
    y = _summaryRow(
      canvas,
      y,
      widthPx,
      label: 'کل',
      value: CurrencyFormatter.receipt(receipt.totalAmount),
      bold: true,
    );
    y = _dash(canvas, y, widthPx);

    y = _center(canvas, 'جاری کردہ توسط ${receipt.receiverName}', y, widthPx);
    y += 4;
    y = _center(
      canvas,
      receipt.isPaid ? 'ادا شدہ' : 'غیر ادا شدہ',
      y,
      widthPx,
      size: 22,
      bold: true,
    );
    y += 8;

    final whatsapp = (settings.whatsappNumber?.trim().isNotEmpty == true)
        ? settings.whatsappNumber!.trim()
        : AppConstants.defaultWhatsappNumber;
    y = _kv(canvas, 'ہیلپ لائن', AppConstants.helplineNumber, y, widthPx);
    y = _kv(canvas, 'واٹس ایپ', whatsapp, y, widthPx);
    final gps = (receipt.latitude != null && receipt.longitude != null)
        ? '${receipt.latitude!.toStringAsFixed(6)}, ${receipt.longitude!.toStringAsFixed(6)}'
        : '-';
    y = _kv(canvas, 'GPS مقام', gps, y, widthPx);
    y += 6;
    y = _center(canvas, 'شکریہ', y, widthPx, bold: true);
    y = _center(canvas, AppConstants.poweredBy, y, widthPx, size: 12);
    y += 12;

    final picture = recorder.endRecording();
    final image = await picture.toImage(widthPx, y.ceil());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  Future<ui.Image?> _logo() async {
    try {
      final data = await rootBundle.load(AppConstants.logoAsset);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  double _center(
    Canvas canvas,
    String text,
    double y,
    int width, {
    double size = 13,
    bool bold = false,
  }) {
    final painter = _painter(
      text,
      size: size,
      bold: bold,
      align: TextAlign.center,
    )..layout(maxWidth: width - 16);
    painter.paint(canvas, Offset((width - painter.width) / 2, y));
    return y + painter.height + 3;
  }

  double _kv(Canvas canvas, String label, String value, double y, int width) {
    final painter = _painter(
      '$label: $value',
      size: 13,
      align: TextAlign.right,
    )..layout(maxWidth: width - 16);
    painter.paint(canvas, Offset(width - 8 - painter.width, y));
    return y + painter.height + 3;
  }

  double _tableHeader(Canvas canvas, double y, int width) {
    return _tableRow(
      canvas,
      y,
      width,
      name: 'فیس کی قسم',
      qty: 'تعداد',
      rate: 'یونٹ',
      amount: 'قیمت',
      bold: true,
    );
  }

  double _tableRow(
    Canvas canvas,
    double y,
    int width, {
    required String name,
    required String qty,
    required String rate,
    required String amount,
    bool bold = false,
  }) {
    const pad = 6.0;
    final amountW = width * 0.22;
    final rateW = width * 0.22;
    final qtyW = width * 0.16;
    final nameW = width - amountW - rateW - qtyW - pad * 2;
    var x = pad;
    _cell(canvas, amount, x, y, amountW, TextAlign.left, bold);
    x += amountW;
    _cell(canvas, rate, x, y, rateW, TextAlign.center, bold);
    x += rateW;
    _cell(canvas, qty, x, y, qtyW, TextAlign.center, bold);
    x += qtyW;
    final namePainter = _cell(canvas, name, x, y, nameW, TextAlign.right, bold);
    return y + namePainter + 4;
  }

  double _cell(
    Canvas canvas,
    String text,
    double x,
    double y,
    double w,
    TextAlign align,
    bool bold,
  ) {
    final painter = _painter(text, size: 12, bold: bold, align: align)
      ..layout(maxWidth: w);
    final dx = switch (align) {
      TextAlign.right => x + w - painter.width,
      TextAlign.center => x + (w - painter.width) / 2,
      _ => x,
    };
    painter.paint(canvas, Offset(dx, y));
    return painter.height;
  }

  double _summaryRow(
    Canvas canvas,
    double y,
    int width, {
    required String label,
    required String value,
    bool bold = false,
  }) {
    final valuePainter = _painter(value, size: 14, bold: bold, align: TextAlign.left)
      ..layout();
    final labelPainter = _painter(label, size: 14, bold: bold, align: TextAlign.right)
      ..layout();
    valuePainter.paint(canvas, Offset(8, y));
    labelPainter.paint(canvas, Offset(width - 8 - labelPainter.width, y));
    return y + labelPainter.height + 4;
  }

  double _dash(Canvas canvas, double y, int width) {
    y += 4;
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;
    const dash = 6.0;
    const gap = 4.0;
    var x = 8.0;
    while (x < width - 8) {
      canvas.drawLine(Offset(x, y), Offset((x + dash).clamp(0, width - 8), y), paint);
      x += dash + gap;
    }
    return y + 8;
  }

  double _line(Canvas canvas, double y, int width) {
    y += 2;
    canvas.drawLine(
      Offset(8, y),
      Offset(width - 8.0, y),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 1,
    );
    return y + 6;
  }

  TextPainter _painter(
    String text, {
    required double size,
    bool bold = false,
    required TextAlign align,
  }) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black,
          fontSize: size,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
          height: 1.25,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: align,
    );
  }
}