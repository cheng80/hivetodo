import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 완료 상태 필터
enum TodoStatus { all, unchecked, checked }

// 홈 필터 로컬 상태 - 선택 태그
class SelectedTagNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void setTag(int? value) => state = value;
}

// 홈 필터 로컬 상태 - 완료 상태
class TodoStatusNotifier extends Notifier<TodoStatus> {
  @override
  TodoStatus build() => TodoStatus.all;

  void setStatus(TodoStatus value) => state = value;
}

// 홈 필터 로컬 상태 - 검색어
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

// 홈 필터 로컬 상태 - 검색 모드
class SearchModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setMode(bool value) => state = value;
}

// 화면 종료 시 자동 해제
final selectedTagProvider =
    NotifierProvider.autoDispose<SelectedTagNotifier, int?>(
  SelectedTagNotifier.new,
);
final todoStatusProvider =
    NotifierProvider.autoDispose<TodoStatusNotifier, TodoStatus>(
  TodoStatusNotifier.new,
);
final searchQueryProvider =
    NotifierProvider.autoDispose<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);
final searchModeProvider =
    NotifierProvider.autoDispose<SearchModeNotifier, bool>(
  SearchModeNotifier.new,
);

/// 태그/검색어/상태 결합 필터
class FilterState {
  final int? tag;
  final String keyword;
  final TodoStatus status;

  const FilterState({
    required this.tag,
    required this.keyword,
    required this.status,
  });
}

final filterStateProvider = Provider<FilterState>((ref) {
  final tag = ref.watch(selectedTagProvider);
  final keyword = ref.watch(searchQueryProvider).trim();
  final status = ref.watch(todoStatusProvider);
  return FilterState(tag: tag, keyword: keyword, status: status);
});
