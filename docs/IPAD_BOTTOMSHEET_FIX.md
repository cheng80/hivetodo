# iPad 바텀시트 즉시 닫힘 버그 수정 가이드

> 다른 앱에서 동일 증상 발생 시 **이 문서를 참고하여 수정**하세요.

---

## 증상

- **iPad**에서 상단 버튼(AppBar 등) 탭 시 바텀시트가 뜨자마자 바로 닫힘
- 기존 항목 수정 시트는 정상 동작하는 경우도 있음
- iPhone에서는 문제 없음

---

## 원인

### A. iPadOS 26.1 Flutter 버그 (주요 원인)

- **상태바(status bar) 탭이 가짜 터치 이벤트로 전달**되어 모달이 즉시 닫힘
- AppBar 상단 버튼 탭 시 상태바 영역과 겹쳐 이 현상 발생
- Flutter 3.41.0에서 수정 → 이후 크래시로 revert → 재수정 대기 중 (2026-02 기준)
- [Flutter Issue #177992](https://github.com/flutter/flutter/issues/177992)

### B. Drawer → 시트 오픈 시 레이스 (부가 원인)

- Drawer를 닫는 `Navigator.pop`과 시트 오픈이 겹쳐 시트가 즉시 닫힘
- iPad에서 화면 계층이 복잡할 때 발생

---

## 수정 방법 (2가지 중 택 1)

### 방법 A: `isDismissible: false` (딜레이 없음, 권장)

바깥 영역 탭으로 닫히지 않게 하여 가짜 터치를 무시합니다.
닫기는 시트 내부의 Cancel/취소 버튼으로만 가능합니다.

```dart
final result = await showModalBottomSheet<Todo>(
  context: context,
  useRootNavigator: true,
  isDismissible: false,   // 가짜 터치로 barrier 탭 방지
  isScrollControlled: true,
  builder: (context) => MyEditSheet(),
);
```

- 장점: 딜레이 없어 반응이 즉각적
- 단점: 바깥 탭으로 시트를 닫을 수 없음 (Cancel 버튼 필요)

### 방법 B: 350ms 지연 (`isDismissible: true` 유지)

바깥 탭 닫기를 유지하면서, 가짜 터치가 지나간 뒤 시트를 오픈합니다.

```dart
Future<void> _showEditSheet() async {
  // iPadOS 26.1 workaround
  await Future.delayed(const Duration(milliseconds: 350));
  if (!mounted) return;

  final result = await showModalBottomSheet<Todo>(
    context: context,
    useRootNavigator: true,
    isDismissible: true,
    isScrollControlled: true,
    builder: (context) => MyEditSheet(),
  );
}
```

- 장점: 바깥 탭 닫기 유지
- 단점: 버튼 탭 후 350ms 지연 체감

---

## 부가: 루트 Navigator로 열기

iPad에서 Scaffold/Drawer/Showcase 등 복잡한 화면 계층에서는 루트 Navigator를 사용하는 것이 안정적입니다.

```dart
final rootContext = Navigator.of(context, rootNavigator: true).context;
final result = await showModalBottomSheet<Todo>(
  context: rootContext,
  useRootNavigator: true,
  // ...
);
```

---

## 부가: Drawer에서 시트를 여는 경우

Drawer 닫힘 애니메이션과 겹치지 않도록 **짧은 지연** 후 시트 오픈.

```dart
onTap: () async {
  Navigator.pop(context);  // Drawer 닫기
  await Future.delayed(const Duration(milliseconds: 220));
  if (!mounted) return;
  await _showAddSheet(ref);
},
```

---

## 수정 대상 파일

- `showModalBottomSheet`를 호출하는 모든 함수
- 특히 AppBar 등 **화면 상단** 버튼에서 시트를 여는 경로
- Drawer에서 시트를 여는 메뉴의 `onTap` 콜백

---

## AI 지시용 프롬프트

```
@docs/IPAD_BOTTOMSHEET_FIX.md 이 문서를 참고하여
iPad에서 바텀시트가 즉시 닫히는 버그를 수정해줘.
showModalBottomSheet를 호출하는 모든 곳을 확인하고 적용해.
```
