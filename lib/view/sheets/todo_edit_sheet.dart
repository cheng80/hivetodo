// todo_edit_sheet.dart
// 핵심 기능만 간단히 요약


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hive_sample/model/tag.dart';
import 'package:flutter_hive_sample/model/todo.dart';
import 'package:flutter_hive_sample/theme/app_colors.dart';
import 'package:flutter_hive_sample/view/tag_settings.dart';
import 'package:flutter_hive_sample/vm/edit_sheet_notifier.dart';
import 'package:flutter_hive_sample/vm/tag_list_notifier.dart';
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

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

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
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: p.textOnSheet,
                      fontSize: 18,
                    ),
                  ),

                  Row(
                    spacing: 20,
                    children: [
                      /// [취소 버튼]
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "CANCEL",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: p.iconOnSheet,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      /// [저장/변경 버튼] - 내용이 비어있으면 비활성화
                      Builder(
                        builder: (context) {
                          final isEmpty = ref.watch(isContentEmptyProvider);
                          final label =
                              widget.update == null ? "SAVE" : "CHANGE";
                          return GestureDetector(
                            onTap: isEmpty ? null : () => _onSave(),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: isEmpty ? p.iconOnSheet : p.accent,
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
                      border: Border.all(color: p.textOnSheet, width: 2),
                    ),
                    child: TextFormField(
                      controller: _controller,
                      maxLength: 100,
                      minLines: 3,
                      maxLines: 5,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: p.textOnSheet,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorText: isEmpty ? '내용을 입력해주세요.' : null,
                        errorStyle: TextStyle(
                          color: p.accent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            /// ─────────────────────────────────────────────────
            /// [tag 라벨]
            /// ─────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              alignment: Alignment.centerLeft,
              child: Text(
                "tag",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: p.iconOnSheet,
                ),
              ),
            ),

            /// ─────────────────────────────────────────────────
            /// [tag 선택] - 세로 스크롤 Wrap (태그 수·이름 길이 대응)
            /// ─────────────────────────────────────────────────
            Expanded(
              child: Builder(
                builder: (context) {
                  final selectedId = ref.watch(editTagProvider);
                  final tags = ref.watch(tagListProvider).value ?? <Tag>[];
                  /// 화면 너비에서 패딩 제외 후 5등분 → 아이템 고정 너비
                  final itemWidth =
                      (MediaQuery.of(context).size.width - 48 - 12 * 4) / 5;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 16,
                      children: tags.map((tag) {
                        final isSelected = selectedId == tag.id;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            ref.read(editTagProvider.notifier).setTag(tag.id);
                          },
                          child: SizedBox(
                            width: itemWidth,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 4,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    border: isSelected
                                        ? Border.all(
                                            color: p.iconOnSheet,
                                            width: 2,
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(8),
                                    color: isSelected
                                        ? tag.color
                                        : tag.color.withValues(alpha: 0.6),
                                  ),
                                  child: Visibility(
                                    visible: isSelected,
                                    child: Icon(
                                      Icons.check,
                                      color: p.textOnSheet,
                                    ),
                                  ),
                                ),
                                Text(
                                  tag.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: p.textOnSheet,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),

            /// ─────────────────────────────────────────────────
            /// [태그 관리 버튼] - 태그 설정 화면으로 이동 후 복귀
            /// ─────────────────────────────────────────────────
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (_) => const TagSettings()),
                    );
                  },
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: p.iconOnSheet, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 6,
                      children: [
                        Icon(Icons.settings, size: 18, color: p.iconOnSheet),
                        Text(
                          "태그 관리",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: p.textOnSheet,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// [_onSave] - 저장/변경 버튼 탭 시 호출
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
    final p = context.palette;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: p.iconOnSheet,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
