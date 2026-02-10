# TagDo

태그 기반 할 일 앱. 할 일에 태그를 달고, 마감일을 걸고, 알람 받을 수 있다.

---

## 주요 기능

- **태그**: 업무/개인/공부 등 10종 기본 태그. 색상·이름 커스터마이징 가능
- **필터**: 전체/미완료/완료, 태그별, 마감일 있는 것만 보기
- **마감일·알림**: 설정한 시간에 로컬 알림
- **검색**: 할 일 내용으로 검색
- **드래그로 순서 변경**: 항목을 끌어다 놓아서 정렬
- **다크 모드**: 라이트/다크/시스템 테마
- **다국어**: 한국어, 영어, 일본어, 중국어(간체/번체)

---

## 기술 스택

| 구분 | 사용 |
|------|------|
| 상태 관리 | Riverpod |
| 로컬 DB | Hive |
| 경량 설정 저장 | GetStorage |
| 다국어 | easy_localization |
| 알림 | flutter_local_notifications |
| UI | Material + Custom ColorScheme |

### 구조

- **MVVM**: `view`는 UI만, `vm`에 Notifier/Handler
- **palette**: `context.palette`로 라이트/다크 구분된 색상 접근
- **Handler**: DB 접근 (DatabaseHandler, TagHandler)
- **Notifier**: Riverpod로 상태 관리 (TodoListNotifier, TagListNotifier, ThemeNotifier, HomeFilterNotifier)

---

## 실행

```bash
flutter pub get
flutter run
```

다국어 리소스는 `assets/translations/`에 있고, 앱에서 Drawer → 언어 선택으로 변경 가능하다.
