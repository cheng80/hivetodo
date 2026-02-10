// ============================================================================
// [view/todo_item.dart] - Todo 아이템 위젯
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hive_sample/model/tag.dart';
import 'package:flutter_hive_sample/model/todo.dart';
import 'package:flutter_hive_sample/theme/app_colors.dart';
import 'package:flutter_hive_sample/vm/todo_list_notifier.dart';
import 'package:flutter_hive_sample/vm/tag_list_notifier.dart';
import 'package:flutter_hive_sample/vm/tag_handler.dart';

class TodoItem extends ConsumerWidget {
  final Todo todo;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final todoNotifier = ref.read(todoListProvider.notifier);
    final tags = ref.watch(tagListProvider).value ?? <Tag>[];

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
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 22),
        color: Colors.transparent,
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
          ],
        ),
      ),
    );
  }
}
