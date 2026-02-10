// app_storage.dart
// GetStorage 기반 앱 설정 헬퍼

import 'package:get_storage/get_storage.dart';

/// AppStorage - 앱 설정을 저장/조회하는 정적 헬퍼
///
/// GetStorage 접근을 한 곳으로 모아 관리한다.
/// 추후 설정 항목이 늘어나면 여기에 키/메서드를 추가한다.
class AppStorage {
  static GetStorage get _storage => GetStorage();

  // ─── 테마 ─────────────────────────────────────
  static const String _keyTheme = 'theme_mode';

  /// 저장된 테마 모드 문자열 조회 (light / dark / system)
  static String? getThemeMode() => _storage.read<String>(_keyTheme);

  /// 테마 모드 저장
  static Future<void> saveThemeMode(String mode) =>
      _storage.write(_keyTheme, mode);

  // ─── 추후 설정 추가 시 여기에 ────────────────────
}
