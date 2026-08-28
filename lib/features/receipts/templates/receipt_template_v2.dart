import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/models/receipt.dart';
import 'receipt_template.dart';

/// Compact PCMMDC receipt — same fields as v1 with tighter vertical spacing.
class ReceiptTemplateV2 implements ReceiptTemplate {
  static const _body = 17.0;
  static const _company = 20.0;
  static const _table = 15.0;
  static const _summary = 18.0;
  static const _issuedName = 20.0;
  static const _paid = 22.0;
  static const _footer = 15.0;
  static const _edge = 4.0;
  static const _lineHeight = 1.12;
  static const _gapRow = 1.0;
  static const _gapSection = 1.0;
  static const _gapCenter = 1.0;
  static const _gapDashBefore = 1.0;
  static const _gapDashAfter = 2.0;
  static const _gapFooter = 2.0;

  @override
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

    var y = 3.0;
    final logo = await _logo();
    if (logo != null) {
      const logoW = 112.0;
      final logoH = logoW * logo.height / logo.width;
      final dx = (widthPx - logoW) / 2;
      canvas.drawImageRect(
        logo,
        Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
        Rect.fromLTWH(dx, y, logoW, logoH),
        Paint(),
      );
      y += logoH + 2;
    }

    final company = (companyHeaderName != null && companyHeaderName.isNotEmpty)
        ? companyHeaderName
        : settings.companyHeaderName;
    y = _center(canvas, company, y, widthPx, size: _company, bold: true);
    y += _gapSection;

    y = _kv(canvas, AppConstants.labelDivision, marketCityDistrict ?? '', y, widthPx);
    y = _kv(canvas, AppConstants.labelMarket, receipt.marketNameSnapshot, y, widthPx);
    y = _kv(
      canvas,
      AppConstants.labelContractor,
      receipt.contractorName?.trim().isNotEmpty == true
          ? receipt.contractorName!.trim()
          : '-',
      y,
      widthPx,
    );
    y = _kv(canvas, AppConstants.labelOperator, receipt.receiverName, y, widthPx);
    y += _gapSection;
    y = _center(canvas, AppConstants.labelReceiptNo, y, widthPx, bold: true);
    y = _center(
      canvas,
      receipt.receiptNumber,
      y,
      widthPx,
      bold: true,
      ltr: true,
    );
    y += _gapRow;
    y = _center(canvas, AppConstants.labelDateTime, y, widthPx, bold: true);
    y = _center(
      canvas,
      DateFormatter.receiptPrintDateTime(receipt.createdAt),
      y,
      widthPx,
      bold: true,
      ltr: true,
    );
    y += _gapSection;
    y = _center(canvas, AppConstants.labelFeeReceipt, y, widthPx, bold: true);
    y += _gapRow;

    y = _tableHeader(canvas, y, widthPx);
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

    y = _dash(canvas, y, widthPx);
    y = _summaryRow(
      canvas,
      y,
      widthPx,
      label: 'PST(${CurrencyFormatter.receipt(receipt.taxPercent)}%)',
      value: CurrencyFormatter.receipt(receipt.taxAmount),
      bold: true,
    );
    y = _summaryRow(
      canvas,
      y,
      widthPx,
      label: AppConstants.labelTotalAmount,
      value: CurrencyFormatter.receipt(receipt.totalAmount),
      bold: true,
    );
    y = _dash(canvas, y, widthPx);

    y = _center(canvas, AppConstants.labelIssuedBy, y, widthPx, bold: true);
    y = _center(
      canvas,
      receipt.receiverName,
      y,
      widthPx,
      size: _issuedName,
      bold: true,
      ltr: _isLatin(receipt.receiverName),
    );
    y += _gapRow;
    y = _center(
      canvas,
      receipt.isPaid ? AppConstants.labelPaid : AppConstants.labelUnpaid,
      y,
      widthPx,
      size: _paid,
      bold: true,
    );
    y += _gapSection;

    final whatsapp = (settings.whatsappNumber?.trim().isNotEmpty == true)
        ? settings.whatsappNumber!.trim()
        : AppConstants.defaultWhatsappNumber;
    final lat = receipt.latitude ?? AppConstants.defaultLatitude;
    final lng = receipt.longitude ?? AppConstants.defaultLongitude;
    final gps = '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
    y = _contact(canvas, AppConstants.labelHelpline, AppConstants.helplineNumber, y, widthPx);
    y = _contact(canvas, AppConstants.labelWhatsapp, whatsapp, y, widthPx);
    y = _contact(canvas, AppConstants.labelGps, gps, y, widthPx);
    y += _gapSection;
    y = _center(canvas, AppConstants.labelThanks, y, widthPx, size: _footer);
    y += _gapRow;
    y = _poweredBy(canvas, y, widthPx);
    y += _gapFooter;

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
    double size = _body,
    bool bold = false,
    bool ltr = false,
    double gap = _gapCenter,
  }) {
    final painter = _painter(
      text,
      size: size,
      bold: bold,
      align: TextAlign.center,
      ltr: ltr,
    )..layout(maxWidth: width - 8);
    painter.paint(canvas, Offset((width - painter.width) / 2, y));
    return y + painter.height + gap;
  }

  double _kv(Canvas canvas, String label, String value, double y, int width) {
    final latin = _isLatin(value);
    final labelPainter = _painter(
      label,
      size: _body,
      bold: true,
      align: TextAlign.right,
    )..layout();
    final valuePainter = _painter(
      value,
      size: _body,
      bold: true,
      align: TextAlign.left,
      ltr: latin,
    )..layout(maxWidth: width - labelPainter.width - 16);
    valuePainter.paint(canvas, Offset(_edge, y));
    labelPainter.paint(canvas, Offset(width - _edge - labelPainter.width, y));
    return y +
        (labelPainter.height > valuePainter.height
            ? labelPainter.height
            : valuePainter.height) +
        _gapRow;
  }

  double _contact(
    Canvas canvas,
    String label,
    String value,
    double y,
    int width,
  ) {
    return _center(
      canvas,
      '$label : \u2066$value\u2069',
      y,
      width,
      size: _footer,
      gap: 0,
    );
  }

  double _poweredBy(Canvas canvas, double y, int width) {
    final painter = TextPainter(
      text: TextSpan(
        text: AppConstants.poweredBy,
        style: TextStyle(
          color: Colors.black,
          fontSize: _footer,
          fontWeight: FontWeight.w400,
          height: 1.15,
          letterSpacing: 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: width - 8);
    painter.paint(canvas, Offset((width - painter.width) / 2, y));
    return y + painter.height + _gapRow;
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
    const pad = 4.0;
    final amountW = width * 0.22;
    final rateW = width * 0.22;
    final qtyW = width * 0.16;
    final nameW = width - amountW - rateW - qtyW - pad * 2;
    var x = pad;
    _cell(canvas, amount, x, y, amountW, TextAlign.left, bold, ltr: true);
    x += amountW;
    _cell(canvas, rate, x, y, rateW, TextAlign.center, bold, ltr: true);
    x += rateW;
    _cell(canvas, qty, x, y, qtyW, TextAlign.center, bold, ltr: true);
    x += qtyW;
    final namePainter = _cell(canvas, name, x, y, nameW, TextAlign.right, bold);
    return y + namePainter + _gapRow;
  }

  double _cell(
    Canvas canvas,
    String text,
    double x,
    double y,
    double w,
    TextAlign align,
    bool bold, {
    bool ltr = false,
  }) {
    final painter = _painter(
      text,
      size: _table,
      bold: bold,
      align: align,
      ltr: ltr,
    )..layout(maxWidth: w);
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
    final valuePainter = _painter(
      value,
      size: _summary,
      bold: bold,
      align: TextAlign.left,
      ltr: true,
    )..layout();
    final labelPainter = _painter(
      label,
      size: _summary,
      bold: bold,
      align: TextAlign.right,
    )..layout();
    valuePainter.paint(canvas, Offset(_edge, y));
    labelPainter.paint(canvas, Offset(width - _edge - labelPainter.width, y));
    return y + labelPainter.height + _gapRow;
  }

  double _dash(Canvas canvas, double y, int width) {
    y += _gapDashBefore;
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.6;
    const dash = 5.0;
    const gap = 3.0;
    var x = 0.0;
    while (x < width) {
      final end = (x + dash).clamp(0.0, width.toDouble());
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      x += dash + gap;
    }
    return y + _gapDashAfter;
  }

  TextPainter _painter(
    String text, {
    required double size,
    bool bold = false,
    required TextAlign align,
    bool ltr = false,
  }) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black,
          fontSize: size,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w400,
          height: _lineHeight,
        ),
      ),
      textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
      textAlign: align,
      locale: const Locale('ur', 'PK'),
    );
  }

  bool _isLatin(String value) {
    final trimmed = value.trim();
    return trimmed.isNotEmpty && RegExp(r'^[\x00-\x7F]+$').hasMatch(trimmed);
  }
}
