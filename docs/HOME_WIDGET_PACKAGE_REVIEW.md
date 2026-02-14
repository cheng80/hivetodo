# 홈 위젯 패키지 검토

> TagDo 앱에 홈 화면 위젯(Todo 요약 표시) 기능 추가 시 사용할 패키지 검토

---

## 요약

| 패키지 | 추천 | likes | 비고 |
|--------|------|-------|------|
| **home_widget** | ✅ **추천** | 2.1k | 사실상 표준, Google Codelab 사용 |
| home_widget_nic | △ | 0 | home_widget 포크, 비활성 |

**결론: `home_widget` 사용 권장**

---

## 1. home_widget (^0.9.0)

- **pub.dev**: https://pub.dev/packages/home_widget
- **GitHub**: https://github.com/ABausG/home_widget
- **Publisher**: antonborri.es (verified)
- **Likes**: 2,133 | **Points**: 160 | **Downloads**: 53.5k/주

### 특징

| 항목 | 내용 |
|------|------|
| 플랫폼 | Android, iOS |
| 위젯 UI 작성 | **Flutter 불가** → 네이티브 코드 필수 |
| Android | Jetpack Glance 또는 XML + RemoteViews |
| iOS | SwiftUI + WidgetKit |
| 데이터 전달 | `HomeWidget.saveWidgetData()`, `HomeWidget.updateWidget()` |
| Flutter 위젯 → 이미지 | `HomeWidget.renderFlutterWidget()` 지원 (차트 등 복잡 UI) |

### Flutter API (Dart)

```dart
// 데이터 저장
HomeWidget.saveWidgetData<String>('todo_count', '5');
HomeWidget.saveWidgetData<String>('next_due', '내일 회의');

// 위젯 갱신 트리거
HomeWidget.updateWidget(
  name: 'TagDoWidget',
  androidName: 'TagDoWidgetProvider',
  iOSName: 'TagDoWidget',
);

// Flutter 위젯을 PNG로 렌더 → 위젯에서 이미지로 표시
await HomeWidget.renderFlutterWidget(
  TodoSummaryChart(),
  fileName: 'todo_chart',
  key: 'chart_path',
  logicalSize: Size(400, 200),
);
```

### 플랫폼별 요구사항

| 플랫폼 | 요구사항 |
|--------|----------|
| **iOS** | Widget Extension 타겟 추가, **App Groups** (유료 Apple Developer 필요) |
| **Android** | AppWidgetProvider 또는 Jetpack Glance, AndroidManifest 수정 |

### 장점

- Google 공식 Codelab에서 사용 ([Adding a Home Screen widget to your Flutter App](https://codelabs.developers.google.com/flutter-home-screen-widgets))
- Flutter ↔ 네이티브 간 데이터 공유 인터페이스 통일
- `renderFlutterWidget`로 Flutter UI를 이미지로 내보내 위젯에 표시 가능
- 대규모 커뮤니티, 이슈/문서 풍부

### 단점

- **네이티브 코드 작성 필수** (Swift/Kotlin)
- iOS: App Groups 설정 필요 (유료 개발자 계정)
- 초기 설정 복잡도 높음

---

## 2. home_widget_nic (^0.5.1)

- **pub.dev**: https://pub.dev/packages/home_widget_nic
- **Likes**: 0 | **Downloads**: 15/주
- **Publisher**: unverified

### 특징

- `home_widget`의 포크/변형으로 보임
- Jetpack Glance, `requestPinWidget`, `Uint8List` 등 추가 기능
- **활성 개발/유지보수 부족** (12개월 전 마지막 업데이트, likes 0)

### 결론

- **비추천**: 활성도·신뢰도 낮음

---

## 3. TagDo 적용 시 고려사항

### 표시할 데이터 (예시)

| 키 | 타입 | 설명 |
|----|------|------|
| `todo_count` | int | 미완료 할 일 개수 |
| `next_due_title` | String | 가장 가까운 마감일 할 일 제목 |
| `next_due_date` | String | 마감일 포맷 문자열 |
| `chart_path` | String? | (선택) `renderFlutterWidget`로 생성한 차트 이미지 경로 |

### 구현 난이도

| 단계 | 내용 | 예상 공수 |
|------|------|-----------|
| 1 | `home_widget` 패키지 추가, Dart에서 데이터 저장/갱신 로직 | 1~2일 |
| 2 | Android 위젯 (XML 또는 Glance) | 1~2일 |
| 3 | iOS 위젯 (SwiftUI + WidgetKit), App Groups 설정 | 2~3일 |
| 4 | Todo 변경 시 `updateWidget()` 호출 연동 | 0.5일 |

**총 예상**: 4~7일 (플랫폼·네이티브 경험에 따라 변동)

### 참고 자료

- [Google Codelab - Flutter Home Screen Widgets](https://codelabs.developers.google.com/flutter-home-screen-widgets)
- [home_widget 공식 문서](https://docs.page/ABausG/home_widget)
- [Apple WidgetKit](https://developer.apple.com/documentation/widgetkit)
- [Android App Widgets](https://developer.android.com/develop/ui/views/appwidgets)

---

## 4. 대안 검토

### Flutter만으로 위젯 작성 가능한가?

- **불가능**. Android/iOS 홈 위젯은 OS가 제공하는 네이티브 위젯 API를 사용해야 함.
- Flutter 엔진은 위젯 프로세스에서 실행되지 않으므로, Flutter UI를 직접 그릴 수 없음.
- `renderFlutterWidget`은 Flutter 앱 프로세스에서 위젯을 PNG로 렌더한 뒤, 그 이미지 경로를 네이티브 위젯에 전달하는 방식.

### Android만 지원?

- Android 전용으로 먼저 구현하면 iOS 설정(App Groups 등)을 나중에 추가 가능.
- `home_widget`은 플랫폼별로 `androidName`, `iOSName`을 분리해 지정할 수 있어 단계적 구현에 적합.

---

## 5. 권장 사항

1. **`home_widget` 사용** – 현재 Flutter 생태계에서 사실상 표준
2. **Android 우선 구현** – XML 또는 Jetpack Glance로 먼저 구현 후 iOS 확장
3. **단순 UI부터** – 텍스트(미완료 개수, 다음 마감일)만 표시하는 위젯으로 시작
4. **데이터 갱신 시점** – `TodoListNotifier`의 insert/update/delete/check 시 `HomeWidget.updateWidget()` 호출
