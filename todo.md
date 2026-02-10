# TODO - 추가 구현 항목

## 기능 추가

- [x] **색상 태그별 필터링 기능**
  - `DatabaseHandler`에 `queryTodosByTag(int tag)` 메서드 추가
  - `VMHandler`에 `filterByTag(int? tag)` 메서드 추가
  - `home.dart` 앱바 아래에 태그 필터 드롭다운 UI 추가
  - null이면 전체 보기, 인덱스 지정 시 해당 색상만 필터링
  - 수정 파일: `database_handler.dart`, `vm_handler.dart`, `home.dart`

- [x] **태그에 이름 부여**
  - Tag 모델 + Hive Box "tag"로 DB 저장
  - 기본 10개: 업무, 개인, 공부, 취미, 건강, 쇼핑, 가족, 금융, 이동, 기타
  - 목록/편집/필터 화면에서 색상 옆에 태그 이름 표시

- [x] **검색 기능**
  - 할 일 내용(content) 텍스트 검색
  - 앱바에 검색 아이콘 추가 → 검색 바 토글

- [x] **완료/미완료 필터 (전체, 완료, 미완료)**
  - 기존 자동 정렬(미완료→완료) 제거
  - 단일 정렬 기준: 최근 수정순
  - 상태 필터 칩 UI 추가 (HomeStatusChips)

- [x] **태그 색상 커스터마이징**
  - Tag 모델에 `colorValue` (int) 필드로 색상 직접 저장
  - `TodoColor.presets` 15개 프리셋 + `MaterialPicker` (~190색) 선택 가능
  - `flutter_colorpicker` 패키지 적용

- [x] **태그 관리 화면 (태그 설정)**
  - Drawer → "태그 관리" 버튼으로 진입
  - 태그 추가/수정/삭제 가능 (`tag_settings.dart`)
  - 색상 선택: 프리셋 다이얼로그 + MaterialPicker 다이얼로그

- [x] **Drawer 추가**
  - 세팅 헤더 (기어 아이콘 + "세팅" 텍스트)
  - 다크 모드 스위치
  - 태그 관리 버튼

- [x] **테마 시스템 적용 (다크/라이트 모드)**
  - `ThemeNotifier` + `GetStorage`로 테마 상태 관리/영속화
  - `CommonColorScheme` 기반 시맨틱 컬러 정의
  - `context.palette` 확장으로 어디서든 테마 색상 접근
  - 모든 view 파일의 하드코딩 색상 → `context.palette` 마이그레이션

- [x] **UI 모듈화**
  - `home.dart`의 위젯 빌드 함수들을 `home_widgets.dart`로 분리
  - `todo_item.dart` 별도 위젯 파일 분리

- [ ] **Todo 항목 순서 변경 (드래그 앤 드롭)**
  - `ReorderableListView`로 사용자 지정 순서 지원
  - 순서 값을 모델에 추가 (새 @HiveField 필요)

## 버그 수정 / 개선

- [x] **DateTime.now() 중복 호출 버그 수정**
  - `Todo.create()`에서 now 변수 하나로 통일 완료

- [x] **updatedAt 미갱신 수정**
  - `todo_edit.dart` 수정 모드에서 `updatedAt: DateTime.now()` 추가 완료

- [x] **"CHAGNGE" 오타 수정**
  - "CHANGE"로 수정 완료

- [x] **전체 삭제 시 확인 다이얼로그 추가**
  - 실수로 전체 삭제 방지를 위한 "정말 삭제하시겠습니까?" 확인 팝업

- [x] **빈 내용 저장 방지**
  - content가 비어있을 때 저장 버튼 비활성화 또는 인라인 경고 표시

- [x] **드롭다운 선택 시 글자 흔들림 수정**
  - `isExpanded: true` + `Expanded` + `Align` 적용

## 구조 개선

- [x] **MVVM 패턴 정리**
  - Handler: DB/저장소 접근 전담 (DatabaseHandler, TagHandler)
  - Notifier: Riverpod 상태 관리 (TodoListNotifier, TagListNotifier, ThemeNotifier)
  - vm_handler.dart 삭제 → TodoListNotifier로 통합

- [x] **Todo 아이템 위젯 분리**
  - `home.dart`의 `_buildTodoItem()`을 별도 위젯 파일로 분리
  - `view/todo_item.dart` 생성 → `ConsumerWidget`으로 구현

- [ ] **Riverpod 코드 제너레이션 방식 추가 (`@riverpod`)**
  - 참고 프로젝트의 `vm_handler_gen.dart`처럼 어노테이션 방식 ViewModel 추가
  - `riverpod_annotation`, `riverpod_generator` 패키지 필요
