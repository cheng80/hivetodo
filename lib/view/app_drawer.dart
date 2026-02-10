// app_drawer.dart
// 앱 사이드 메뉴 (Drawer)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hive_sample/theme/app_colors.dart';
import 'package:flutter_hive_sample/view/tag_settings.dart';
import 'package:flutter_hive_sample/vm/theme_notifier.dart';

/// AppDrawer - 설정 및 부가 기능을 위한 사이드 메뉴
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final themeMode = ref.watch(themeNotifierProvider);
    final isDark = themeMode == ThemeMode.dark ||
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
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                spacing: 12,
                children: [
                  Icon(Icons.settings, color: p.icon, size: 28),
                  Text(
                    '세팅',
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

            /// 태그 관리 버튼
            ListTile(
              leading: Icon(Icons.label_outline, color: p.icon),
              title: Text(
                '태그 관리',
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

            /// 다크모드 스위치
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '다크 모드',
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
          ],
        ),
      ),
    );
  }
}
