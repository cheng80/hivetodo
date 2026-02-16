# Theme 마이그레이션 계획

hivetodo(tagdo)의 기존 theme 구조를 custom_test_app 방식으로 마이그레이션하는 계획입니다.

---

## 1. 현재 vs 목표 구조 비교

### 1.1 현재 hivetodo (제거 대상)

| 파일 | 역할 |
|------|------|
| `config_ui.dart` | UI 상수 (모서리, 패딩, 그림자, 애니메이션, 타이포 등) |
| `app_colors.dart` | library export + AppColors (light/dark 팔레트) |
| `app_color_scheme.dart` | AppColorScheme (CommonColorScheme 래퍼) |
| `common_color_scheme.dart` | CommonColorScheme (시맨틱 색상 정의) |
| `palette_context.dart` | `context.palette` → AppColorScheme 확장 |

### 1.2 목표 custom_test_app 방식

| 파일 | 역할 |
|------|------|
| `theme_provider.dart` | InheritedWidget 기반 테마 모드 관리 (선택) |
| `app_theme_colors.dart` | Brightness 기반 static 메서드 + `context.appTheme` 확장 |
| `README.md` | 사용 문서 |

---

## 2. 주요 차이점 분석

### 2.1 색상 API

| 구분 | hivetodo (현재) | custom_test_app (목표) |
|------|-----------------|------------------------|
| 접근 방식 | `context.palette` → 객체 getter | `context.appTheme` 또는 `AppThemeColors.xxx(context)` |
| 예시 | `p.background`, `p.textMeta` | `p.background`, `AppThemeColors.textPrimary(context)` |

### 2.2 hivetodo 전용 색상 (AppThemeColors에 없음)

custom_test_app의 기본 `AppThemeColors`에는 다음 색상이 없습니다. 마이그레이션 시 `app_theme_colors.dart`에 **반드시 추가**해야 합니다.

| 색상 | 용도 |
|------|------|
| `textMeta` | 메타 텍스트 (날짜, 태그 이름) |
| `textOnSheet` | BottomSheet 위 텍스트 |
| `icon` | 아이콘 기본 색 |
| `iconOnSheet` | BottomSheet 위 아이콘 |
| `sheetBackground` | BottomSheet 배경 |
| `dropdownBg` | 드롭다운 배경 |
| `searchFieldBg` | 검색 필드 배경 |
| `searchFieldText` | 검색 필드 텍스트 |
| `searchFieldHint` | 검색 필드 힌트 |
| `alarmAccent` | 마감일/알람 아이콘 색 |

### 2.3 ConfigUI (custom_test_app에 없음)

hivetodo의 `ConfigUI`는 **theme 폴더 외부 개념**입니다. custom_test_app README에 따르면:

> Custom 위젯은 theme 폴더에 의존하지 않으므로, 다른 앱에서 `lib/custom/`만 복사해 사용할 수 있습니다.

**결정**: `ConfigUI`는 theme과 분리된 UI 상수이므로, **`lib/util/config_ui.dart`로 이동**하여 theme 마이그레이션과 별도로 유지합니다.

### 2.4 테마 모드 관리

| 구분 | hivetodo | custom_test_app |
|------|----------|-----------------|
| 방식 | Riverpod `ThemeNotifier` + `AppStorage` | InheritedWidget `ThemeProvider` + setState |
| 영속화 | ✅ AppStorage에 저장 | ❌ 없음 |

**결정**: hivetodo는 이미 Riverpod + 영속화를 사용하므로, **ThemeProvider는 도입하지 않고** `ThemeNotifier`를 유지합니다. `theme_provider.dart`의 `context.themeMode`, `context.toggleTheme`, `context.isDarkMode` 확장이 필요하다면, `ThemeNotifier` + `ref`와 연동하는 별도 확장을 만들거나, 기존 `ThemeNotifier.isDarkMode(context)`를 그대로 사용합니다.

---

## 3. 마이그레이션 단계

### Phase 1: ConfigUI 분리 (theme과 무관)

1. `lib/theme/config_ui.dart` → `lib/util/config_ui.dart`로 이동
2. 모든 `import 'package:tagdo/theme/config_ui.dart'`를 `import 'package:tagdo/util/config_ui.dart'`로 변경

**영향 파일** (grep 기준):

- `lib/view/app_drawer.dart`
- `lib/view/tag_settings.dart`
- `lib/view/sheets/todo_edit_sheet/edit_sheet_tag_selector.dart`
- `lib/view/home.dart`
- `lib/view/home_widgets.dart`
- `lib/view/sheets/todo_edit_sheet/edit_sheet_due_date_field.dart`
- `lib/view/todo_item.dart`
- `lib/view/sheets/todo_edit_sheet/edit_sheet_content_field.dart`
- `lib/view/sheets/todo_edit_sheet/edit_sheet_header.dart`
- `lib/view/sheets/todo_delete_sheet.dart`
- `lib/view/sheets/todo_edit_sheet/edit_form_field.dart`

---

### Phase 2: theme 폴더 정리 및 새 구조 적용

#### 2.1 제거할 파일

- `app_colors.dart`
- `app_color_scheme.dart`
- `common_color_scheme.dart`
- `palette_context.dart`

#### 2.2 추가할 파일

1. **`theme_provider.dart`** (선택)
   - hivetodo는 Riverpod 사용 → `ThemeProvider` InheritedWidget은 **생략 권장**
   - `context.themeMode`, `context.toggleTheme`, `context.isDarkMode`가 필요하면 `ThemeNotifier` + `ref.watch(themeNotifierProvider)`로 처리

2. **`app_theme_colors.dart`**
   - custom_test_app 버전을 복사
   - hivetodo 전용 색상 추가: `textMeta`, `textOnSheet`, `icon`, `iconOnSheet`, `sheetBackground`, `dropdownBg`, `searchFieldBg`, `searchFieldText`, `searchFieldHint`, `alarmAccent`
   - **hivetodo의 `AppColors.dark`/`AppColors.light` 색상값을 그대로 반영** (시각적 일관성 유지)

3. **`README.md`**
   - custom_test_app README를 복사 후 hivetodo에 맞게 수정

---

### Phase 3: 코드 마이그레이션 (context.palette → context.appTheme)

| 기존 | 변경 후 |
|------|---------|
| `context.palette` | `context.appTheme` |
| `p.background` | `p.background` (동일) |
| `p.textMeta` | `p.textMeta` (app_theme_colors에 추가) |
| `p.textOnSheet` | `p.textOnSheet` (추가) |
| `p.icon` | `p.icon` (추가) |
| `p.iconOnSheet` | `p.iconOnSheet` (추가) |
| `p.sheetBackground` | `p.sheetBackground` (추가) |
| `p.dropdownBg` | `p.dropdownBg` (추가) |
| `p.searchFieldBg` | `p.searchFieldBg` (추가) |
| `p.searchFieldText` | `p.searchFieldText` (추가) |
| `p.searchFieldHint` | `p.searchFieldHint` (추가) |
| `p.alarmAccent` | `p.alarmAccent` (추가) |

**import 변경**:

- `import 'package:tagdo/theme/app_colors.dart'` → `import 'package:tagdo/theme/app_theme_colors.dart'`

**영향 파일**:

- `lib/util/common_util.dart`
- `lib/view/app_drawer.dart`
- `lib/view/tag_settings.dart`
- `lib/view/sheets/todo_edit_sheet/edit_sheet_tag_selector.dart`
- `lib/view/home.dart`
- `lib/view/home_widgets.dart`
- `lib/view/sheets/todo_edit_sheet/edit_sheet_due_date_field.dart`
- `lib/view/todo_item.dart`
- `lib/view/sheets/todo_edit_sheet/edit_sheet_content_field.dart`
- `lib/view/sheets/todo_edit_sheet/edit_sheet_header.dart`
- `lib/view/sheets/todo_delete_sheet.dart`
- `lib/view/sheets/todo_edit_sheet/edit_form_field.dart`

---

### Phase 4: main.dart 및 ThemeData

- `MaterialApp`의 `theme`/`darkTheme`에서 `AppThemeColors.lightBackground`, `AppThemeColors.darkBackground` 사용 (README 2.4 참고)
- hivetodo 전용 색상 반영:
  - `scaffoldBackgroundColor`: `AppThemeColors.lightBackground` / `AppThemeColors.darkBackground`
  - 기존 `ColorScheme` 값은 `AppColors.dark`/`AppColors.light`와 동일하게 유지

---

## 4. 작업 순서 요약

| 순서 | 작업 | 비고 |
|------|------|------|
| 1 | ConfigUI를 `lib/util/config_ui.dart`로 이동 | theme과 분리 |
| 2 | ConfigUI import 경로 일괄 변경 (11개 파일) | |
| 3 | `app_theme_colors.dart` 생성 (hivetodo 색상 포함) | custom_test_app + 확장 색상 |
| 4 | `theme_provider.dart` 복사 여부 결정 | Riverpod 유지 시 **생략 권장** |
| 5 | `README.md` 복사 및 hivetodo용 수정 | |
| 6 | 기존 theme 파일 4개 삭제 | app_colors, app_color_scheme, common_color_scheme, palette_context |
| 7 | `context.palette` → `context.appTheme` 일괄 치환 | |
| 8 | import `app_colors` → `app_theme_colors` 일괄 치환 | |
| 9 | main.dart ThemeData 정리 | AppThemeColors 상수 사용 |
| 10 | 빌드 및 테스트 | |

---

## 5. 위험 요소 및 주의사항

1. **색상값 차이**: custom_test_app 색상과 hivetodo 색상이 다릅니다. hivetodo의 `AppColors.dark`/`AppColors.light` 값을 `app_theme_colors.dart`에 **그대로 반영**해야 시각적 일관성이 유지됩니다.

2. **ThemeProvider vs Riverpod**: custom_test_app은 InheritedWidget, hivetodo는 Riverpod. `ThemeProvider`를 그대로 쓰면 `onToggleTheme`에서 `ref.read(themeNotifierProvider.notifier).toggleTheme()`를 호출하도록 래핑해야 합니다. **권장**: ThemeProvider는 사용하지 않고, `ThemeNotifier` + `ref.watch(themeNotifierProvider)`로 처리.

3. **ConfigUI 의존성**: ConfigUI를 util로 옮긴 후에도 모든 참조가 `util/config_ui.dart`로 바뀌어야 합니다.

4. **common_util.dart**: `showConfirmDialog` 등에서 `p.sheetBackground`, `p.textOnSheet`, `p.iconOnSheet` 사용. import 및 `context.appTheme`로 변경 필요.

---

## 6. hivetodo 색상값 매핑 (app_theme_colors.dart 작성 시 참고)

### 다크 테마 (AppColors.dark)

| 필드 | 값 |
|------|-----|
| background | `Color.fromRGBO(26, 26, 26, 1)` |
| cardBackground | `Color.fromRGBO(36, 36, 36, 1)` |
| sheetBackground | `Color.fromRGBO(44, 44, 44, 1)` |
| primary | `Colors.white` |
| accent | `Colors.red` |
| textPrimary | `Colors.white` |
| textSecondary | `Color.fromRGBO(115, 115, 115, 1)` |
| textMeta | `Color.fromRGBO(215, 215, 215, 1)` |
| textOnPrimary | `Color.fromRGBO(26, 26, 26, 1)` |
| textOnSheet | `Color.fromRGBO(240, 240, 240, 1)` |
| divider | `Color.fromRGBO(60, 60, 60, 1)` |
| icon | `Colors.white` |
| iconOnSheet | `Color.fromRGBO(180, 180, 180, 1)` |
| chipSelectedBg | `Colors.white` |
| chipSelectedText | `Colors.black` |
| chipUnselectedBg | `Color.fromRGBO(50, 50, 50, 1)` |
| chipUnselectedText | `Colors.white` |
| dropdownBg | `Color.fromRGBO(26, 26, 26, 1)` |
| searchFieldBg | `Colors.white` |
| searchFieldText | `Colors.black` |
| searchFieldHint | `Color.fromRGBO(120, 120, 120, 1)` |
| alarmAccent | `Color(0xFFFFB300)` |

### 라이트 테마 (AppColors.light)

| 필드 | 값 |
|------|-----|
| background | `Color(0xFFF5F5F5)` |
| cardBackground | `Colors.white` |
| sheetBackground | `Colors.white` |
| primary | `Color(0xFF1976D2)` |
| accent | `Colors.red` |
| textPrimary | `Color(0xFF212121)` |
| textSecondary | `Color(0xFF616161)` |
| textMeta | `Color(0xFF616161)` |
| textOnPrimary | `Colors.white` |
| textOnSheet | `Color(0xFF212121)` |
| divider | `Color(0xFFE0E0E0)` |
| icon | `Color(0xFF212121)` |
| iconOnSheet | `Color(0xFF424242)` |
| chipSelectedBg | `Color(0xFF212121)` |
| chipSelectedText | `Colors.white` |
| chipUnselectedBg | `Color(0xFFE0E0E0)` |
| chipUnselectedText | `Color(0xFF212121)` |
| dropdownBg | `Colors.white` |
| searchFieldBg | `Color(0xFFE0E0E0)` |
| searchFieldText | `Color(0xFF212121)` |
| searchFieldHint | `Color(0xFF757575)` |
| alarmAccent | `Color(0xFFFFB300)` |

---

## 7. 참고: custom_test_app README 핵심 요약

- **ThemeProvider**: `themeMode`, `onToggleTheme` 제공, `context.themeMode`, `context.toggleTheme`, `context.isDarkMode`
- **AppThemeColors**: `Theme.of(context).brightness` 기반, static 메서드 또는 `context.appTheme`
- **ThemeData 정의**: `AppThemeColors.lightBackground`, `AppThemeColors.darkBackground` 상수 사용
- **앱별 커스터마이징**: `app_theme_colors.dart` 내부 색상값 수정, 새 semantic 색은 static 메서드 + Helper getter 추가
