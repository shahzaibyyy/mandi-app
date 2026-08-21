import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/models/receipt.dart';
import '../../../data/models/receipt_line_item.dart';

class ReceiptPrintFormatter {
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
    final generator = Generator(paperSize, profile);
    final lineWidth = settings.paperWidthMm >= 80 ? 48 : 32;

    final bytes = <int>[];
    bytes.addAll(generator.reset());

    final header = (companyHeaderName != null && companyHeaderName.isNotEmpty)
        ? companyHeaderName
        : settings.companyHeaderName;

    bytes.addAll(
      generator.text(
        header,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
    );
    bytes.addAll(
      generator.text(
        'MARKET FEE RECEIPT',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
    );
    bytes.addAll(
      generator.text(
        'رسید انٹری فیس',
        styles: const PosStyles(align: PosAlign.center),
      ),
    );
    bytes.addAll(generator.hr(ch: '-'));

    bytes.addAll(_kv(generator, 'Mandi / منڈی', receipt.marketNameSnapshot));
    if (marketCityDistrict != null && marketCityDistrict.isNotEmpty) {
      bytes.addAll(
        _kv(generator, 'City/District / ضلع', marketCityDistrict),
      );
    }
    bytes.addAll(_kv(generator, 'Receiver / وصول کنندہ', receipt.receiverName));
    if (receipt.contractorName != null &&
        receipt.contractorName!.trim().isNotEmpty) {
      bytes.addAll(
        _kv(generator, 'Contractor / ٹھیکیدار', receipt.contractorName!.trim()),
      );
    }
    bytes.addAll(_kv(generator, 'Receipt No / رسید نمبر', receipt.receiptNumber));
    bytes.addAll(
      _kv(
        generator,
        'Date / تاریخ',
        DateFormatter.receiptDateTime(receipt.createdAt),
      ),
    );

    bytes.addAll(generator.hr(ch: '-'));
    bytes.addAll(_tableHeader(generator, lineWidth));
    bytes.addAll(generator.hr(ch: '-'));

    for (final item in receipt.lineItems) {
      bytes.addAll(_itemRow(generator, lineWidth, item));
    }

    bytes.addAll(generator.hr(ch: '-'));
    bytes.addAll(
      _kv(
        generator,
        'Subtotal / مجموعہ',
        CurrencyFormatter.format(receipt.subtotal),
      ),
    );
    bytes.addAll(
      _kv(
        generator,
        'PST ${CurrencyFormatter.plain(receipt.taxPercent)}%',
        CurrencyFormatter.format(receipt.taxAmount),
      ),
    );
    bytes.addAll(
      generator.text(
        _twoCol(
          lineWidth,
          'TOTAL / کل رقم',
          CurrencyFormatter.format(receipt.totalAmount),
        ),
        styles: const PosStyles(bold: true),
      ),
    );
    bytes.addAll(
      generator.text(
        'Status / حیثیت: ${receipt.isPaid ? 'PAID / ادا شدہ' : 'UNPAID / غیر ادا'}',
        styles: PosStyles(
          bold: true,
          align: PosAlign.center,
        ),
      ),
    );
    bytes.addAll(generator.hr(ch: '-'));

    final phone = settings.whatsappNumber?.trim();
    if (phone != null && phone.isNotEmpty) {
      bytes.addAll(_kv(generator, 'Phone/WhatsApp', phone));
    }

    if (receipt.latitude != null && receipt.longitude != null) {
      bytes.addAll(
        _kv(
          generator,
          'GPS',
          '${receipt.latitude!.toStringAsFixed(6)}, ${receipt.longitude!.toStringAsFixed(6)}',
        ),
      );
    }

    bytes.addAll(
      generator.text(
        '${AppConstants.appName} v${AppConstants.appVersion}',
        styles: const PosStyles(align: PosAlign.center),
      ),
    );
    bytes.addAll(generator.feed(2));
    bytes.addAll(generator.cut());
    return bytes;
  }

  List<int> _kv(Generator generator, String key, String value) {
    return generator.text('$key: $value');
  }

  List<int> _tableHeader(Generator generator, int lineWidth) {
    return generator.text(
      _columns(lineWidth, 'Item/آئٹم', 'Qty', 'Rate', 'Amt'),
      styles: const PosStyles(bold: true),
    );
  }

  List<int> _itemRow(
    Generator generator,
    int lineWidth,
    ReceiptLineItem item,
  ) {
    return generator.text(
      _columns(
        lineWidth,
        item.feeTypeName,
        CurrencyFormatter.plain(item.quantity),
        CurrencyFormatter.plain(item.unitRate),
        CurrencyFormatter.plain(item.amount),
      ),
    );
  }

  String _columns(
    int lineWidth,
    String name,
    String qty,
    String rate,
    String amt,
  ) {
    final qtyW = lineWidth >= 48 ? 8 : 5;
    final rateW = lineWidth >= 48 ? 10 : 8;
    final amtW = lineWidth >= 48 ? 10 : 8;
    final nameW = lineWidth - qtyW - rateW - amtW;
    return '${_fit(name, nameW)}${_fit(qty, qtyW, right: true)}${_fit(rate, rateW, right: true)}${_fit(amt, amtW, right: true)}';
  }

  String _twoCol(int lineWidth, String left, String right) {
    final rightW = right.length;
    final leftW = lineWidth - rightW;
    return '${_fit(left, leftW)}$right';
  }

  String _fit(String value, int width, {bool right = false}) {
    if (width <= 0) return '';
    if (value.length > width) {
      return value.substring(0, width);
    }
    return right ? value.padLeft(width) : value.padRight(width);
  }
}