# Flutter Hive Sample - TODO 앱

> Hive 로컬 데이터베이스를 활용한 Flutter TODO 샘플 앱

---

## 목차

1. [프로젝트 개요](#프로젝트-개요)
2. [기술 스택](#기술-스택)
3. [프로젝트 구조](#프로젝트-구조)
4. [Hive 핵심 개념](#hive-핵심-개념)
5. [앱 실행 흐름](#앱-실행-흐름)
6. [파일별 상세 설명](#파일별-상세-설명)
7. [데이터 흐름 (CRUD)](#데이터-흐름-crud)
8. [상태 관리 방식](#상태-관리-방식)
9. [UI 구조](#ui-구조)
10. [실행 방법](#실행-방법)
11. [참고 사항 및 개선 포인트](#참고-사항-및-개선-포인트)

---

## 프로젝트 개요

이 앱은 **Hive** 로컬 데이터베이스를 사용하여 TODO(할 일) 항목을 생성, 조회, 수정, 삭제(CRUD)하는 방법을 보여주는 샘플 프로젝트입니다.

### 주요 기능

| 기능 | 설명 |
|------|------|
| TODO 생성 | 할 일 내용 입력 + 색상 태그 선택 |
| TODO 조회 | Hive Box에서 전체 목록 로드 후 정렬 표시 |
| TODO 수정 | 기존 항목의 내용/태그 변경 |
| TODO 삭제 | 단일 삭제 또는 전체 삭제 |
| 완료 토글 | 체크박스로 완료/미완료 전환 |
| 자동 정렬 | 미완료 항목 → 완료 항목 순, 각각 최신 수정순 |

---

## 기술 스택

| 구분 | 패키지 | 버전 | 용도 |
|------|--------|------|------|
| 프레임워크 | Flutter | SDK ^3.10.4 | UI 프레임워크 |
| 로컬 DB | hive | ^2.2.3 | NoSQL 로컬 데이터베이스 |
| Hive Flutter | hive_flutter | ^1.1.0 | Hive의 Flutter 통합 지원 |
| 아이콘 | cupertino_icons | ^1.0.8 | iOS 스타일 아이콘 |

---

## 프로젝트 구조

```
lib/
├── main.dart                      # 앱 진입점 - Hive 초기화 및 앱 실행
└── _sample/
    ├── todo.dart                  # Todo 데이터 모델 (@HiveType 정의)
    ├── todo.g.dart                # TypeAdapter 자동 생성 파일 (build_runner)
    ├── todo_color.dart            # 태그 색상 유틸리티 클래스
    ├── home_page.dart             # 메인 화면 - TODO 목록 + CRUD 로직
    ├── todo_edit_widget.dart      # 생성/수정 BottomSheet 위젯
    └── todo_item_widget.dart      # 개별 TODO 아이템 위젯
```

### 파일 간 의존 관계

```
main.dart
  ├── todo.dart (모델 + 어댑터 등록)
  └── home_page.dart (첫 화면)
        ├── todo.dart (모델 사용)
        ├── todo_edit_widget.dart (생성/수정 시트)
        │     ├── todo.dart (Todo.create, copyWith)
        │     └── todo_color.dart (색상 목록)
        └── todo_item_widget.dart (목록 아이템)
              ├── todo.dart (Todo 표시)
              └── todo_color.dart (태그 색상)
```

---

## Hive 핵심 개념

### Hive란?

Hive는 **순수 Dart로 작성된 경량 NoSQL 데이터베이스**입니다. SQLite보다 빠르고 설정이 간단합니다.

### 주요 구성 요소

| 구성 요소 | 설명 | SQL 비유 |
|-----------|------|----------|
| **Box** | 데이터를 저장하는 컨테이너 | 테이블 (Table) |
| **TypeAdapter** | 커스텀 객체를 바이너리로 변환하는 변환기 | ORM 매퍼 |
| **@HiveType** | 클래스를 Hive 타입으로 등록하는 어노테이션 | 테이블 정의 |
| **@HiveField** | 필드를 Hive 필드로 등록하는 어노테이션 | 컬럼 정의 |
| **typeId** | 타입을 구분하는 고유 번호 (0~223) | - |

### Hive 사용 패턴 (이 앱에서)

```dart
// 1. 초기화 (main.dart - 앱 시작 시 1회)
await Hive.initFlutter();                    // Flutter 환경 초기화
Hive.registerAdapter(TodoAdapter());         // TypeAdapter 등록
await Hive.openBox<Todo>("todo");            // Box 열기

// 2. Box 참조 획득 (home_page.dart - 위젯 초기화 시)
Box<Todo> _box = Hive.box<Todo>("todo");     // 이미 열린 Box 가져오기

// 3. CRUD 연산
_box.values                                  // 전체 조회 (Iterable)
_box.put("key", todo)                        // 생성/수정 (upsert)
_box.delete("key")                           // 단일 삭제
_box.clear()                                 // 전체 삭제
```

---

## 앱 실행 흐름

```
┌─────────────────────────────────────────────────────────┐
│                    앱 시작 (main.dart)                    │
│                                                          │
│  1. Hive.initFlutter()        → Hive 초기화              │
│  2. registerAdapter()          → TodoAdapter 등록         │
│  3. openBox<Todo>("todo")      → Box 열기                │
│  4. runApp(MyApp())            → 앱 실행                 │
└──────────────────────┬──────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────┐
│               HomePage 초기화 (home_page.dart)           │
│                                                          │
│  1. Hive.box<Todo>("todo")    → Box 참조 획득            │
│  2. _box.values               → 저장된 Todo 전체 로드    │
│  3. _sort()                   → 미완료↑ 완료↓ 정렬       │
│  4. ValueListenableBuilder    → UI에 목록 표시            │
└──────────────────────┬──────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────┐
│                   사용자 인터랙션                         │
│                                                          │
│  [+ 버튼]     → TodoEditWidget(생성) → _updated()        │
│  [아이템 탭]  → TodoEditWidget(수정) → _updated()        │
│  [체크박스]   → _onChecked() → 완료 상태 토글             │
│  [길게 누르기] → 삭제 시트 → _onDeleted()                 │
└─────────────────────────────────────────────────────────┘
```

---

## 파일별 상세 설명

### 1. `main.dart` - 앱 진입점

**역할:** Hive 초기화 및 앱 루트 위젯 설정

```dart
void main() async {
  await Hive.initFlutter();              // Step 1: Hive 초기화
  Hive.registerAdapter(TodoAdapter());   // Step 2: 어댑터 등록
  await Hive.openBox<Todo>("todo");      // Step 3: Box 열기
  runApp(const MyApp());                 // Step 4: 앱 실행
}
```

- `Hive.initFlutter()` : 앱의 문서 디렉토리를 Hive의 저장 경로로 설정
- `registerAdapter()` : 커스텀 타입(Todo)을 Hive가 이해할 수 있도록 등록
- `openBox()` : "todo" Box를 열어 데이터 읽기/쓰기 준비 완료
- `MyApp` : `MaterialApp` → `HomePage`를 첫 화면으로 설정

---

### 2. `todo.dart` - 데이터 모델

**역할:** Hive에 저장되는 Todo 객체의 구조 정의

| 필드 | HiveField | 타입 | 설명 |
|------|-----------|------|------|
| `no` | 0 | `int` | 고유 ID (밀리초 타임스탬프) |
| `content` | 1 | `String` | 할 일 내용 |
| `tag` | 2 | `int` | 색상 태그 인덱스 (0~9) |
| `isCheck` | 3 | `bool` | 완료 여부 |
| `createdAt` | 4 | `DateTime` | 생성 일시 |
| `updatedAt` | 5 | `DateTime` | 수정 일시 |

**주요 메서드:**

| 메서드 | 용도 |
|--------|------|
| `Todo.create(content, tag)` | 새 Todo 생성 (no는 타임스탬프로 자동 부여) |
| `copyWith({...})` | 불변 객체의 일부 필드만 변경한 복사본 생성 |
| `toString()` | 디버깅용 문자열 출력 |

**@HiveField 규칙:**
- 한 번 부여한 필드 번호는 **절대 변경 불가** (기존 데이터 호환성)
- 필드 추가 시 **새로운 번호** 사용 (예: 다음은 @HiveField(6))
- 필드 삭제 시 해당 번호를 **재사용하지 않음**

---

### 3. `todo.g.dart` - TypeAdapter (자동 생성)

**역할:** Todo 객체 ↔ 바이너리 데이터 변환

- `build_runner`가 `@HiveType`, `@HiveField` 어노테이션을 기반으로 자동 생성
- `read()` : 바이너리 → Todo 객체 (역직렬화)
- `write()` : Todo 객체 → 바이너리 (직렬화)

**생성 명령어:**
```bash
flutter packages pub run build_runner build
```

> **주의:** 이 파일은 수동으로 수정하면 안 됩니다.

---

### 4. `todo_color.dart` - 색상 유틸리티

**역할:** Todo 태그에 사용되는 10가지 색상 관리

| 인덱스 | 색상 | 인덱스 | 색상 |
|--------|------|--------|------|
| 0 | 빨강 (red) | 5 | 딥 오렌지 (deepOrange) |
| 1 | 앰버 (amber) | 6 | 핑크 (pink) |
| 2 | 보라 (purpleAccent) | 7 | 틸 (teal) |
| 3 | 라이트블루 (lightBlue) | 8 | 인디고 (indigoAccent) |
| 4 | 파랑 (blue) | 9 | 초록 (green) |

| 메서드 | 용도 | 사용처 |
|--------|------|--------|
| `setColors()` | 전체 색상 리스트 반환 | TodoEditWidget (색상 선택 UI) |
| `colorOf(index)` | 인덱스 → 색상 변환 | TodoItemWidget (태그 색상 표시) |

---

### 5. `home_page.dart` - 메인 화면

**역할:** TODO 목록 표시 + 모든 CRUD 로직의 중심

#### 상태 관리

```dart
late Box<Todo> _box;                                    // Hive Box 참조
final ValueNotifier<List<Todo>> _todos = ValueNotifier([]); // 메모리 상태
```

- `_box` : Hive 디스크 저장소 (영구 저장)
- `_todos` : 메모리 상태 (UI 갱신 트리거)
- **양쪽을 항상 수동으로 동기화** 해야 합니다.

#### CRUD 메서드

| 메서드 | 동작 | Hive 연산 |
|--------|------|-----------|
| `_init()` | 초기 데이터 로드 | `_box.values` |
| `_updated(value)` | 생성 또는 수정 | `_box.put(key, todo)` |
| `_onChecked(todo, index)` | 완료 상태 토글 | `_box.put(key, todo)` |
| `_onDeleted(no)` | 단일 삭제 | `_box.delete(key)` |
| `_onDeleted(null)` | 전체 삭제 | `_box.clear()` |

#### 정렬 로직 (`_sort()`)

```
[미완료 항목] - 수정일 내림차순 (최신이 위)
──────────────────────────────────
[완료 항목]   - 수정일 내림차순 (최신이 위)
```

#### UI 위젯 트리

```
GestureDetector (빈 영역 탭 → 키보드 닫기)
└── Scaffold (다크 테마 배경)
    └── Stack
        └── CustomScrollView
            ├── SliverAppBar ("TODO with Hive" + 추가 버튼)
            └── SliverList (ValueListenableBuilder)
                └── TodoItemWidget × N개
```

---

### 6. `todo_edit_widget.dart` - 생성/수정 시트

**역할:** BottomSheet로 Todo 생성 또는 수정

#### 모드 구분

| 구분 | 조건 | 타이틀 | 버튼 |
|------|------|--------|------|
| 생성 모드 | `update == null` | CREATE TODO | SAVE |
| 수정 모드 | `update != null` | UPDATE TODO | CHANGE |

#### UI 구성

```
┌─────────────────────────────────────┐
│  CREATE TODO              SAVE      │  ← 헤더
├─────────────────────────────────────┤
│  content                            │  ← 레이블
│  ┌─────────────────────────────┐    │
│  │ (텍스트 입력 필드)           │    │  ← TextFormField
│  └─────────────────────────────┘    │
├─────────────────────────────────────┤
│  tag                                │  ← 레이블
│  🔴 🟡 🟣 🔵 🔵                     │  ← 색상 팔레트
│  🟠 🩷 🟢 🔵 🟢                     │    (Wrap으로 자동 줄바꿈)
└─────────────────────────────────────┘
```

#### 데이터 반환 방식

```dart
// SAVE/CHANGE 버튼 탭 시
Navigator.of(context).pop(
  update == null
    ? Todo.create(content, tagIndex)        // 생성: 새 Todo 반환
    : update!.copyWith(content, tag)        // 수정: 수정된 Todo 반환
);

// HomePage에서 수신
showModalBottomSheet(...).then(_updated);   // 반환된 Todo를 _updated()에서 처리
```

---

### 7. `todo_item_widget.dart` - 목록 아이템

**역할:** 개별 Todo 항목 표시 + 사용자 인터랙션 처리

#### UI 레이아웃

```
┌──────────────────────────────────────────┐
│ [☐] [●] 할 일 내용                       │
│          2024. 01. 15  (수정됨)           │
└──────────────────────────────────────────┘
  ↑    ↑    ↑               ↑
체크  태그  content      수정 여부
박스  색상  텍스트       (createdAt ≠ updatedAt일 때)
```

#### 인터랙션

| 동작 | 트리거 | 콜백 | 결과 |
|------|--------|------|------|
| 탭 | `onTap` | `onTap()` | 수정 시트 열기 |
| 길게 누르기 | `onLongPress` | `_showDeleteSheet()` | 삭제 옵션 표시 |
| 체크박스 탭 | 체크 아이콘 탭 | `onChecked(todo.copyWith(...))` | 완료 토글 |

#### 삭제 시트

| 옵션 | 전달값 | 동작 |
|------|--------|------|
| Delete | `todo.no` (int) | 해당 항목만 삭제 |
| All | `null` | 전체 삭제 |

---

## 데이터 흐름 (CRUD)

### Create (생성)

```
[+ 버튼 탭]
  → _showEditSheet() (update: null)
    → TodoEditWidget 표시 (생성 모드)
      → [SAVE 탭]
        → Todo.create(content, tag)
          → Navigator.pop(newTodo)
            → _updated(newTodo)
              → _box.put(key, todo)      ← Hive에 저장
              → _todos.value에 추가       ← 메모리 갱신
              → _sort()                   ← 정렬
              → UI 자동 갱신               ← ValueListenableBuilder
```

### Read (조회)

```
[앱 시작 / HomePage 초기화]
  → initState()
    → _box = Hive.box<Todo>("todo")     ← Box 참조 획득
    → _init()
      → _box.values                     ← Hive에서 전체 로드
      → _todos.value에 할당              ← 메모리에 저장
      → _sort()                          ← 정렬
      → UI 자동 갱신                      ← ValueListenableBuilder
```

### Update (수정)

```
[아이템 탭]
  → _showEditSheet(todo: existingTodo)
    → TodoEditWidget 표시 (수정 모드)
      → [CHANGE 탭]
        → update.copyWith(content, tag)
          → Navigator.pop(updatedTodo)
            → _updated(updatedTodo)
              → _box.put(key, todo)      ← Hive에 덮어쓰기
              → _todos.value에서 교체     ← 메모리 갱신
              → _sort()                   ← 정렬
              → UI 자동 갱신               ← ValueListenableBuilder
```

### Delete (삭제)

```
[아이템 길게 누르기]
  → _showDeleteSheet()
    → [Delete 탭]
      → _onDeleted(todo.no)
        → _box.delete(key)              ← Hive에서 삭제
        → _todos.value에서 제거          ← 메모리 갱신
        → UI 자동 갱신                    ← ValueListenableBuilder

    → [All 탭]
      → _onDeleted(null)
        → _box.clear()                  ← Hive 전체 삭제
        → _todos.value = []             ← 메모리 초기화
        → UI 자동 갱신                    ← ValueListenableBuilder
```

---

## 상태 관리 방식

### 현재 방식: ValueNotifier + ValueListenableBuilder

```
┌───────────────────────────────────────────────────┐
│  HomePage                                          │
│                                                    │
│  ┌──────────────────┐    ┌──────────────────────┐ │
│  │ Hive Box<Todo>   │◄──►│ ValueNotifier<List>  │ │
│  │ (디스크 영구저장)  │동기화│ (메모리, UI 트리거)   │ │
│  └──────────────────┘    └─────────┬────────────┘ │
│                                     │              │
│                          ValueListenableBuilder    │
│                                     │              │
│                              ┌──────▼──────┐      │
│                              │  SliverList  │      │
│                              │ (UI 자동갱신) │      │
│                              └─────────────┘      │
└───────────────────────────────────────────────────┘
```

### 특징

| 항목 | 설명 |
|------|------|
| 장점 | 간단하고 직관적, 외부 패키지 불필요 |
| 단점 | 위젯 내부 로컬 상태 (다른 화면에서 접근 불가) |
| 동기화 | Hive ↔ ValueNotifier 수동 동기화 필요 |
| 적합 규모 | 소규모 앱 / 샘플 프로젝트 |

---

## UI 구조

### 화면 구성

```
┌─────────────────────────────────┐
│  TODO  with Hive           [+]  │  ← SliverAppBar
├─────────────────────────────────┤
│                                  │
│  [☐] [●] 첫 번째 할 일          │  ← TodoItemWidget
│          2024. 01. 15            │
│                                  │
│  [☐] [●] 두 번째 할 일          │  ← TodoItemWidget
│          2024. 01. 14  (수정됨)  │
│                                  │
│  [☑] [●] 완료된 할 일           │  ← TodoItemWidget (완료)
│          2024. 01. 13            │
│                                  │
└─────────────────────────────────┘
     다크 테마 (배경: #1A1A1A)
```

### 색상 테마

| 요소 | 색상 | RGB |
|------|------|-----|
| 배경색 | 거의 검정 | (26, 26, 26) |
| 타이틀 "TODO" | 흰색 | white |
| 타이틀 "with Hive" | 회색 | (155, 155, 155) |
| 체크박스 | 회색 | (115, 115, 115) |
| 할 일 텍스트 | 흰색 (볼드) | white |
| 빈 텍스트 | 회색 | (115, 115, 115) |
| 날짜 | 밝은 회색 | (215, 215, 215) |

---

## 실행 방법

### 사전 요구사항

- Flutter SDK ^3.10.4
- Dart SDK (Flutter에 포함)

### 설치 및 실행

```bash
# 1. 의존성 설치
flutter pub get

# 2. 앱 실행
flutter run

# 3. (필요 시) TypeAdapter 재생성
flutter packages pub run build_runner build
```

---

## 참고 사항 및 개선 포인트

### 현재 코드의 알려진 이슈

1. **updatedAt 미갱신**: 수정 모드에서 `copyWith(content, tag)`만 변경하므로 `updatedAt`이 갱신되지 않습니다.
   ```dart
   // 현재 코드
   widget.update!.copyWith(content: controller.text, tag: current.value)
   // 개선안
   widget.update!.copyWith(content: controller.text, tag: current.value, updatedAt: DateTime.now())
   ```

2. **ValueNotifier dispose 누락**: `_HomePageState`에서 `_todos.dispose()`가 호출되지 않아 잠재적 메모리 누수가 있습니다.
   ```dart
   @override
   void dispose() {
     _todos.dispose();
     super.dispose();
   }
   ```

3. **오타**: "CHAGNGE" → "CHANGE"로 수정 필요

### 확장 시 고려사항

- **상태 관리 전환**: 앱 규모가 커지면 Riverpod/Bloc 등으로 전환하여 상태 공유 및 테스트 용이성 확보
- **Hive 마이그레이션**: 필드 추가/삭제 시 `@HiveField` 번호 규칙을 반드시 준수
- **에러 핸들링**: 현재 Hive 연산에 대한 try-catch가 없으므로 프로덕션 코드에서는 추가 필요
