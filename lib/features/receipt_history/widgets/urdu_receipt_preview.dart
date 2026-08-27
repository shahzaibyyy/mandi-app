import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/models/receipt.dart';

class UrduReceiptPreview extends StatelessWidget {
  const UrduReceiptPreview({
    super.key,
    required this.receipt,
    required this.settings,
    this.cityDistrict,
    this.companyHeaderName,
  });

  final Receipt receipt;
  final AppSettings settings;
  final String? cityDistrict;
  final String? companyHeaderName;

  static const _body = 18.0;
  static const _company = 21.0;
  static const _table = 16.0;
  static const _summarySize = 19.0;
  static const _issuedName = 26.0;
  static const _paid = 32.0;

  @override
  Widget build(BuildContext context) {
    final company = (companyHeaderName != null && companyHeaderName!.isNotEmpty)
        ? companyHeaderName!
        : settings.companyHeaderName;
    final whatsapp = (settings.whatsappNumber?.trim().isNotEmpty == true)
        ? settings.whatsappNumber!.trim()
        : AppConstants.defaultWhatsappNumber;
    final lat = receipt.latitude ?? AppConstants.defaultLatitude;
    final lng = receipt.longitude ?? AppConstants.defaultLongitude;
    final gps = '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: DefaultTextStyle.merge(
            style: const TextStyle(
              fontSize: _body,
              height: 1.35,
              fontWeight: FontWeight.w400,
            ),
            child: Column(
              children: [
                Image.asset(AppConstants.logoAsset, width: 112),
                const SizedBox(height: 8),
                Text(
                  company,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: _company,
                  ),
                ),
                const SizedBox(height: 12),
                _kv(AppConstants.labelDivision, cityDistrict ?? '-'),
                _kv(AppConstants.labelMarket, receipt.marketNameSnapshot),
                _kv(
                  AppConstants.labelContractor,
                  receipt.contractorName?.trim().isNotEmpty == true
                      ? receipt.contractorName!
                      : '-',
                ),
                _kv(AppConstants.labelOperator, receipt.receiverName),
                const SizedBox(height: 6),
                _stackedCenter(
                  AppConstants.labelReceiptNo,
                  receipt.receiptNumber,
                  valueBold: true,
                  labelBold: true,
                ),
                const SizedBox(height: 6),
                _stackedCenter(
                  AppConstants.labelDateTime,
                  DateFormatter.receiptPrintDateTime(receipt.createdAt),
                  valueBold: true,
                  labelBold: true,
                ),
                const SizedBox(height: 6),
                const Text(
                  AppConstants.labelFeeReceipt,
                  style: TextStyle(
                    fontSize: _body,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                _tableRow('فیس کی قسم', 'تعداد', 'یونٹ', 'قیمت', header: true),
                for (final item in receipt.lineItems)
                  _tableRow(
                    item.feeTypeName,
                    CurrencyFormatter.receipt(item.quantity),
                    CurrencyFormatter.receipt(item.unitRate),
                    CurrencyFormatter.receipt(item.amount),
                  ),
                _dash(),
                _summary(
                  'PST(${CurrencyFormatter.receipt(receipt.taxPercent)}%)',
                  CurrencyFormatter.receipt(receipt.taxAmount),
                  bold: true,
                ),
                _summary(
                  AppConstants.labelTotalAmount,
                  CurrencyFormatter.receipt(receipt.totalAmount),
                  bold: true,
                ),
                _dash(),
                _stackedCenter(
                  AppConstants.labelIssuedBy,
                  receipt.receiverName,
                  valueSize: _issuedName,
                  valueBold: true,
                  labelBold: true,
                ),
                const SizedBox(height: 6),
                Text(
                  receipt.isPaid
                      ? AppConstants.labelPaid
                      : AppConstants.labelUnpaid,
                  style: TextStyle(
                    fontSize: _paid,
                    fontWeight: FontWeight.w900,
                    color: receipt.isPaid ? AppColors.paid : AppColors.unpaid,
                  ),
                ),
                const SizedBox(height: 10),
                _contactLine(AppConstants.labelHelpline, AppConstants.helplineNumber),
                _contactLine(AppConstants.labelWhatsapp, whatsapp),
                _contactLine(AppConstants.labelGps, gps),
                const SizedBox(height: 8),
                const Text(
                  AppConstants.labelThanks,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: _body, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 4),
                const Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    AppConstants.poweredBy,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _body,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.2,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dash() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        width: double.infinity,
        height: 2,
        child: CustomPaint(painter: _ReceiptDashPainter()),
      ),
    );
  }

  Widget _kv(String label, String value) {
    const bold = TextStyle(fontWeight: FontWeight.w900);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(label, style: bold),
          const SizedBox(width: 8),
          Expanded(
            child: Directionality(
              textDirection: _isLatin(value)
                  ? TextDirection.ltr
                  : TextDirection.rtl,
              child: Text(value, textAlign: TextAlign.left, style: bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w400)),
          const Text(' : '),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stackedCenter(
    String label,
    String value, {
    double? valueSize,
    bool valueBold = false,
    bool labelBold = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: labelBold ? FontWeight.w900 : FontWeight.w400,
            ),
          ),
          Directionality(
            textDirection: _isLatin(value)
                ? TextDirection.ltr
                : TextDirection.rtl,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: valueSize ?? _body,
                fontWeight: valueBold ? FontWeight.w900 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableRow(
    String name,
    String qty,
    String rate,
    String amount, {
    bool header = false,
  }) {
    final style = TextStyle(
      fontWeight: header ? FontWeight.w900 : FontWeight.w400,
      fontSize: _table,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(name, style: style)),
          Expanded(
            child: Text(qty, textAlign: TextAlign.center, style: style),
          ),
          Expanded(
            child: Text(rate, textAlign: TextAlign.center, style: style),
          ),
          Expanded(
            child: Text(amount, textAlign: TextAlign.left, style: style),
          ),
        ],
      ),
    );
  }

  Widget _summary(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w900 : FontWeight.w400,
      fontSize: _summarySize,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: style),
          const Spacer(),
          Text(value, style: style),
        ],
      ),
    );
  }

  bool _isLatin(String value) {
    final trimmed = value.trim();
    return trimmed.isNotEmpty && RegExp(r'^[\x00-\x7F]+$').hasMatch(trimmed);
  }
}

class _ReceiptDashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.4;
    const dash = 5.0;
    const gap = 3.0;
    var x = 0.0;
    final y = size.height / 2;
    while (x < size.width) {
      final end = (x + dash).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
