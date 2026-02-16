# Theme 폴더 사용 가이드

테마 모드 관리와 앱 전용 색상을 제공합니다. `material.dart`만 의존하며, 커스텀 스키마 없이 단순하게 구성되어 있습니다.

---

## 폴더 구조

```
lib/theme/
  app_theme_colors.dart  # Brightness 기반 앱 색상
  README.md              # 사용 문서
  MIGRATION_PLAN.md      # 마이그레이션 계획 (참고용)
```

> **참고**: hivetodo는 Riverpod `ThemeNotifier`로 테마 모드를 관리합니다. `theme_provider.dart`(InheritedWidget)는 사용하지 않습니다.

---

## 1. 테마 모드 (Riverpod)

테마 모드는 `lib/vm/theme_notifier.dart`의 `ThemeNotifier`로 관리됩니다.

### 1.1 사용

```dart
// 테마 모드 가져오기
final themeMode = ref.watch(themeNotifierProvider);

// 테마 변경
ref.read(themeNotifierProvider.notifier).setThemeMode(ThemeMode.dark);
ref.read(themeNotifierProvider.notifier).toggleTheme();

// 다크 모드 여부
ref.read(themeNotifierProvider.notifier).isDarkMode(context);
```

---

## 2. AppThemeColors

`Theme.of(context).brightness`로 라이트/다크를 판별해 색상을 반환합니다. ThemeExtension 없이 단순 구현입니다.

### 2.1 Import

```dart
import 'package:tagdo/theme/app_theme_colors.dart';
```

### 2.2 사용 방법

**방법 A: static 메서드**

```dart
Container(color: AppThemeColors.background(context))
Text('제목', style: TextStyle(color: AppThemeColors.textPrimary(context)))
```

**방법 B: extension (context.appTheme)**

```dart
final p = context.appTheme;
Container(color: p.background)
Text('제목', style: TextStyle(color: p.textPrimary))
```

### 2.3 제공 색상

| 메서드 | 설명 |
|--------|------|
| `background` | 전체 배경 |
| `cardBackground` | 카드/패널 배경 |
| `sheetBackground` | BottomSheet 배경 |
| `primary` | 주요 포인트 |
| `accent` | 보조 포인트 |
| `textPrimary` | 기본 텍스트 |
| `textSecondary` | 보조 텍스트 |
| `textMeta` | 메타 텍스트 (날짜, 태그) |
| `textOnPrimary` | Primary 배경 위 텍스트 |
| `textOnSheet` | BottomSheet 위 텍스트 |
| `divider` | 구분선 |
| `icon` | 아이콘 기본 색 |
| `iconOnSheet` | BottomSheet 위 아이콘 |
| `chipSelectedBg` | 칩 선택 배경 |
| `chipSelectedText` | 칩 선택 텍스트 |
| `chipUnselectedBg` | 칩 비선택 배경 |
| `chipUnselectedText` | 칩 비선택 텍스트 |
| `dropdownBg` | 드롭다운 배경 |
| `searchFieldBg` | 검색 필드 배경 |
| `searchFieldText` | 검색 필드 텍스트 |
| `searchFieldHint` | 검색 필드 힌트 |
| `alarmAccent` | 마감일/알람 아이콘 색 |

### 2.4 ThemeData 정의용 상수

`MaterialApp`의 `theme`/`darkTheme`에서 사용할 때는 `BuildContext`가 없으므로 상수를 사용합니다.

```dart
MaterialApp(
  theme: ThemeData(
    scaffoldBackgroundColor: AppThemeColors.lightBackground,
  ),
  darkTheme: ThemeData(
    scaffoldBackgroundColor: AppThemeColors.darkBackground,
  ),
  ...
)
```

| 상수 | 설명 |
|------|------|
| `AppThemeColors.lightBackground` | 라이트 배경 |
| `AppThemeColors.darkBackground` | 다크 배경 |

---

## 3. ConfigUI (별도 위치)

UI 상수(모서리, 패딩, 애니메이션 등)는 `lib/util/config_ui.dart`에 있습니다.

```dart
import 'package:tagdo/util/config_ui.dart';

ConfigUI.radiusCard
ConfigUI.screenPaddingH
```

---

## 4. 앱별 커스터마이징

### 4.1 색상 변경

`app_theme_colors.dart`의 각 메서드 내부 색상 값을 앱에 맞게 수정합니다.

### 4.2 색상 추가

새 semantic 색이 필요하면 `AppThemeColors`에 static 메서드를 추가하고, `AppThemeColorsHelper`에도 getter를 추가합니다.
