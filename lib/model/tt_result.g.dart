// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tt_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TTResultAdapter extends TypeAdapter<TTResult> {
  @override
  final int typeId = 0;

  @override
  TTResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TTResult()
      ..video = fields[0] as String?
      ..bgm = fields[1] as String?
      ..title = fields[2] as String?
      ..img = fields[3] as String?
      ..name = fields[4] as String?
      ..avatar = fields[5] as String?;
  }

  @override
  void write(BinaryWriter writer, TTResult obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.video)
      ..writeByte(1)
      ..write(obj.bgm)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.img)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.avatar);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TTResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
