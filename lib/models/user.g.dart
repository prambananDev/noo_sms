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
      id: fields[0] as int,
      username: fields[1] as String,
      password: fields[2] as String?,
      fullname: fields[3] as String,
      level: fields[4] as String,
      roles: fields[5] as String,
      approvalRoles: fields[6] as String?,
      brand: fields[7] as String?,
      custSegment: fields[8] as String?,
      businessUnit: fields[9] as String?,
      token: fields[10] as String?,
      message: fields[11] as String?,
      code: fields[12] as int?,
      user: fields[13] as User?,
      so: fields[14] as dynamic,
      bu: fields[15] as String?,
      name: fields[16] as String?,
      role: fields[17] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.password)
      ..writeByte(3)
      ..write(obj.fullname)
      ..writeByte(4)
      ..write(obj.level)
      ..writeByte(5)
      ..write(obj.roles)
      ..writeByte(6)
      ..write(obj.approvalRoles)
      ..writeByte(7)
      ..write(obj.brand)
      ..writeByte(8)
      ..write(obj.custSegment)
      ..writeByte(9)
      ..write(obj.businessUnit)
      ..writeByte(10)
      ..write(obj.token)
      ..writeByte(11)
      ..write(obj.message)
      ..writeByte(12)
      ..write(obj.code)
      ..writeByte(13)
      ..write(obj.user)
      ..writeByte(14)
      ..write(obj.so)
      ..writeByte(15)
      ..write(obj.bu)
      ..writeByte(16)
      ..write(obj.name)
      ..writeByte(17)
      ..write(obj.role);
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
