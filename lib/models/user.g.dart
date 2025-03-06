// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as int?,
      username: fields[1] as String?,
      Username: fields[2] as String?,
      password: fields[3] as String?,
      fullname: fields[4] as String?,
      token: fields[5] as String?,
      message: fields[6] as String?,
      code: fields[7] as int?,
      so: fields[8] as dynamic,
      bu: fields[9] as String?,
      SO: fields[10] as dynamic,
      BU: fields[11] as String?,
      role: fields[12] as String?,
      editApproval: fields[13] as int?,
      approvalRole: fields[14] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.Username)
      ..writeByte(3)
      ..write(obj.password)
      ..writeByte(4)
      ..write(obj.fullname)
      ..writeByte(5)
      ..write(obj.token)
      ..writeByte(6)
      ..write(obj.message)
      ..writeByte(7)
      ..write(obj.code)
      ..writeByte(8)
      ..write(obj.so)
      ..writeByte(9)
      ..write(obj.bu)
      ..writeByte(10)
      ..write(obj.SO)
      ..writeByte(11)
      ..write(obj.BU)
      ..writeByte(12)
      ..write(obj.role)
      ..writeByte(13)
      ..write(obj.editApproval)
      ..writeByte(14)
      ..write(obj.approvalRole);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
