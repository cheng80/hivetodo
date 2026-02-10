// ============================================================================
// [view/sheets/todo_delete_sheet.dart] - 삭제 옵션 BottomSheet
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hive_sample/theme/app_colors.dart';

class TodoDeleteSheet extends StatelessWidget {
  final VoidCallback onDeleteOne;
  final VoidCallback onDeleteAll;

  const TodoDeleteSheet({
    super.key,
    required this.onDeleteOne,
    required this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 112 + MediaQuery.of(context).padding.bottom,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// [이 항목 삭제] - 해당 Todo만 삭제
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              onDeleteOne();
            },
            child: Container(
              margin: const EdgeInsets.only(left: 20, right: 20, top: 12),
              alignment: Alignment.centerLeft,
              color: Colors.transparent,
              height: 50,
              child: Text(
                "이 항목 삭제",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: p.textOnSheet,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          /// [전체 삭제] - 모든 Todo 삭제 (빨간색 경고)
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              onDeleteAll();
            },
            child: Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              alignment: Alignment.centerLeft,
              color: Colors.transparent,
              height: 50,
              child: Text(
                "전체 삭제",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: p.accent,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
