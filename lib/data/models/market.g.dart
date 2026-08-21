// GENERATED CODE - DO NOT MODIFY BY HAND
// Hand-written TypeAdapter matching hive_generator 2.x output.
// hive_generator 2.0.1 cannot resolve against Dart 3.13 / analyzer 8.

part of 'market.dart';

class MarketAdapter extends TypeAdapter<Market> {
  @override
  final int typeId = 0;

  @override
  Market read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Market(
      id: fields[0] as String,
      name: fields[1] as String,
      cityDistrict: fields[2] as String,
      companyHeaderName: fields[3] as String,
      address: fields[4] as String?,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Market obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.cityDistrict)
      ..writeByte(3)
      ..write(obj.companyHeaderName)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
