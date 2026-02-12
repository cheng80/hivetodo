# TagDo

태그 기반 할 일 앱. 태그 분류, 마감일·알림, 검색, 드래그 정렬을 지원한다.

---

## 주요 기능

| 기능 | 설명 |
|------|------|
| 태그 | 업무/개인/공부 등 10종 기본 태그, 색상·이름 커스터마이징 |
| 필터 | 전체/미완료/완료, 태그별, 마감일 유무 |
| 마감일·알림 | 로컬 알림 예약, 앱 재시작 시 알람 재등록 |
| 검색 | 할 일 내용 실시간 검색 |
| 순서 변경 | 드래그 앤 드롭으로 리스트 정렬 |
| 테마 | 라이트/다크/시스템, 영속화 |
| 다국어 | ko, en, ja, zh-CN, zh-TW |

---

## 기술 스택

| 구분 | 기술 | 용도 |
|------|------|------|
| 상태 관리 | Riverpod | 비동기 데이터, 테마, 필터 상태 |
| 로컬 DB | Hive | Todo·Tag 영속화, NoSQL Key-Value |
| 설정 | GetStorage | 테마·언어 등 경량 설정 |
| 다국어 | easy_localization | 5개 언어, locale 기반 |
| 알림 | flutter_local_notifications | 마감일 알람, 포그라운드 표시 |
| UI | Material + Custom ColorScheme | 테마 일관성, 시맨틱 컬러 |

---

## 아키텍처

**MVVM + 레이어 분리**

```
lib/
├── model/      # Todo, Tag, Hive TypeAdapter
├── view/       # UI 전담 (home, app_drawer, sheets, todo_item)
├── vm/         # 비즈니스 로직·상태
│   ├── *Handler   → DB/저장소 접근 (DatabaseHandler, TagHandler)
│   └── *Notifier  → Riverpod 상태 (TodoListNotifier, ThemeNotifier 등)
├── service/    # NotificationService (알림 예약·취소)
├── theme/      # ColorScheme, palette, ConfigUI
└── util/       # 공통 유틸, locale

assets/
└── translations/   # 다국어 JSON (ko, en, ja, zh-CN, zh-TW)
```

- **View**: UI 렌더링만. `ref.watch`로 상태 구독, `ref.read`로 액션 호출
- **Handler**: Hive Box CRUD 전담. Repository 용어 대신 Handler 사용 (Git 혼동 방지)
- **Notifier**: Riverpod AsyncNotifier/Notifier. `ref.invalidateSelf()`로 재로딩
- **테마**: `CommonColorScheme` + `context.palette`로 라이트/다크 색상 통일
- **다국어**: `easy_localization` + `assets/translations/`. JSON 형태로 각 언어별 관리 (ko, en, ja, zh-CN, zh-TW). Drawer에서 언어 선택

### 시스템 구성도

![System Diagram](docs/system/System_Diagram.png)

### 데이터 모델 (ERD)

![ERD](docs/erd/ERD.png)

---

## 실행

```bash
flutter pub get
flutter run
```
