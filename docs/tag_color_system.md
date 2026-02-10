# 태그 색상 관리 구조

태그 색상은 **3개 레이어**로 관리된다.

---

## 1. 데이터 모델 (`lib/model/tag.dart`)

- `Tag.colorValue` (int) — `Color.toARGB32()`로 변환된 정수값을 Hive에 저장
- `Tag.color` getter — 저장된 int를 `Color` 객체로 복원
- 어떤 색상이든 int로 저장 가능 (프리셋에 제한되지 않음)

## 2. 프리셋 팔레트 (`lib/model/todo_color.dart`)

- `TodoColor.presets` — 빠른 선택용 15개 프리셋 색상 (static const)
- 저장에는 관여하지 않음. 순수 UI 선택지 역할
- `flutter_colorpicker`의 `MaterialPicker`로 약 190개 색상도 선택 가능

## 3. 데이터 접근 (`lib/vm/tag_handler.dart`)

- `_defaults` — 앱 최초 실행 시 자동 생성되는 기본 태그 10개 (이름 + 색상)
- `saveTag()` — 생성/수정 공용 (같은 ID면 덮어쓰기)
- `deleteTag()` — 삭제
- `colorOf(tags, id)` — Todo에서 태그 ID로 색상 조회하는 정적 헬퍼

## 4. 상태 관리 (`lib/vm/tag_list_notifier.dart`)

- `TagListNotifier` (AsyncNotifier) — CRUD 후 `ref.invalidateSelf()`로 UI 자동 갱신
- `tagListProvider`로 어디서든 태그 목록 구독 가능

---

## 흐름

```
사용자 색상 선택 (프리셋 15개 / MaterialPicker ~190개)
  → Color.toARGB32() → int
  → Tag(colorValue: int) → Hive 저장
  → TagListNotifier.invalidateSelf()
  → UI에서 tag.color getter로 Color 복원하여 표시
```
