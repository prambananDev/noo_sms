// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'noo_user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SCSUserAdapter extends TypeAdapter<SCSUser> {
  @override
  final int typeId = 2;

  @override
  SCSUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SCSUser(
      idEmp: fields[0] as String?,
      idSales: fields[1] as String?,
      name: fields[2] as String?,
      wh: fields[3] as String?,
      token: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SCSUser obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.idEmp)
      ..writeByte(1)
      ..write(obj.idSales)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.wh)
      ..writeByte(4)
      ..write(obj.token);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SCSUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
