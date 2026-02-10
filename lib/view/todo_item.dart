// ============================================================================
// [view/todo_item.dart] - Todo 아이템 위젯
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tagdo/model/tag.dart';
import 'package:tagdo/model/todo.dart';
import 'package:tagdo/theme/app_colors.dart';
import 'package:tagdo/theme/config_ui.dart';
import 'package:tagdo/vm/todo_list_notifier.dart';
import 'package:tagdo/vm/tag_list_notifier.dart';
import 'package:tagdo/vm/tag_handler.dart';
import 'package:tagdo/vm/home_filter_notifier.dart';

class TodoItem extends ConsumerWidget {
  final Todo todo;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const TodoItem({
    super.key,
    required this.todo,
    required this.index,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final todoNotifier = ref.read(todoListProvider.notifier);
    final tags = ref.watch(tagListProvider).value ?? <Tag>[];

    /// 삭제 시트 표시 중인 Todo 하이라이트
    final highlightedNo = ref.watch(highlightedTodoProvider);
    final isHighlighted = highlightedNo == todo.no;

    return GestureDetector(
      /// [탭] - 수정 시트 열기
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },

      /// [길게 누르기] - 삭제 옵션 시트 표시
      onLongPress: () {
        HapticFeedback.mediumImpact();
        onLongPress();
      },
      child: AnimatedContainer(
        duration: ConfigUI.durationMedium,
        curve: ConfigUI.curveDefault,
        margin: const EdgeInsets.only(
          left: ConfigUI.listItemMarginLeft,
          right: ConfigUI.listItemMarginRight,
          top: ConfigUI.listItemMarginTop,
          bottom: ConfigUI.listItemMarginBottom,
        ),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          color: isHighlighted
              ? p.textPrimary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: ConfigUI.cardRadius,
          border: isHighlighted
              ? Border.all(
                  color: p.textPrimary.withValues(alpha: 0.2),
                  width: ConfigUI.focusBorderWidth,
                )
              : null,
          boxShadow: isHighlighted
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// [체크박스] - 완료 상태 토글
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                todoNotifier.toggleCheck(todo);
              },
              child: Icon(
                todo.isCheck ? Icons.check_box : Icons.check_box_outline_blank,
                color: p.textSecondary,
                size: 32,
              ),
            ),

            /// [색상 태그]
            Container(
              margin: const EdgeInsets.only(top: 4, left: 4),
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: TagHandler.colorOf(tags, todo.tag),
              ),
            ),

            /// [텍스트 영역]
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 8, top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    /// 할 일 내용
                    Text(
                      todo.content.isEmpty ? "내용 없음" : todo.content,
                      style: todo.content.isEmpty
                          ? TextStyle(
                              color: p.textSecondary,
                              fontSize: 16,
                            )
                          : TextStyle(
                              color: p.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                    ),

                    /// 태그 이름
                    Text(
                      TagHandler.nameOf(tags, todo.tag),
                      style: TextStyle(
                        color: p.textMeta,
                        fontSize: 12,
                      ),
                    ),

                    /// 날짜 + 수정 여부 (스타일 통일)
                    RichText(
                      text: TextSpan(
                        text: todo.updatedAt
                            .toString()
                            .substring(0, 19)
                            .replaceAll("-", ". "),
                        style: TextStyle(
                          color: p.textMeta,
                          fontSize: 12,
                        ),
                        children: [
                          if (todo.createdAt != todo.updatedAt) ...[
                            TextSpan(
                              text: "  (수정됨)",
                              style: TextStyle(
                                fontSize: 12,
                                color: p.textMeta,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// [드래그 핸들] - 이 영역만 드래그로 순서 변경 가능
            ReorderableDragStartListener(
              index: index,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.drag_handle,
                  color: p.textSecondary,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
