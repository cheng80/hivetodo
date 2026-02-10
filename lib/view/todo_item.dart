// ============================================================================
// [view/todo_item.dart] - Todo 아이템 위젯
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hive_sample/model/todo.dart';
import 'package:flutter_hive_sample/model/todo_color.dart';
import 'package:flutter_hive_sample/vm/vm_handler.dart';

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
    final vmHandler = ref.read(vmHandlerProvider.notifier);

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
                vmHandler.toggleCheck(todo);
              },
              child: Icon(
                todo.isCheck ? Icons.check_box : Icons.check_box_outline_blank,
                color: const Color.fromRGBO(115, 115, 115, 1),
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
                color: TodoColor.colorOf(todo.tag),
              ),
            ),

            /// [텍스트 영역]
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 8, top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 할 일 내용
                    Text(
                      todo.content.isEmpty ? "내용 없음" : todo.content,
                      style: todo.content.isEmpty
                          ? const TextStyle(
                              color: Color.fromRGBO(115, 115, 115, 1),
                              fontSize: 16,
                            )
                          : const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                    ),
                    const SizedBox(height: 8),

                    /// 날짜 + 수정 여부
                    RichText(
                      text: TextSpan(
                        text: todo.updatedAt
                            .toString()
                            .substring(0, 19)
                            .replaceAll("-", ". "),
                        style: const TextStyle(
                          color: Color.fromRGBO(215, 215, 215, 1),
                          fontSize: 12,
                        ),
                        children: [
                          if (todo.createdAt != todo.updatedAt) ...[
                            const TextSpan(
                              text: "  (수정됨)",
                              style: TextStyle(
                                fontSize: 10,
                                color: Color.fromRGBO(64, 64, 64, 1),
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
