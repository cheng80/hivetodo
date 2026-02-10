# TODO - 추가 구현 항목

## 기능 추가

- [x] **색상 태그별 필터링 기능**
  - `DatabaseHandler`에 `queryTodosByTag(int tag)` 메서드 추가
  - `VMHandler`에 `filterByTag(int? tag)` 메서드 추가
  - `home.dart` 앱바 아래에 태그 필터 드롭다운 UI 추가
  - null이면 전체 보기, 인덱스 지정 시 해당 색상만 필터링
  - 수정 파일: `database_handler.dart`, `vm_handler.dart`, `home.dart`

- [ ] **태그에 이름 부여**
  - 현재 색상 인덱스(0~9)만 존재, 카테고리 이름 없음
  - `TodoColor`에 이름 매핑 추가 (예: 0=업무, 1=개인, 2=공부 등)
  - 목록/편집 화면에서 색상 옆에 태그 이름 표시

- [x] **검색 기능**
  - 할 일 내용(content) 텍스트 검색
  - 앱바에 검색 아이콘 추가 → 검색 바 토글

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

## 구조 개선

- [ ] **Riverpod 코드 제너레이션 방식 추가 (`@riverpod`)**
  - 참고 프로젝트의 `vm_handler_gen.dart`처럼 어노테이션 방식 ViewModel 추가
  - `riverpod_annotation`, `riverpod_generator` 패키지 필요

- [x] **Todo 아이템 위젯 분리**
  - `home.dart`의 `_buildTodoItem()`을 별도 위젯 파일로 분리
  - `view/todo_item.dart` 생성 → `ConsumerWidget`으로 구현
