// ============================================================================
// [view/sheets/todo_delete_sheet.dart] - 삭제 옵션 BottomSheet
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tagdo/theme/app_colors.dart';
import 'package:tagdo/theme/config_ui.dart';

class TodoDeleteSheet extends StatelessWidget {
  final VoidCallback onDeleteOne;
  final VoidCallback onDeleteChecked;
  final VoidCallback onDeleteAll;

  const TodoDeleteSheet({
    super.key,
    required this.onDeleteOne,
    required this.onDeleteChecked,
    required this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 162 + MediaQuery.of(context).padding.bottom,
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
              margin: const EdgeInsets.only(
                left: ConfigUI.sheetPaddingH,
                right: ConfigUI.sheetPaddingH,
                top: 12,
              ),
              alignment: Alignment.centerLeft,
              color: Colors.transparent,
              height: ConfigUI.sheetButtonHeight,
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

          /// [완료 항목 삭제] - 완료된 Todo만 일괄 삭제
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              onDeleteChecked();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: ConfigUI.sheetPaddingH),
              alignment: Alignment.centerLeft,
              color: Colors.transparent,
              height: ConfigUI.sheetButtonHeight,
              child: Text(
                "완료 항목 삭제",
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
              margin: const EdgeInsets.symmetric(horizontal: ConfigUI.sheetPaddingH),
              alignment: Alignment.centerLeft,
              color: Colors.transparent,
              height: ConfigUI.sheetButtonHeight,
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
