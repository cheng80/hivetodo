/// ============================================================================
/// [model/todo.g.dart] - Hive TypeAdapter 자동 생성 파일
/// ============================================================================
/// build_runner에 의해 자동 생성됩니다.
/// 명령어: flutter packages pub run build_runner build
///
/// [역할]
/// Todo 객체를 Hive의 바이너리 형식으로 직렬화(write)하고,
/// 바이너리 데이터를 다시 Todo 객체로 역직렬화(read)합니다.
///
/// [주의] 이 파일을 수동으로 수정하면 안 됩니다!
/// ============================================================================

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

/// TodoAdapter - Todo 객체의 직렬화/역직렬화 담당
class TodoAdapter extends TypeAdapter<Todo> {
  /// typeId: 1 → @HiveType(typeId: 1)과 동일
  @override
  final int typeId = 1;

  /// 바이너리 → Todo 객체 (역직렬화)
  @override
  Todo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Todo(
      no: fields[0] as int,
      content: fields[1] as String,
      tag: fields[2] as int,
      isCheck: fields[3] as bool,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
    );
  }

  /// Todo 객체 → 바이너리 (직렬화)
  @override
  void write(BinaryWriter writer, Todo obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.no)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.tag)
      ..writeByte(3)
      ..write(obj.isCheck)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
