// todo_edit_sheet.dart
// 핵심 기능만 간단히 요약


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hive_sample/model/todo.dart';
import 'package:flutter_hive_sample/model/todo_color.dart';
import 'package:flutter_hive_sample/vm/edit_sheet_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// TodoEditSheet - Todo 생성/수정 BottomSheet 위젯
///
/// [update] 파라미터:
/// - null → 생성 모드 (빈 입력 필드, SAVE 버튼)
/// - not null → 수정 모드 (기존 값 표시, CHANGE 버튼)
// 로컬 상태는 별도 Notifier 파일에서 관리

class TodoEditSheet extends ConsumerStatefulWidget {
  /// 수정할 기존 Todo 객체 (null이면 새로 생성)
  final Todo? update;

  const TodoEditSheet({
    super.key,
    required this.update,
  });

  @override
  ConsumerState<TodoEditSheet> createState() => _TodoEditSheetState();
}

class _TodoEditSheetState extends ConsumerState<TodoEditSheet> {
  /// 할 일 내용 입력 컨트롤러
  late TextEditingController _controller;

  /// 선택 가능한 색상 목록
  late List<Color> _colors;

  @override
  void initState() {
    super.initState();

    /// 수정 모드: 기존 Todo의 content와 tag로 초기화
    if (widget.update != null) {
      _controller = TextEditingController(text: widget.update!.content);
    } else {
      /// 생성 모드: 빈 컨트롤러
      _controller = TextEditingController();
    }

    final initialTag = widget.update?.tag ?? 0;
    final initialEmpty = _controller.text.trim().isEmpty;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(editTagProvider.notifier).setTag(initialTag);
      ref.read(isContentEmptyProvider.notifier).setEmpty(initialEmpty);
    });
    _controller.addListener(() {
      final isEmpty = _controller.text.trim().isEmpty;
      if (ref.read(isContentEmptyProvider) != isEmpty) {
        ref.read(isContentEmptyProvider.notifier).setEmpty(isEmpty);
      }
    });

    _colors = TodoColor.setColors();
  }

  @override
  void dispose() {
    /// 컨트롤러와 ValueNotifier를 정리합니다.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      /// 빈 영역 탭 시 키보드 숨기기
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
        color: Colors.transparent,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - kToolbarHeight,
        child: Column(
          children: [
            /// ─────────────────────────────────────────────────
            /// [상단 헤더] - 타이틀 + 저장 버튼
            /// ─────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 60,
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// 타이틀: 생성/수정 모드에 따라 텍스트 변경
                  Text(
                    widget.update == null ? "CREATE TODO" : "UPDATE TODO",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),

                  Row(
                    children: [
                      /// [취소 버튼] - 변경 없이 시트를 닫습니다.
                      /// Navigator.pop()에 값을 전달하지 않으므로 null이 반환됩니다.
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "CANCEL",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color.fromRGBO(115, 115, 115, 1),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      /// [저장/변경 버튼] - 내용이 비어있으면 비활성화
                      Builder(
                        builder: (context) {
                          final isEmpty =
                              ref.watch(isContentEmptyProvider);
                          final label =
                              widget.update == null ? "SAVE" : "CHANGE";
                          return GestureDetector(
                            onTap: isEmpty ? null : () => _onSave(),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: isEmpty
                                    ? const Color.fromRGBO(115, 115, 115, 1)
                                    : Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// ─────────────────────────────────────────────────
            /// [content 입력 필드]
            /// ─────────────────────────────────────────────────
            _buildFormField(
              "content",
              Builder(
                builder: (context) {
                  final isEmpty = ref.watch(isContentEmptyProvider);
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: TextFormField(
                      controller: _controller,
                      maxLength: 100,
                      minLines: 3,
                      maxLines: 5,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorText: isEmpty ? '내용을 입력해주세요.' : null,
                        errorStyle: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            /// ─────────────────────────────────────────────────
            /// [tag 선택] - 색상 팔레트
            /// ─────────────────────────────────────────────────
            _buildFormField(
              "tag",
              Builder(
                builder: (context) {
                  final selectedIndex = ref.watch(editTagProvider);
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: List.generate(
                        _colors.length,
                        (index) => GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            ref.read(editTagProvider.notifier).setTag(index);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                border: selectedIndex == index
                                    ? Border.all(
                                        color: const Color.fromRGBO(
                                            91, 91, 91, 1),
                                        width: 2,
                                      )
                                    : null,
                                borderRadius: BorderRadius.circular(8),
                                color: selectedIndex == index
                                    ? _colors[index]
                                    : _colors[index].withValues(alpha: 0.6),
                              ),
                              child: Visibility(
                                visible: selectedIndex == index,
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// [_onSave] - 저장/변경 버튼 탭 시 호출됩니다.
  ///
  /// Navigator.pop()으로 Todo 객체를 반환합니다.
  /// 부모 위젯(TodoHome)의 _showEditSheet()에서 이 값을 받아
  /// VMHandler를 통해 Hive에 저장합니다.
  void _onSave() {
    HapticFeedback.mediumImpact();

    final content = _controller.text.trim();
    if (content.isEmpty) {
      return;
    }

    final Todo result;
    final selectedTag = ref.read(editTagProvider);

    if (widget.update == null) {
      /// 생성 모드: Todo.create()로 새 객체 생성
      result = Todo.create(content, selectedTag);
    } else {
      /// 수정 모드: copyWith()으로 content, tag, updatedAt만 변경
      result = widget.update!.copyWith(
        content: content,
        tag: selectedTag,
        updatedAt: DateTime.now(),
      );
    }

    Navigator.of(context).pop(result);
  }

  /// [_buildFormField] - 레이블 + 입력 위젯 조합 헬퍼
  Widget _buildFormField(String label, Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(115, 115, 115, 1),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
