import 'package:flutter_riverpod/flutter_riverpod.dart';

// 편집 시트 로컬 상태 - 태그
class EditTagNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTag(int value) => state = value;
}

// 편집 시트 로컬 상태 - 내용 비어있음 여부
class IsContentEmptyNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void setEmpty(bool value) => state = value;
}

// 화면 종료 시 자동 해제
final editTagProvider =
    NotifierProvider.autoDispose<EditTagNotifier, int>(EditTagNotifier.new);
final isContentEmptyProvider =
    NotifierProvider.autoDispose<IsContentEmptyNotifier, bool>(
  IsContentEmptyNotifier.new,
);
