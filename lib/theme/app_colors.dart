// 앱 컬러 시스템 - 모든 컬러 관련 클래스와 확장을 export
//
// 사용 예시:
// ```dart
// import 'package:flutter_hive_sample/theme/app_colors.dart';
//
// final p = context.palette;
// Container(color: p.background)
// ```
library;

export 'common_color_scheme.dart';
export 'app_color_scheme.dart';
export 'palette_context.dart';

import 'package:flutter/material.dart';
import 'common_color_scheme.dart';
import 'app_color_scheme.dart';

// 라이트 / 다크 팔레트 정의
class AppColors {
  const AppColors._();

  // ============================================================================
  // 다크 테마 팔레트 (현재 기본 테마)
  // ============================================================================
  static const AppColorScheme dark = AppColorScheme(
    common: CommonColorScheme(
      background: Color.fromRGBO(26, 26, 26, 1),
      cardBackground: Color.fromRGBO(36, 36, 36, 1),
      sheetBackground: Colors.white,
      primary: Colors.white,
      accent: Colors.red,
      textPrimary: Colors.white,
      textSecondary: Color.fromRGBO(115, 115, 115, 1),
      textMeta: Color.fromRGBO(215, 215, 215, 1),
      textOnPrimary: Color.fromRGBO(26, 26, 26, 1),
      textOnSheet: Colors.black,
      divider: Color.fromRGBO(60, 60, 60, 1),
      icon: Colors.white,
      iconOnSheet: Color.fromRGBO(91, 91, 91, 1),
      chipSelectedBg: Colors.white,
      chipSelectedText: Colors.black,
      chipUnselectedBg: Color.fromRGBO(50, 50, 50, 1),
      chipUnselectedText: Colors.white,
      dropdownBg: Color.fromRGBO(26, 26, 26, 1),
      searchFieldBg: Colors.white,
      searchFieldText: Colors.black,
      searchFieldHint: Color.fromRGBO(120, 120, 120, 1),
    ),
  );

  // ============================================================================
  // 라이트 테마 팔레트
  // ============================================================================
  static const AppColorScheme light = AppColorScheme(
    common: CommonColorScheme(
      background: Color(0xFFF5F5F5),
      cardBackground: Colors.white,
      sheetBackground: Colors.white,
      primary: Color(0xFF1976D2),
      accent: Colors.red,
      textPrimary: Color(0xFF212121),
      textSecondary: Color(0xFF757575),
      textMeta: Color(0xFF9E9E9E),
      textOnPrimary: Colors.white,
      textOnSheet: Colors.black,
      divider: Color(0xFFE0E0E0),
      icon: Color(0xFF212121),
      iconOnSheet: Color(0xFF757575),
      chipSelectedBg: Color(0xFF212121),
      chipSelectedText: Colors.white,
      chipUnselectedBg: Color(0xFFE0E0E0),
      chipUnselectedText: Color(0xFF212121),
      dropdownBg: Colors.white,
      searchFieldBg: Color(0xFFE0E0E0),
      searchFieldText: Color(0xFF212121),
      searchFieldHint: Color(0xFF9E9E9E),
    ),
  );
}
