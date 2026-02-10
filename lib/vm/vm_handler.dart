// vm_handler.dart
// 핵심 기능만 간단히 요약


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hive_sample/model/todo.dart';
import 'package:flutter_hive_sample/vm/database_handler.dart';

/// VMHandler - Riverpod AsyncNotifier 기반 ViewModel
///
/// AsyncNotifier( Todo 리스트 )를 상속하여 Todo 목록을 비동기로 관리합니다.
/// state는 AsyncValue( Todo 리스트 ) 타입으로, 로딩/데이터/에러 3가지 상태를 포함합니다.
class VMHandler extends AsyncNotifier<List<Todo>> {
  /// DatabaseHandler 인스턴스 - Hive CRUD 연산을 위임합니다.
  final DatabaseHandler _dbHandler = DatabaseHandler();

  /// [build] - Provider가 처음 생성될 때 호출됩니다.
  /// Hive Box에서 전체 Todo 목록을 로드하여 초기 상태로 설정합니다.
  ///
  /// ref.invalidateSelf() 호출 시에도 이 메서드가 다시 실행되어
  /// DB에서 최신 데이터를 다시 읽어옵니다 (자동 동기화).
  @override
  Future<List<Todo>> build() async {
    return await _dbHandler.queryTodos();
  }

  /// [insertTodo] - 새로운 Todo를 생성합니다.
  ///
  /// [매개변수] todo: 생성할 Todo 객체
  ///
  /// 1. DatabaseHandler를 통해 Hive에 저장
  /// 2. ref.invalidateSelf()로 상태 무효화 → build() 재실행 → UI 자동 갱신
  Future<void> insertTodo(Todo todo) async {
    await _dbHandler.insertTodo(todo);
    ref.invalidateSelf();
  }

  /// [updateTodo] - 기존 Todo를 수정합니다.
  ///
  /// [매개변수] todo: 수정된 Todo 객체
  Future<void> updateTodo(Todo todo) async {
    await _dbHandler.updateTodo(todo);
    ref.invalidateSelf();
  }

  /// [toggleCheck] - Todo의 완료 상태를 토글합니다.
  ///
  /// [매개변수] todo: 토글할 Todo 객체
  Future<void> toggleCheck(Todo todo) async {
    await _dbHandler.toggleCheck(todo);
    ref.invalidateSelf();
  }

  /// [deleteTodo] - 특정 Todo를 삭제합니다.
  ///
  /// [매개변수] no: 삭제할 Todo의 고유 번호
  Future<void> deleteTodo(int no) async {
    await _dbHandler.deleteTodo(no);
    ref.invalidateSelf();
  }

  /// [deleteAllTodos] - 모든 Todo를 삭제합니다.
  Future<void> deleteAllTodos() async {
    await _dbHandler.deleteAllTodos();
    ref.invalidateSelf();
  }

  /// [reloadData] - 데이터를 수동으로 새로고침합니다.
  ///
  /// ref.invalidateSelf()는 현재 Provider의 상태를 무효화하고
  /// build()를 다시 호출하여 DB에서 최신 데이터를 가져옵니다.
  void reloadData() {
    ref.invalidateSelf();
  }

  /// [filterByTag] - 태그 기준으로 목록을 필터링합니다.
  ///
  /// [매개변수] tag
  /// - null: 전체 조회
  /// - 값 지정: 해당 tag만 필터링
  Future<void> filterByTag(int? tag) async {
    await filterTodos(tag: tag);
  }

  /// [filterTodos] - 태그/검색어 조건으로 목록을 필터링합니다.
  ///
  /// [매개변수]
  /// - tag: null이면 태그 필터 미적용
  /// - keyword: null/빈값이면 검색 미적용
  Future<void> filterTodos({int? tag, String? keyword}) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      return await _dbHandler.queryTodosFiltered(
        tag: tag,
        keyword: keyword,
      );
    });
    state = result;
  }
}

/// ============================================================================
/// [vmHandlerProvider] - VMHandler의 Riverpod Provider 정의
/// ============================================================================
/// AsyncNotifierProvider를 사용하여 VMHandler를 Provider로 등록합니다.
///
/// [사용법]
/// ```dart
/// // View에서 Todo 목록 구독 (자동 UI 갱신)
/// final todosAsync = ref.watch(vmHandlerProvider);
///
/// // todosAsync.when()으로 로딩/데이터/에러 상태 분기 처리
/// todosAsync.when(
///   data: (todos) => ListView(...),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('오류: $err'),
/// );
///
/// // CRUD 호출
/// ref.read(vmHandlerProvider.notifier).insertTodo(todo);
/// ```
/// ============================================================================
final vmHandlerProvider =
    AsyncNotifierProvider<VMHandler, List<Todo>>(VMHandler.new);
