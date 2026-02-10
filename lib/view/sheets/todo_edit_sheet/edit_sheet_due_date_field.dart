// edit_sheet_due_date_field.dart
// TodoEditSheet 마감일 선택 필드 (DatePicker + TimePicker)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tagdo/theme/app_colors.dart';
import 'package:tagdo/theme/config_ui.dart';
import 'package:tagdo/view/sheets/todo_edit_sheet/edit_form_field.dart';
import 'package:tagdo/vm/edit_sheet_notifier.dart';

/// [EditSheetDueDateField] - 마감일 선택 (탭 시 DatePicker + TimePicker)
class EditSheetDueDateField extends ConsumerWidget {
  final Future<void> Function() onPickDate;

  const EditSheetDueDateField({
    super.key,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final dueDate = ref.watch(editDueDateProvider);

    return EditFormField(
      label: "마감일",
      child: Container(
        decoration: BoxDecoration(
          borderRadius: ConfigUI.inputRadius,
          border: Border.all(
            color: p.textOnSheet,
            width: ConfigUI.focusBorderWidth,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPickDate,
            borderRadius: ConfigUI.inputRadius,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: p.iconOnSheet,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      dueDate != null ? _formatDueDate(dueDate) : "미설정",
                      style: TextStyle(
                        color: dueDate != null
                            ? p.textOnSheet
                            : p.iconOnSheet,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (dueDate != null)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        ref.read(editDueDateProvider.notifier).clear();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: p.iconOnSheet,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDueDate(DateTime d) {
    final period = d.hour < 12 ? "오전" : "오후";
    final hour12 =
        d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
    final min = d.minute.toString().padLeft(2, "0");
    return "${d.year}년 ${d.month}월 ${d.day}일 $period $hour12:$min";
  }
}
