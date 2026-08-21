import 'package:hive/hive.dart';

part 'receipt_line_item.g.dart';

@HiveType(typeId: 2)
class ReceiptLineItem extends HiveObject {
  ReceiptLineItem({
    this.feeTypeId,
    required this.feeTypeName,
    required this.unitLabel,
    required this.quantity,
    required this.unitRate,
    required this.amount,
  });

  @HiveField(0)
  String? feeTypeId;

  @HiveField(1)
  String feeTypeName;

  @HiveField(2)
  String unitLabel;

  @HiveField(3)
  double quantity;

  @HiveField(4)
  double unitRate;

  @HiveField(5)
  double amount;
}