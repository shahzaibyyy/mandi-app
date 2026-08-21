import 'package:hive/hive.dart';

import 'receipt_line_item.dart';

part 'receipt.g.dart';

@HiveType(typeId: 3)
class Receipt extends HiveObject {
  Receipt({
    required this.id,
    required this.receiptNumber,
    required this.marketId,
    required this.marketNameSnapshot,
    required this.receiverName,
    this.contractorName,
    required this.lineItems,
    required this.subtotal,
    required this.taxPercent,
    required this.taxAmount,
    required this.totalAmount,
    required this.isPaid,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.printCount = 0,
    this.lastPrintedAt,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String receiptNumber;

  @HiveField(2)
  String marketId;

  @HiveField(3)
  String marketNameSnapshot;

  @HiveField(4)
  String receiverName;

  @HiveField(5)
  String? contractorName;

  @HiveField(6)
  List<ReceiptLineItem> lineItems;

  @HiveField(7)
  double subtotal;

  @HiveField(8)
  double taxPercent;

  @HiveField(9)
  double taxAmount;

  @HiveField(10)
  double totalAmount;

  @HiveField(11)
  bool isPaid;

  @HiveField(12)
  double? latitude;

  @HiveField(13)
  double? longitude;

  @HiveField(14)
  DateTime createdAt;

  @HiveField(15)
  int printCount;

  @HiveField(16)
  DateTime? lastPrintedAt;
}