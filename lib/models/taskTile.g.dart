// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taskTile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class taskTileAdapter extends TypeAdapter<taskTile> {
  @override
  final int typeId = 0;

  @override
  taskTile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return taskTile(
      title: fields[0] as String?,
      description: fields[1] as String?,
      status: fields[2] as String?,
      datetime: fields[3] as String?,
      id: fields[4] as String?,
      imagePath: fields[5] as String?,
      blockedBy: (fields[7] as List?)?.cast<taskTile>(),
      parentTasks: (fields[8] as List?)?.cast<taskTile>(),
      minorTasks: (fields[9] as List?)?.cast<taskTile>(),
      urgentTasks: (fields[10] as List?)?.cast<taskTile>(),
      miscTasks: (fields[11] as List?)?.cast<taskTile>(),
    )..isVisible = fields[6] as bool;
  }

  @override
  void write(BinaryWriter writer, taskTile obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.datetime)
      ..writeByte(4)
      ..write(obj.id)
      ..writeByte(5)
      ..write(obj.imagePath)
      ..writeByte(6)
      ..write(obj.isVisible)
      ..writeByte(7)
      ..write(obj.blockedBy)
      ..writeByte(8)
      ..write(obj.parentTasks)
      ..writeByte(9)
      ..write(obj.minorTasks)
      ..writeByte(10)
      ..write(obj.urgentTasks)
      ..writeByte(11)
      ..write(obj.miscTasks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is taskTileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
