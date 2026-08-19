// GENERATED CODE - DO NOT MODIFY BY HAND
part of '\''work_day.dart'\'';

class WorkDayRecordAdapter extends TypeAdapter<WorkDayRecord> {
  @override
  final int typeId = 0;
  @override
  WorkDayRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return WorkDayRecord(
      id: fields[0] as String, date: fields[1] as DateTime, type: fields[2] as WorkDayType,
      price: fields[3] as double, note: fields[4] as String,
      createdAt: fields[5] as DateTime, updatedAt: fields[6] as DateTime,
    );
  }
  @override
  void write(BinaryWriter writer, WorkDayRecord obj) {
    writer..writeByte(7)..writeByte(0)..write(obj.id)..writeByte(1)..write(obj.date)
          ..writeByte(2)..write(obj.type.index)..writeByte(3)..write(obj.price)
          ..writeByte(4)..write(obj.note)..writeByte(5)..write(obj.createdAt)..writeByte(6)..write(obj.updatedAt);
  }
  @override
  int get hashCode => typeId.hashCode;
  @override
  bool operator ==(Object other) => identical(this, other) || other is WorkDayRecordAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class WorkDayTypeEnumAdapter extends TypeAdapter<WorkDayType> {
  @override
  final int typeId = 2;
  @override
  WorkDayType read(BinaryReader reader) => WorkDayType.values[reader.readByte()];
  @override
  void write(BinaryWriter writer, WorkDayType obj) => writer.writeByte(obj.index);
  @override
  int get hashCode => typeId.hashCode;
  @override
  bool operator ==(Object other) => identical(this, other) || other is WorkDayTypeEnumAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class PriceConfigAdapter extends TypeAdapter<PriceConfig> {
  @override
  final int typeId = 1;
  @override
  PriceConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return PriceConfig(
      whiteShiftPrice: fields[0] as double, overtimePrice: fields[1] as double,
      businessTripPrice: fields[2] as double, restPrice: fields[3] as double,
    );
  }
  @override
  void write(BinaryWriter writer, PriceConfig obj) {
    writer..writeByte(4)..writeByte(0)..write(obj.whiteShiftPrice)..writeByte(1)..write(obj.overtimePrice)
          ..writeByte(2)..write(obj.businessTripPrice)..writeByte(3)..write(obj.restPrice);
  }
  @override
  int get hashCode => typeId.hashCode;
  @override
  bool operator ==(Object other) => identical(this, other) || other is PriceConfigAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}