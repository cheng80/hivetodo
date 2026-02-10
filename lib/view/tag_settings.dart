// tag_settings.dart
// 태그 관리 화면 (신규 생성, 수정, 삭제)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hive_sample/model/tag.dart';
import 'package:flutter_hive_sample/model/todo_color.dart';
import 'package:flutter_hive_sample/theme/app_colors.dart';
import 'package:flutter_hive_sample/vm/tag_list_notifier.dart';

/// 태그 설정 화면
class TagSettings extends ConsumerWidget {
  const TagSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final tagsAsync = ref.watch(tagListProvider);

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        iconTheme: IconThemeData(color: p.icon),
        title: Text(
          '태그 관리',
          style: TextStyle(
            color: p.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        actions: [
          /// 태그 추가 버튼
          IconButton(
            onPressed: () => _showTagEditor(context, ref),
            icon: Icon(Icons.add, color: p.icon, size: 28),
          ),
        ],
      ),
      body: tagsAsync.when(
        data: (tags) {
          if (tags.isEmpty) {
            return Center(
              child: Text(
                '태그가 없습니다.\n+ 버튼으로 추가해 보세요!',
                textAlign: TextAlign.center,
                style: TextStyle(color: p.textSecondary, fontSize: 16),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: tags.length,
            separatorBuilder: (_, _) => Divider(
              color: p.divider,
              height: 1,
              indent: 20,
              endIndent: 20,
            ),
            itemBuilder: (context, index) {
              final tag = tags[index];
              return _TagTile(
                tag: tag,
                onEdit: () => _showTagEditor(context, ref, tag: tag),
                onDelete: () => _confirmDelete(context, ref, tag),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('오류: $e', style: TextStyle(color: p.textPrimary)),
        ),
      ),
    );
  }

  /// 태그 생성/수정 다이얼로그
  void _showTagEditor(BuildContext context, WidgetRef ref, {Tag? tag}) {
    final p = context.palette;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: p.sheetBackground,
      builder: (_) => _TagEditorSheet(tag: tag),
    );
  }

  /// 삭제 확인 다이얼로그
  void _confirmDelete(BuildContext context, WidgetRef ref, Tag tag) {
    final p = context.palette;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.sheetBackground,
        title: Text('태그 삭제', style: TextStyle(color: p.textOnSheet)),
        content: Text(
          '"${tag.name}" 태그를 삭제하시겠습니까?',
          style: TextStyle(color: p.iconOnSheet),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('취소', style: TextStyle(color: p.iconOnSheet)),
          ),
          TextButton(
            onPressed: () {
              ref.read(tagListProvider.notifier).deleteTag(tag.id);
              Navigator.pop(ctx);
            },
            child: Text('삭제', style: TextStyle(color: p.accent)),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────
/// 태그 목록 타일
/// ─────────────────────────────────────────────────
class _TagTile extends StatelessWidget {
  final Tag tag;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TagTile({
    required this.tag,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: tag.color,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      title: Text(
        tag.name,
        style: TextStyle(
          color: p.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          IconButton(
            onPressed: onEdit,
            icon: Icon(Icons.edit, color: p.textSecondary, size: 22),
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              onDelete();
            },
            icon: Icon(Icons.delete_outline, color: p.accent, size: 22),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────
/// 태그 생성/수정 BottomSheet
/// ─────────────────────────────────────────────────
class _TagEditorSheet extends ConsumerStatefulWidget {
  final Tag? tag;

  const _TagEditorSheet({this.tag});

  @override
  ConsumerState<_TagEditorSheet> createState() => _TagEditorSheetState();
}

class _TagEditorSheetState extends ConsumerState<_TagEditorSheet> {
  late final TextEditingController _nameController;
  late Color _selectedColor;

  bool get _isEdit => widget.tag != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tag?.name ?? '');
    _selectedColor = widget.tag?.color ?? TodoColor.presets.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 헤더
          Text(
            _isEdit ? '태그 수정' : '태그 추가',
            style: TextStyle(
              color: p.textOnSheet,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),

          /// 이름 입력 (최대 10글자)
          TextField(
            controller: _nameController,
            maxLength: 10,
            style: TextStyle(color: p.textOnSheet, fontSize: 16),
            cursorColor: p.textOnSheet,
            decoration: InputDecoration(
              labelText: '태그 이름',
              labelStyle: TextStyle(color: p.iconOnSheet),
              counterStyle: TextStyle(color: p.iconOnSheet),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: p.iconOnSheet),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: p.textOnSheet, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          /// 색상 선택
          Text(
            '색상',
            style: TextStyle(
              color: p.iconOnSheet,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          /// 현재 선택된 색상 미리보기 + 색상 선택 버튼
          Row(
            spacing: 12,
            children: [
              /// 선택된 색상 미리보기
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: p.iconOnSheet, width: 2),
                ),
              ),

              /// 프리셋에서 선택 버튼
              OutlinedButton.icon(
                onPressed: _showPresetPicker,
                icon: Icon(Icons.palette, size: 18, color: p.textOnSheet),
                label: Text('프리셋', style: TextStyle(color: p.textOnSheet)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: p.iconOnSheet),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              /// MaterialPicker로 선택 버튼
              OutlinedButton.icon(
                onPressed: _showMaterialPicker,
                icon: Icon(Icons.color_lens, size: 18, color: p.textOnSheet),
                label: Text('전체 색상', style: TextStyle(color: p.textOnSheet)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: p.iconOnSheet),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          /// 저장 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: p.textOnSheet,
                foregroundColor: p.sheetBackground,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _isEdit ? '수정' : '추가',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 프리셋 색상 선택 다이얼로그
  void _showPresetPicker() {
    final p = context.palette;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.sheetBackground,
        title: Text('프리셋 색상', style: TextStyle(color: p.textOnSheet)),
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: TodoColor.presets.map((color) {
            final isSelected =
                _selectedColor.toARGB32() == color.toARGB32();
            return GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                setState(() => _selectedColor = color);
                Navigator.pop(ctx);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: p.textOnSheet, width: 3)
                      : null,
                ),
                child: isSelected
                    ? Icon(Icons.check, color: p.sheetBackground, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// MaterialPicker 색상 선택 다이얼로그 (~190색)
  void _showMaterialPicker() {
    final p = context.palette;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.sheetBackground,
        title: Text('색상 선택', style: TextStyle(color: p.textOnSheet)),
        content: MaterialPicker(
          pickerColor: _selectedColor,
          onColorChanged: (color) {
            HapticFeedback.mediumImpact();
            setState(() => _selectedColor = color);
            Navigator.pop(ctx);
          },
          enableLabel: false,
        ),
      ),
    );
  }

  void _onSave() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    HapticFeedback.mediumImpact();
    final notifier = ref.read(tagListProvider.notifier);

    if (_isEdit) {
      /// 수정
      final updated = widget.tag!.copyWith(
        name: name,
        colorValue: _selectedColor.toARGB32(),
      );
      notifier.updateTag(updated);
    } else {
      /// 신규 생성
      final newTag = Tag(
        id: notifier.nextId(),
        name: name,
        colorValue: _selectedColor.toARGB32(),
      );
      notifier.addTag(newTag);
    }

    Navigator.pop(context);
  }
}
