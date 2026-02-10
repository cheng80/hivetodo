// database_handler.dart
// 핵심 기능만 간단히 요약


import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_hive_sample/model/todo.dart';

/// DatabaseHandler - Hive Box를 통한 Todo CRUD 연산을 담당하는 클래스
///
/// [사용법]
/// ```dart
/// final handler = DatabaseHandler();
/// List<Todo> todos = await handler.queryTodos();        // 전체 조회
/// await handler.insertTodo(newTodo);                     // 생성
/// await handler.updateTodo(updatedTodo);                 // 수정
/// await handler.deleteTodo(todo.no);                     // 단일 삭제
/// await handler.deleteAllTodos();                        // 전체 삭제
/// ```
class DatabaseHandler {
  /// Hive Box 이름 상수 - main.dart에서 열 때 사용한 이름과 동일해야 합니다.
  static const String _boxName = "todo";

  /// [_getBox] - 이미 열려있는 Hive Box의 참조를 반환합니다.
  /// main.dart에서 앱 시작 시 Hive.openBox for Todo로 이미 열어두었으므로
  /// 여기서는 Hive.box for Todo로 참조만 가져옵니다.
  Box<Todo> _getBox() {
    return Hive.box<Todo>(_boxName);
  }

  /// [queryTodos] - 전체 Todo 목록을 조회합니다.
  ///
  /// Hive Box의 모든 값을 가져온 후 정렬하여 반환합니다.
  /// 정렬 규칙: 미완료(위) → 완료(아래), 각각 수정일 내림차순
  ///
  /// [반환값] 정렬된 Todo 리스트
  Future<List<Todo>> queryTodos() async {
    return await queryTodosFiltered();
  }

  /// [queryTodosByTag] - 특정 tag만 필터링하여 조회합니다.
  ///
  /// [매개변수] tag: Todo.tag 값 (0~9)
  /// [반환값] 정렬된 Todo 리스트
  Future<List<Todo>> queryTodosByTag(int tag) async {
    return await queryTodosFiltered(tag: tag);
  }

  /// [queryTodosFiltered] - tag/keyword 조건으로 필터링하여 조회합니다.
  ///
  /// [매개변수]
  /// - tag: null이면 태그 필터 미적용
  /// - keyword: null/빈값이면 검색 미적용
  Future<List<Todo>> queryTodosFiltered({
    int? tag,
    String? keyword,
  }) async {
    final box = _getBox();
    Iterable<Todo> todos = box.values;

    if (tag != null) {
      todos = todos.where((e) => e.tag == tag);
    }

    final query = keyword?.trim().toLowerCase();
    if (query != null && query.isNotEmpty) {
      todos = todos.where((e) => e.content.toLowerCase().contains(query));
    }

    final list = todos.toList();
    final unchecked = list.where((e) => !e.isCheck).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final checked = list.where((e) => e.isCheck).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return [...unchecked, ...checked];
  }

  /// [insertTodo] - 새로운 Todo를 Hive Box에 저장합니다.
  ///
  /// [매개변수] todo: 저장할 Todo 객체
  /// key는 todo.no를 문자열로 변환하여 사용합니다.
  /// todo.no는 밀리초 타임스탬프이므로 유니크합니다.
  Future<void> insertTodo(Todo todo) async {
    final box = _getBox();
    await box.put("${todo.no}", todo);
    print("[DatabaseHandler] insertTodo: no=${todo.no}, content=${todo.content}");
  }

  /// [updateTodo] - 기존 Todo를 수정합니다.
  ///
  /// Hive의 put()은 key가 이미 존재하면 덮어쓰기(upsert) 동작을 합니다.
  /// 따라서 insert와 동일한 메서드를 사용하지만, 의미적으로 분리했습니다.
  ///
  /// [매개변수] todo: 수정된 Todo 객체 (no는 기존 값 유지)
  Future<void> updateTodo(Todo todo) async {
    final box = _getBox();
    await box.put("${todo.no}", todo);
    print("[DatabaseHandler] updateTodo: no=${todo.no}, content=${todo.content}");
  }

  /// [toggleCheck] - Todo의 완료 상태를 토글합니다.
  ///
  /// [매개변수] todo: 원본 Todo 객체
  /// [반환값] isCheck가 반전된 새 Todo 객체
  ///
  /// copyWith를 사용하여 불변 객체의 isCheck만 토글하고,
  /// updatedAt을 현재 시간으로 갱신합니다.
  Future<Todo> toggleCheck(Todo todo) async {
    final box = _getBox();
    final updated = todo.copyWith(
      isCheck: !todo.isCheck,
      updatedAt: DateTime.now(),
    );
    await box.put("${updated.no}", updated);
    print("[DatabaseHandler] toggleCheck: no=${updated.no}, isCheck=${updated.isCheck}");
    return updated;
  }

  /// [deleteTodo] - 특정 Todo를 삭제합니다.
  ///
  /// [매개변수] no: 삭제할 Todo의 고유 번호
  Future<void> deleteTodo(int no) async {
    final box = _getBox();
    await box.delete("$no");
    print("[DatabaseHandler] deleteTodo: no=$no");
  }

  /// [deleteAllTodos] - 모든 Todo를 삭제합니다.
  ///
  /// Hive Box의 clear()를 호출하여 모든 데이터를 제거합니다.
  Future<void> deleteAllTodos() async {
    final box = _getBox();
    await box.clear();
    print("[DatabaseHandler] deleteAllTodos: Box cleared");
  }
}
