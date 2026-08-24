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

  static const _body = 13.5;
  static const _company = 15.5;
  static const _table = 12.5;
  static const _issuedName = 18.5;
  static const _paid = 24.5;

  @override
  Widget build(BuildContext context) {
    final company = (companyHeaderName != null && companyHeaderName!.isNotEmpty)
        ? companyHeaderName!
        : settings.companyHeaderName;
    final whatsapp = (settings.whatsappNumber?.trim().isNotEmpty == true)
        ? settings.whatsappNumber!.trim()
        : AppConstants.defaultWhatsappNumber;
    final gps = (receipt.latitude != null && receipt.longitude != null)
        ? '${receipt.latitude!.toStringAsFixed(6)}, ${receipt.longitude!.toStringAsFixed(6)}'
        : '-';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontSize: _body, height: 1.25),
            child: Column(
              children: [
                Image.asset(AppConstants.logoAsset, width: 96),
                const SizedBox(height: 8),
                Text(
                  company,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
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
                _dash(),
                _stackedCenter(AppConstants.labelReceiptNo, receipt.receiptNumber),
                const SizedBox(height: 6),
                _stackedCenter(
                  AppConstants.labelDateTime,
                  DateFormatter.receiptPrintDateTime(receipt.createdAt),
                ),
                _dash(),
                const Text(
                  AppConstants.labelFeeReceipt,
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                _tableRow('فیس کی قسم', 'تعداد', 'یونٹ', 'قیمت', header: true),
                _dash(),
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
                ),
                _summary(
                  AppConstants.labelTotal,
                  CurrencyFormatter.receipt(receipt.totalAmount),
                  bold: true,
                ),
                _dash(),
                _stackedCenter(
                  AppConstants.labelIssuedBy,
                  receipt.receiverName,
                  valueSize: _issuedName,
                  valueBold: true,
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
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const Text(AppConstants.poweredBy),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dash() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Text(AppConstants.receiptDashLine),
    );
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(label),
          const SizedBox(width: 8),
          Expanded(
            child: Directionality(
              textDirection: _isLatin(value)
                  ? TextDirection.ltr
                  : TextDirection.rtl,
              child: Text(value, textAlign: TextAlign.left),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const Text(' : '),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(value),
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
  }) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Text(label, textAlign: TextAlign.center),
          Directionality(
            textDirection: _isLatin(value)
                ? TextDirection.ltr
                : TextDirection.rtl,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: valueSize ?? _body,
                fontWeight: valueBold ? FontWeight.w900 : FontWeight.w500,
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
      fontWeight: header ? FontWeight.w800 : FontWeight.w500,
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
      fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
      fontSize: 14.5,
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
