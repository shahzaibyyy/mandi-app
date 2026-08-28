import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/models/receipt.dart';
import 'receipt_template.dart';

/// Market-style receipt matching the Ahmer Ali reference slip (Image A).
class ReceiptTemplateV3 implements ReceiptTemplate {
  static const _body = 15.0;
  static const _company = 15.0;
  static const _table = 14.0;
  static const _summary = 15.0;
  static const _totalValue = 17.0;
  static const _paid = 18.0;
  static const _footer = 14.0;
  static const _edge = 4.0;

  static final _dateOnly = DateFormat('dd/MM/yyyy');
  static final _timeOnly = DateFormat('hh:mm:ss a');

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

    var y = 6.0;
    final logo = await _logo();
    if (logo != null) {
      const logoW = 90.0;
      final logoH = logoW * logo.height / logo.width;
      final dx = (widthPx - logoW) / 2;
      canvas.drawImageRect(
        logo,
        Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
        Rect.fromLTWH(dx, y, logoW, logoH),
        Paint(),
      );
      y += logoH + 5;
    }

    final company = (companyHeaderName != null && companyHeaderName.isNotEmpty)
        ? companyHeaderName
        : settings.companyHeaderName;
    y = _center(canvas, company, y, widthPx, size: _company, gap: 4);

    y = _kvPair(
      canvas,
      y,
      widthPx,
      rightLabel: AppConstants.labelMarket,
      rightValue: receipt.marketNameSnapshot,
      leftLabel: AppConstants.labelDivision,
      leftValue: marketCityDistrict ?? '',
    );
    y = _kvPair(
      canvas,
      y,
      widthPx,
      rightLabel: 'آپریٹر',
      rightValue: receipt.receiverName,
      leftLabel: AppConstants.labelContractor,
      leftValue: receipt.contractorName?.trim().isNotEmpty == true
          ? receipt.contractorName!.trim()
          : '-',
    );

    final dateTime =
        '${_dateOnly.format(receipt.createdAt)}\n${_timeOnly.format(receipt.createdAt)}';
    y = _kvPair(
      canvas,
      y,
      widthPx,
      rightLabel: AppConstants.labelReceiptNo,
      rightValue: receipt.receiptNumber,
      rightLtr: true,
      leftLabel: 'تاریخ',
      leftValue: dateTime,
      leftLtr: true,
    );

    y += 2;
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
      valueBold: true,
    );
    y = _summaryRow(
      canvas,
      y,
      widthPx,
      label: AppConstants.labelTotal,
      value: CurrencyFormatter.receipt(receipt.totalAmount),
      valueBold: true,
      valueSize: _totalValue,
    );
    y = _dash(canvas, y, widthPx);

    y = _center(
      canvas,
      receipt.isPaid ? AppConstants.labelPaid : AppConstants.labelUnpaid,
      y,
      widthPx,
      size: _paid,
      bold: true,
      gap: 5,
    );

    final whatsapp = (settings.whatsappNumber?.trim().isNotEmpty == true)
        ? settings.whatsappNumber!.trim()
        : AppConstants.defaultWhatsappNumber;
    final lat = receipt.latitude ?? AppConstants.defaultLatitude;
    final lng = receipt.longitude ?? AppConstants.defaultLongitude;
    final gps = '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';

    y = _kvPair(
      canvas,
      y,
      widthPx,
      rightLabel: AppConstants.labelWhatsapp,
      rightValue: whatsapp,
      rightLtr: true,
      leftLabel: AppConstants.labelHelpline,
      leftValue: AppConstants.helplineNumber,
      leftLtr: true,
    );
    y = _kv(canvas, AppConstants.labelGps, gps, y, widthPx, ltrValue: true);
    y += 3;
    y = _center(
      canvas,
      '${AppConstants.labelThanks} | PCMMDC',
      y,
      widthPx,
      size: _footer,
      ltr: true,
      gap: 2,
    );
    y = _center(
      canvas,
      'App Version: ${AppConstants.appVersion}',
      y,
      widthPx,
      size: 12,
      ltr: true,
      gap: 8,
    );

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
    double gap = 3,
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

  /// One label+value pair: label on the right, value on the left.
  double _kv(
    Canvas canvas,
    String label,
    String value,
    double y,
    int width, {
    bool ltrValue = false,
  }) {
    final rowH = _labelValuePair(
      canvas,
      label,
      value,
      y,
      _edge,
      width.toDouble() - _edge,
      ltrValue: ltrValue,
    );
    return y + rowH + 3;
  }

  /// Two mirrored label+value pairs on one row (right half + left half).
  double _kvPair(
    Canvas canvas,
    double y,
    int width, {
    required String rightLabel,
    required String rightValue,
    required String leftLabel,
    required String leftValue,
    bool rightLtr = false,
    bool leftLtr = false,
  }) {
    final mid = width / 2.0;
    final rightH = _labelValuePair(
      canvas,
      rightLabel,
      rightValue,
      y,
      mid + 2,
      width.toDouble() - _edge,
      ltrValue: rightLtr,
    );
    final leftH = _labelValuePair(
      canvas,
      leftLabel,
      leftValue,
      y,
      _edge,
      mid - 2,
      ltrValue: leftLtr,
    );
    return y + (rightH > leftH ? rightH : leftH) + 3;
  }

  double _labelValuePair(
    Canvas canvas,
    String label,
    String value,
    double y,
    double regionLeft,
    double regionRight, {
    bool ltrValue = false,
  }) {
    final regionW = regionRight - regionLeft;
    final labelPainter = _painter(
      label,
      size: _body,
      align: TextAlign.right,
    )..layout(maxWidth: regionW * 0.42);
    final valuePainter = _painter(
      value,
      size: _body,
      align: TextAlign.left,
      ltr: ltrValue || _isLatin(value),
    )..layout(maxWidth: regionW * 0.52);

    labelPainter.paint(
      canvas,
      Offset(regionRight - labelPainter.width, y),
    );
    valuePainter.paint(canvas, Offset(regionLeft, y));

    return labelPainter.height > valuePainter.height
        ? labelPainter.height
        : valuePainter.height;
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
  }) {
    const pad = 4.0;
    final amountW = width * 0.22;
    final rateW = width * 0.22;
    final qtyW = width * 0.16;
    final nameW = width - amountW - rateW - qtyW - pad * 2;
    var x = pad;
    _cell(canvas, amount, x, y, amountW, TextAlign.left, ltr: true);
    x += amountW;
    _cell(canvas, rate, x, y, rateW, TextAlign.center, ltr: true);
    x += rateW;
    _cell(canvas, qty, x, y, qtyW, TextAlign.center, ltr: true);
    x += qtyW;
    final namePainter = _cell(canvas, name, x, y, nameW, TextAlign.right);
    return y + namePainter + 3;
  }

  double _cell(
    Canvas canvas,
    String text,
    double x,
    double y,
    double w,
    TextAlign align, {
    bool ltr = false,
  }) {
    final painter = _painter(
      text,
      size: _table,
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
    bool valueBold = false,
    double valueSize = _summary,
  }) {
    final valuePainter = _painter(
      value,
      size: valueSize,
      bold: valueBold,
      align: TextAlign.left,
      ltr: true,
    )..layout();
    final labelPainter = _painter(label, size: _summary, align: TextAlign.right)
      ..layout();
    valuePainter.paint(canvas, Offset(_edge, y));
    labelPainter.paint(canvas, Offset(width - _edge - labelPainter.width, y));
    return y + valuePainter.height + 3;
  }

  double _dash(Canvas canvas, double y, int width) {
    y += 4;
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.4;
    const dash = 5.0;
    const gap = 3.0;
    var x = 0.0;
    while (x < width) {
      final end = (x + dash).clamp(0.0, width.toDouble());
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      x += dash + gap;
    }
    return y + 5;
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
          height: 1.25,
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
