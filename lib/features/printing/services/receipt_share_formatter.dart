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
      ..writeln('${AppConstants.labelDivision}: ${cityDistrict ?? '-'}')
      ..writeln('${AppConstants.labelMarket}: ${receipt.marketNameSnapshot}')
      ..writeln(
        '${AppConstants.labelContractor}: ${receipt.contractorName?.trim().isNotEmpty == true ? receipt.contractorName : '-'}',
      )
      ..writeln('${AppConstants.labelOperator}: ${receipt.receiverName}')
      ..writeln('${AppConstants.labelReceiptNo} ${receipt.receiptNumber}')
      ..writeln(
        '${AppConstants.labelDateTime} ${DateFormatter.receiptPrintDateTime(receipt.createdAt)}',
      )
      ..writeln(AppConstants.receiptDashLine)
      ..writeln(AppConstants.labelFeeReceipt);
    for (final item in receipt.lineItems) {
      buffer.writeln(
        '${item.feeTypeName}  ${CurrencyFormatter.receipt(item.quantity)}  ${CurrencyFormatter.receipt(item.unitRate)}  ${CurrencyFormatter.receipt(item.amount)}',
      );
    }
    buffer
      ..writeln(
        'PST(${CurrencyFormatter.receipt(receipt.taxPercent)}%)  ${CurrencyFormatter.receipt(receipt.taxAmount)}',
      )
      ..writeln('${AppConstants.labelTotal}  ${CurrencyFormatter.receipt(receipt.totalAmount)}')
      ..writeln('${AppConstants.labelIssuedBy} ${receipt.receiverName}')
      ..writeln(receipt.isPaid ? AppConstants.labelPaid : AppConstants.labelUnpaid)
      ..writeln('${AppConstants.labelHelpline} : ${AppConstants.helplineNumber}')
      ..writeln('${AppConstants.labelWhatsapp} : $whatsapp')
      ..writeln('${AppConstants.labelGps} : $gps')
      ..writeln(AppConstants.labelThanks)
      ..writeln(AppConstants.poweredBy);
    return buffer.toString();
  }
}