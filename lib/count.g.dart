// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'count.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CountAdapter extends TypeAdapter<Count> {
  @override
  final int typeId = 1;

  @override
  Count read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Count(
      count: fields[0] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Count obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.count);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
