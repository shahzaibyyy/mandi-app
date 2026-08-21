// GENERATED CODE - DO NOT MODIFY BY HAND
// Hand-written TypeAdapter matching hive_generator 2.x output.

part of 'receipt_line_item.dart';

class ReceiptLineItemAdapter extends TypeAdapter<ReceiptLineItem> {
  @override
  final int typeId = 2;

  @override
  ReceiptLineItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReceiptLineItem(
      feeTypeId: fields[0] as String?,
      feeTypeName: fields[1] as String,
      unitLabel: fields[2] as String,
      quantity: fields[3] as double,
      unitRate: fields[4] as double,
      amount: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ReceiptLineItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.feeTypeId)
      ..writeByte(1)
      ..write(obj.feeTypeName)
      ..writeByte(2)
      ..write(obj.unitLabel)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.unitRate)
      ..writeByte(5)
      ..write(obj.amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceiptLineItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
