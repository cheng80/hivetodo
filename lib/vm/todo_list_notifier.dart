// todo_list_notifier.dart
// Todo 목록 Riverpod Notifier

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tagdo/model/todo.dart';
import 'package:tagdo/service/in_app_review_service.dart';
import 'package:tagdo/service/notification_service.dart';
import 'package:tagdo/util/app_storage.dart';
import 'package:tagdo/vm/database_handler.dart';

/// TodoListNotifier - Riverpod AsyncNotifier 기반 ViewModel
///
/// Todo 목록을 비동기로 관리합니다.
/// state는 AsyncValue<List<Todo>>로, 로딩/데이터/에러 3가지 상태를 포함합니다.
class TodoListNotifier extends AsyncNotifier<List<Todo>> {
  final DatabaseHandler _dbHandler = DatabaseHandler();
  final NotificationService _notificationService = NotificationService();
  final InAppReviewService _reviewService = InAppReviewService();

  @override
  Future<List<Todo>> build() async {
    return await _dbHandler.queryTodos();
  }

  /// 앱 최초 설치 시: 튜토리얼용 할 일 1개 생성 (5분 후 알람)
  /// [translatedContent]: 시스템 언어에 맞게 번역된 문자열 (Home에서 context.tr()로 전달)
  Future<void> createTutorialTodoIfNeeded(String translatedContent) async {
    if (AppStorage.getTutorialTodoCreated() ||
        AppStorage.getFirstLaunchDate() == null) return;

    final todos = state.value ?? await _dbHandler.queryTodos();
    if (todos.isNotEmpty) return;

    final firstLaunch = DateTime.tryParse(AppStorage.getFirstLaunchDate()!);
    if (firstLaunch == null) return;

    final dueDate = firstLaunch.add(const Duration(minutes: 5));
    final tutorialTodo = Todo.create(translatedContent, 0, dueDate: dueDate);
    final order = _dbHandler.nextSortOrder();
    final inserted = tutorialTodo.copyWith(sortOrder: order);
    await _dbHandler.insertTodo(inserted);
    await _notificationService.scheduleNotification(inserted);
    await AppStorage.setTutorialTodoCreated();
    ref.invalidateSelf();
  }

  /// 새 Todo 생성 (맨 아래에 배치)
  Future<void> insertTodo(Todo todo) async {
    final order = _dbHandler.nextSortOrder();
    final inserted = todo.copyWith(sortOrder: order);
    await _dbHandler.insertTodo(inserted);
    await _notificationService.scheduleNotification(inserted);
    ref.invalidateSelf();
  }

  /// Todo 수정
  Future<void> updateTodo(Todo todo) async {
    await _dbHandler.updateTodo(todo);
    if (todo.dueDate == null) {
      await _notificationService.cancelNotification(todo.no);
    } else {
      await _notificationService.scheduleNotification(todo);
    }
    ref.invalidateSelf();
  }

  /// 완료 상태 토글
  Future<void> toggleCheck(Todo todo) async {
    final wasIncomplete = !todo.isCheck;
    await _dbHandler.toggleCheck(todo);
    ref.invalidateSelf();

    /// 완료로 전환 시: 완료 횟수 증가 + 조건 만족 시 인앱 리뷰 요청
    if (wasIncomplete) {
      await AppStorage.incrementTodoCompletedCount();
      _reviewService.maybeRequestReview();
    }
  }

  /// Todo 삭제
  Future<void> deleteTodo(int no) async {
    await _notificationService.cancelNotification(no);
    await _dbHandler.deleteTodo(no);
    ref.invalidateSelf();
  }

  /// 완료 항목 일괄 삭제
  Future<void> deleteCheckedTodos() async {
    final todos = state.value;
    if (todos != null) {
      for (final todo in todos.where((t) => t.isCheck)) {
        await _notificationService.cancelNotification(todo.no);
      }
    }
    await _dbHandler.deleteCheckedTodos();
    ref.invalidateSelf();
  }

  /// 전체 삭제
  Future<void> deleteAllTodos() async {
    await _notificationService.cancelAllNotifications();
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

  /// 더미 데이터 일괄 삽입 (개발/데모용)
  Future<void> insertDummyTodos(List<Todo> todos) async {
    for (final todo in todos) {
      await insertTodo(todo);
    }
  }

  /// 태그/검색어/완료 상태/마감일 유무로 필터링
  Future<void> filterTodos({
    int? tag,
    String? keyword,
    bool? isCheck,
    bool? hasDueDate,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      return await _dbHandler.queryTodosFiltered(
        tag: tag,
        keyword: keyword,
        isCheck: isCheck,
        hasDueDate: hasDueDate,
      );
    });
    state = result;
  }
}

/// Todo 목록 Provider
final todoListProvider =
    AsyncNotifierProvider<TodoListNotifier, List<Todo>>(TodoListNotifier.new);
