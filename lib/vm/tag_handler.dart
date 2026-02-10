// tag_handler.dart
// Tag Hive Box CRUD

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tagdo/model/tag.dart';
/// 기본 태그 (이름, 색상)
const List<(String, Color)> _defaults = [
  ('업무', Colors.red),
  ('개인', Colors.amber),
  ('공부', Colors.purpleAccent),
  ('취미', Colors.lightBlue),
  ('건강', Colors.blue),
  ('쇼핑', Colors.deepOrange),
  ('가족', Colors.pink),
  ('금융', Colors.teal),
  ('이동', Colors.indigoAccent),
  ('기타', Colors.green),
];

/// TagHandler - Tag Box CRUD
class TagHandler {
  static const String _boxName = 'tag';

  Box<Tag> _getBox() => Hive.box<Tag>(_boxName);

  /// 전체 태그 조회. 비어 있으면 기본 태그 생성 후 반환
  Future<List<Tag>> loadAll() async {
    final box = _getBox();
    if (box.isEmpty) {
      await _initDefaults();
    }
    final list = box.values.toList();
    list.sort((a, b) => a.id.compareTo(b.id));
    return list;
  }

  /// 태그 저장 (신규 생성 / 수정 공용)
  Future<void> saveTag(Tag tag) async {
    await _getBox().put('${tag.id}', tag);
  }

  /// 태그 삭제
  Future<void> deleteTag(int id) async {
    await _getBox().delete('$id');
  }

  /// 다음 사용 가능한 ID 반환
  int nextId() {
    final box = _getBox();
    if (box.isEmpty) return 0;
    final maxId = box.values.map((t) => t.id).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  /// Box 비어 있을 때 기본 태그 생성
  Future<void> _initDefaults() async {
    final box = _getBox();
    for (var i = 0; i < _defaults.length; i++) {
      final (name, color) = _defaults[i];
      await box.put(
        '$i',
        Tag(id: i, name: name, colorValue: color.toARGB32()),
      );
    }
  }

  /// id로 태그 조회 헬퍼
  static Tag? tagOf(List<Tag> tags, int id) {
    return tags.where((e) => e.id == id).firstOrNull;
  }

  /// id로 태그 이름 조회. 없으면 "태그 N" 반환
  static String nameOf(List<Tag> tags, int id) {
    return tagOf(tags, id)?.name ?? '태그 $id';
  }

  /// id로 태그 색상 조회. 없으면 회색 반환
  static Color colorOf(List<Tag> tags, int id) {
    return tagOf(tags, id)?.color ?? Colors.grey;
  }
}
