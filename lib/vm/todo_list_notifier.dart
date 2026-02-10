// todo_list_notifier.dart
// Todo 목록 Riverpod Notifier

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tagdo/model/todo.dart';
import 'package:tagdo/vm/database_handler.dart';

/// TodoListNotifier - Riverpod AsyncNotifier 기반 ViewModel
///
/// Todo 목록을 비동기로 관리합니다.
/// state는 AsyncValue<List<Todo>>로, 로딩/데이터/에러 3가지 상태를 포함합니다.
class TodoListNotifier extends AsyncNotifier<List<Todo>> {
  final DatabaseHandler _dbHandler = DatabaseHandler();

  @override
  Future<List<Todo>> build() async {
    return await _dbHandler.queryTodos();
  }

  /// 새 Todo 생성 (맨 아래에 배치)
  Future<void> insertTodo(Todo todo) async {
    final order = _dbHandler.nextSortOrder();
    await _dbHandler.insertTodo(todo.copyWith(sortOrder: order));
    ref.invalidateSelf();
  }

  /// Todo 수정
  Future<void> updateTodo(Todo todo) async {
    await _dbHandler.updateTodo(todo);
    ref.invalidateSelf();
  }

  /// 완료 상태 토글
  Future<void> toggleCheck(Todo todo) async {
    await _dbHandler.toggleCheck(todo);
    ref.invalidateSelf();
  }

  /// Todo 삭제
  Future<void> deleteTodo(int no) async {
    await _dbHandler.deleteTodo(no);
    ref.invalidateSelf();
  }

  /// 완료 항목 일괄 삭제
  Future<void> deleteCheckedTodos() async {
    await _dbHandler.deleteCheckedTodos();
    ref.invalidateSelf();
  }

  /// 전체 삭제
  Future<void> deleteAllTodos() async {
    await _dbHandler.deleteAllTodos();
    ref.invalidateSelf();
  }

  /// 드래그 앤 드롭 순서 변경
  Future<void> reorder(int oldIndex, int newIndex) async {
    final todos = state.value;
    if (todos == null) return;

    final list = [...todos];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    /// UI 즉시 반영 (낙관적 업데이트)
    state = AsyncData(list);

    /// DB에 새 순서 저장
    await _dbHandler.reorder(list);
  }

  /// 수동 새로고침
  void reloadData() {
    ref.invalidateSelf();
  }

  /// 태그/검색어/완료 상태로 필터링
  Future<void> filterTodos({int? tag, String? keyword, bool? isCheck}) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      return await _dbHandler.queryTodosFiltered(
        tag: tag,
        keyword: keyword,
        isCheck: isCheck,
      );
    });
    state = result;
  }
}

/// Todo 목록 Provider
final todoListProvider =
    AsyncNotifierProvider<TodoListNotifier, List<Todo>>(TodoListNotifier.new);
