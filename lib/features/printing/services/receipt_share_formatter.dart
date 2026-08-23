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
    final whatsapp = (settings.whatsappNumber?.trim().isNotEmpty == true)
        ? settings.whatsappNumber!.trim()
        : AppConstants.defaultWhatsappNumber;
    final gps = (receipt.latitude != null && receipt.longitude != null)
        ? '${receipt.latitude!.toStringAsFixed(6)}, ${receipt.longitude!.toStringAsFixed(6)}'
        : '-';
    final buffer = StringBuffer()
      ..writeln(settings.companyHeaderName)
      ..writeln('ٹاؤن: ${cityDistrict ?? '-'}')
      ..writeln('مارکیٹ: ${receipt.marketNameSnapshot}')
      ..writeln(
        'نام ٹھیکیدار: ${receipt.contractorName?.trim().isNotEmpty == true ? receipt.contractorName : '-'}',
      )
      ..writeln('نام آپریٹر: ${receipt.receiverName}')
      ..writeln('رسید نمبر ${receipt.receiptNumber}')
      ..writeln(
        'تاریخ و وقت ${DateFormatter.receiptPrintDateTime(receipt.createdAt)}',
      )
      ..writeln('----------------')
      ..writeln('فیس رسید');
    for (final item in receipt.lineItems) {
      buffer.writeln(
        '${item.feeTypeName}  ${CurrencyFormatter.receipt(item.quantity)}  ${CurrencyFormatter.receipt(item.unitRate)}  ${CurrencyFormatter.receipt(item.amount)}',
      );
    }
    buffer
      ..writeln(
        'PST(${CurrencyFormatter.receipt(receipt.taxPercent)}%)  ${CurrencyFormatter.receipt(receipt.taxAmount)}',
      )
      ..writeln('کل  ${CurrencyFormatter.receipt(receipt.totalAmount)}')
      ..writeln('جاری کردہ توسط ${receipt.receiverName}')
      ..writeln(receipt.isPaid ? 'ادا شدہ' : 'غیر ادا شدہ')
      ..writeln('ہیلپ لائن: ${AppConstants.helplineNumber}')
      ..writeln('واٹس ایپ: $whatsapp')
      ..writeln('GPS مقام: $gps')
      ..writeln('شکریہ')
      ..writeln(AppConstants.poweredBy);
    return buffer.toString();
  }
}