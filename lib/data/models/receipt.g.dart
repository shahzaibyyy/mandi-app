// GENERATED CODE - DO NOT MODIFY BY HAND
// Hand-written TypeAdapter matching hive_generator 2.x output.

part of 'receipt.dart';

class ReceiptAdapter extends TypeAdapter<Receipt> {
  @override
  final int typeId = 3;

  @override
  Receipt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Receipt(
      id: fields[0] as String,
      receiptNumber: fields[1] as String,
      marketId: fields[2] as String,
      marketNameSnapshot: fields[3] as String,
      receiverName: fields[4] as String,
      contractorName: fields[5] as String?,
      lineItems: (fields[6] as List).cast<ReceiptLineItem>(),
      subtotal: fields[7] as double,
      taxPercent: fields[8] as double,
      taxAmount: fields[9] as double,
      totalAmount: fields[10] as double,
      isPaid: fields[11] as bool,
      latitude: fields[12] as double?,
      longitude: fields[13] as double?,
      createdAt: fields[14] as DateTime,
      printCount: fields[15] as int,
      lastPrintedAt: fields[16] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Receipt obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.receiptNumber)
      ..writeByte(2)
      ..write(obj.marketId)
      ..writeByte(3)
      ..write(obj.marketNameSnapshot)
      ..writeByte(4)
      ..write(obj.receiverName)
      ..writeByte(5)
      ..write(obj.contractorName)
      ..writeByte(6)
      ..write(obj.lineItems)
      ..writeByte(7)
      ..write(obj.subtotal)
      ..writeByte(8)
      ..write(obj.taxPercent)
      ..writeByte(9)
      ..write(obj.taxAmount)
      ..writeByte(10)
      ..write(obj.totalAmount)
      ..writeByte(11)
      ..write(obj.isPaid)
      ..writeByte(12)
      ..write(obj.latitude)
      ..writeByte(13)
      ..write(obj.longitude)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.printCount)
      ..writeByte(16)
      ..write(obj.lastPrintedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceiptAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
