// app_drawer.dart
// 앱 사이드 메뉴 (Drawer)

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tagdo/service/notification_service.dart';
import 'package:tagdo/theme/app_colors.dart';
import 'package:tagdo/theme/config_ui.dart';
import 'package:tagdo/view/tag_settings.dart';
import 'package:tagdo/vm/theme_notifier.dart';
import 'package:tagdo/vm/todo_list_notifier.dart';

/// AppDrawer - 설정 및 부가 기능을 위한 사이드 메뉴
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final themeMode = ref.watch(themeNotifierProvider);
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Drawer(
      backgroundColor: p.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 헤더 (설정 아이콘 + 타이틀)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ConfigUI.screenPaddingH, 24, ConfigUI.screenPaddingH, 16,
              ),
              child: Row(
                spacing: 12,
                children: [
                  Icon(Icons.settings, color: p.icon, size: 28),
                  Text(
                    'settings'.tr(),
                    style: TextStyle(
                      color: p.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: p.divider, height: 1),

            /// 다크모드 스위치
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ConfigUI.screenPaddingH,
                vertical: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'darkMode'.tr(),
                    style: TextStyle(color: p.textPrimary, fontSize: 16),
                  ),
                  Switch(
                    value: isDark,
                    activeThumbColor: p.chipSelectedBg,
                    activeTrackColor: p.chipUnselectedBg,
                    inactiveThumbColor: p.textMeta,
                    inactiveTrackColor: p.chipUnselectedBg,
                    onChanged: (_) {
                      ref.read(themeNotifierProvider.notifier).toggleTheme();
                    },
                  ),
                ],
              ),
            ),

            Divider(color: p.divider, height: 1),

            /// 언어 선택
            ListTile(
              leading: Icon(Icons.language, color: p.icon),
              title: Text(
                'language'.tr(),
                style: TextStyle(color: p.textPrimary, fontSize: 16),
              ),
              trailing: Icon(Icons.chevron_right, color: p.textSecondary),
              onTap: () {
                Navigator.pop(context);
                _showLanguagePicker(context);
              },
            ),

            /// 태그 관리 버튼
            ListTile(
              leading: Icon(Icons.label_outline, color: p.icon),
              title: Text(
                'tagManage'.tr(),
                style: TextStyle(color: p.textPrimary, fontSize: 16),
              ),
              trailing: Icon(Icons.chevron_right, color: p.textSecondary),
              onTap: () {
                Navigator.pop(context); // Drawer 닫기
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TagSettings()),
                );
              },
            ),

            /// 알람 상태 확인 (디버깅)
            ListTile(
              leading: Icon(Icons.access_alarm, color: p.icon),
              title: Text(
                'alarmStatusCheck'.tr(),
                style: TextStyle(color: p.textPrimary, fontSize: 16),
              ),
              trailing: Icon(Icons.info_outline, color: p.textSecondary),
              onTap: () async {
                Navigator.pop(context);
                final todos = await ref.read(todoListProvider.future);
                final withDueDate =
                    todos.where((t) => t.dueDate != null).toList();
                final pending =
                    await NotificationService().checkPendingNotifications();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'alarmStatusSummary'.tr(namedArgs: {
                          'count': '${withDueDate.length}',
                          'alarmCount': '${pending.length}',
                        }),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

}

void _showLanguagePicker(BuildContext context) {
  final p = context.palette;
  showModalBottomSheet(
      context: context,
      backgroundColor: p.sheetBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ConfigUI.radiusSheet),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _langTile(ctx, const Locale('ko'), 'langKo'.tr()),
            _langTile(ctx, const Locale('en'), 'langEn'.tr()),
            _langTile(ctx, const Locale('ja'), 'langJa'.tr()),
            _langTile(ctx, const Locale('zh', 'CN'), 'langZhCN'.tr()),
            _langTile(ctx, const Locale('zh', 'TW'), 'langZhTW'.tr()),
          ],
        ),
      ),
    );
}

Widget _langTile(BuildContext context, Locale locale, String label) {
    final p = context.palette;
    final isSelected = context.locale == locale;
    return ListTile(
      leading: Icon(
        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isSelected ? p.accent : p.icon,
      ),
      title: Text(label, style: TextStyle(color: p.textOnSheet)),
      onTap: () {
      context.setLocale(locale);
      Navigator.pop(context);
    },
  );
}
