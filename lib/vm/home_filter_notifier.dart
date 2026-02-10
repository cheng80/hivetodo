import 'package:flutter_riverpod/flutter_riverpod.dart';

// 홈 필터 로컬 상태 - 선택 태그
class SelectedTagNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void setTag(int? value) => state = value;
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
final searchQueryProvider =
    NotifierProvider.autoDispose<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);
final searchModeProvider =
    NotifierProvider.autoDispose<SearchModeNotifier, bool>(
  SearchModeNotifier.new,
);

// 태그/검색어 결합 상태
class FilterState {
  final int? tag;
  final String keyword;

  const FilterState({
    required this.tag,
    required this.keyword,
  });
}

final filterStateProvider = Provider<FilterState>((ref) {
  final tag = ref.watch(selectedTagProvider);
  final keyword = ref.watch(searchQueryProvider).trim();
  return FilterState(tag: tag, keyword: keyword);
});
