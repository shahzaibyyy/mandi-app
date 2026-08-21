import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/models/receipt.dart';

class ReceiptShareFormatter {
  ReceiptShareFormatter._();

  static String toText({
    required Receipt receipt,
    required AppSettings settings,
    String? cityDistrict,
  }) {
    final buffer = StringBuffer()
      ..writeln(settings.companyHeaderName)
      ..writeln('MARKET FEE RECEIPT')
      ..writeln('Mandi: ${receipt.marketNameSnapshot}');
    if (cityDistrict != null && cityDistrict.isNotEmpty) {
      buffer.writeln('City/District: $cityDistrict');
    }
    buffer.writeln('Receiver: ${receipt.receiverName}');
    if (receipt.contractorName != null &&
        receipt.contractorName!.trim().isNotEmpty) {
      buffer.writeln('Contractor: ${receipt.contractorName}');
    }
    buffer
      ..writeln('Receipt No: ${receipt.receiptNumber}')
      ..writeln('Date: ${DateFormatter.receiptDateTime(receipt.createdAt)}')
      ..writeln('---');
    for (final item in receipt.lineItems) {
      buffer.writeln(
        '${item.feeTypeName}  ${CurrencyFormatter.plain(item.quantity)} x ${CurrencyFormatter.format(item.unitRate)} = ${CurrencyFormatter.format(item.amount)}',
      );
    }
    buffer
      ..writeln('Subtotal: ${CurrencyFormatter.format(receipt.subtotal)}')
      ..writeln(
        'PST ${CurrencyFormatter.plain(receipt.taxPercent)}%: ${CurrencyFormatter.format(receipt.taxAmount)}',
      )
      ..writeln('TOTAL: ${CurrencyFormatter.format(receipt.totalAmount)}')
      ..writeln('Status: ${receipt.isPaid ? 'PAID' : 'UNPAID'}');
    final phone = settings.whatsappNumber?.trim();
    if (phone != null && phone.isNotEmpty) {
      buffer.writeln('Phone/WhatsApp: $phone');
    }
    if (receipt.latitude != null && receipt.longitude != null) {
      buffer.writeln(
        'GPS: ${receipt.latitude!.toStringAsFixed(6)}, ${receipt.longitude!.toStringAsFixed(6)}',
      );
    }
    buffer.writeln('${AppConstants.appName} v${AppConstants.appVersion}');
    return buffer.toString();
  }
}