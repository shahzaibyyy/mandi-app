// GENERATED CODE - DO NOT MODIFY BY HAND
// Hand-written TypeAdapter matching hive_generator 2.x output.

part of 'app_settings.dart';

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 4;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      companyHeaderName: fields[0] as String,
      defaultMarketId: fields[1] as String?,
      defaultTaxPercent: fields[2] as double,
      receiptNumberPrefix: fields[3] as String,
      lastReceiptSequence: fields[4] as int,
      printerMacAddress: fields[5] as String?,
      printerName: fields[6] as String?,
      paperWidthMm: fields[7] as int,
      whatsappNumber: fields[8] as String?,
      defaultReceiverName: fields[9] as String?,
      isLoggedIn: fields[10] as bool? ?? false,
      boundDeviceId: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.companyHeaderName)
      ..writeByte(1)
      ..write(obj.defaultMarketId)
      ..writeByte(2)
      ..write(obj.defaultTaxPercent)
      ..writeByte(3)
      ..write(obj.receiptNumberPrefix)
      ..writeByte(4)
      ..write(obj.lastReceiptSequence)
      ..writeByte(5)
      ..write(obj.printerMacAddress)
      ..writeByte(6)
      ..write(obj.printerName)
      ..writeByte(7)
      ..write(obj.paperWidthMm)
      ..writeByte(8)
      ..write(obj.whatsappNumber)
      ..writeByte(9)
      ..write(obj.defaultReceiverName)
      ..writeByte(10)
      ..write(obj.isLoggedIn)
      ..writeByte(11)
      ..write(obj.boundDeviceId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
