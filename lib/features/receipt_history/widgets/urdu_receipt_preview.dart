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
          child: Column(
            children: [
              Image.asset(AppConstants.logoAsset, width: 96),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: Text(
                  company,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _kv('ٹاؤن', cityDistrict ?? '-'),
              _kv('مارکیٹ', receipt.marketNameSnapshot),
              _kv(
                'نام ٹھیکیدار',
                receipt.contractorName?.trim().isNotEmpty == true
                    ? receipt.contractorName!
                    : '-',
              ),
              _kv('نام آپریٹر', receipt.receiverName),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('----------------'),
              ),
              _stackedCenter('رسید نمبر', receipt.receiptNumber),
              const SizedBox(height: 6),
              _stackedCenter(
                'تاریخ و وقت',
                DateFormatter.receiptPrintDateTime(receipt.createdAt),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('----------------'),
              ),
              const Text(
                'فیس رسید',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              _tableRow('فیس کی قسم', 'تعداد', 'یونٹ', 'قیمت', header: true),
              const Divider(color: Colors.black),
              for (final item in receipt.lineItems)
                _tableRow(
                  item.feeTypeName,
                  CurrencyFormatter.receipt(item.quantity),
                  CurrencyFormatter.receipt(item.unitRate),
                  CurrencyFormatter.receipt(item.amount),
                ),
              const Divider(color: Colors.black),
              _summary(
                'PST(${CurrencyFormatter.receipt(receipt.taxPercent)}%)',
                CurrencyFormatter.receipt(receipt.taxAmount),
              ),
              _summary(
                'کل',
                CurrencyFormatter.receipt(receipt.totalAmount),
                bold: true,
              ),
              const Text('----------------'),
              _stackedCenter('جاری کردہ توسط', receipt.receiverName),
              const SizedBox(height: 6),
              Text(
                receipt.isPaid ? 'ادا شدہ' : 'غیر ادا شدہ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: receipt.isPaid ? AppColors.paid : AppColors.unpaid,
                ),
              ),
              const SizedBox(height: 8),
              _kv('ہیلپ لائن', AppConstants.helplineNumber),
              _kv('واٹس ایپ', whatsapp),
              _kv('GPS مقام', gps),
              const SizedBox(height: 8),
              const Text(
                'شکریہ',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const Text(AppConstants.poweredBy),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(value, textAlign: TextAlign.left),
          ),
        ],
      ),
    );
  }

  Widget _stackedCenter(String label, String value) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Text(label, textAlign: TextAlign.center),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(value, textAlign: TextAlign.center),
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
      fontSize: 12,
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
}