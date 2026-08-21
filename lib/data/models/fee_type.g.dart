// GENERATED CODE - DO NOT MODIFY BY HAND
// Hand-written TypeAdapter matching hive_generator 2.x output.

part of 'fee_type.dart';

class FeeTypeAdapter extends TypeAdapter<FeeType> {
  @override
  final int typeId = 1;

  @override
  FeeType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FeeType(
      id: fields[0] as String,
      marketId: fields[1] as String?,
      name: fields[2] as String,
      unitLabel: fields[3] as String,
      defaultRate: fields[4] as double,
      isActive: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FeeType obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.marketId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.unitLabel)
      ..writeByte(4)
      ..write(obj.defaultRate)
      ..writeByte(5)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
