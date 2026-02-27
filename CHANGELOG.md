# Changelog

모든 주요 변경 사항을 이 문서에 기록합니다.

---

## [1.0.1+3] - 2026-02-17

### 개선
- 태블릿(iPad / Android 태블릿) 바텀시트 최대 폭 제한 (640px)
  - Todo 생성/수정, 삭제, 언어 선택, 태그 편집 등 모든 바텀시트 적용
  - 삭제 시트 고정 높이 제거 → SafeArea + 자동 높이로 변경
- 태그 편집 시트에서 빈 영역 터치 시 키보드 자동 숨김

### 수정
- Android Exact Alarm 권한 제거 (Play Console 정책 준수)
  - `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM` 권한 삭제
  - `AndroidScheduleMode.inexactAllowWhileIdle`로 전환
- iOS 앱 아이콘 알파 채널 제거 (App Store 요구사항)
- Android 12 스플래시 이미지 원형 마스크 대응 (패딩 적용)
- iOS 앱 뱃지 카운트 동기화 개선 (예약 알림 순서 재정렬)
- iPadOS 바텀시트 즉시 닫힘 버그 우회 (`isDismissible: false`)
- 릴리즈 빌드 시 디버그 메뉴(더미 데이터, 알람 상태) 숨김 처리

### 문서
- 스토어 메타데이터 URL 경로 수정
- 출시 체크리스트에 버전 관리 명령어 추가
- Edge-to-Edge 대응 항목 todo에 추가

### 출시 노트 (Google Play / App Store)

**한국어 (KO)**
```
v1.0.1 업데이트

• 태블릿 화면 최적화: iPad 및 Android 태블릿에서 편집 화면이 더 보기 좋게 개선되었습니다.
• 알림 안정성 향상: 알림 예약 방식을 개선하여 더 안정적으로 동작합니다.
• 스플래시 화면 수정: Android 12 이상에서 앱 시작 화면이 정상 표시됩니다.
• 알림 배지 정확도 개선: 앱 아이콘 배지 숫자가 더 정확하게 표시됩니다.
• 기타 버그 수정 및 안정성 개선
```

**영어 (EN)**
```
v1.0.1 Update

• Tablet optimization: Improved editing screens for iPad and Android tablets.
• Notification stability: Enhanced notification scheduling for more reliable reminders.
• Splash screen fix: App launch screen now displays correctly on Android 12+.
• Badge accuracy: App icon badge count is now more accurate.
• Other bug fixes and stability improvements
```

---

## [1.0.0+2] - 2026-02 (첫 출시)

### 주요 기능
- Todo CRUD (생성/수정/삭제/완료 토글)
- 색상 태그 시스템 (15개 프리셋 + 전체 색상)
- 태그별 필터링 / 상태 필터 (전체/미완료/완료)
- 마감일 설정 및 로컬 알림 (날짜 + 시간)
- 마감일 필터 (알람 아이콘 토글)
- 드래그 앤 드롭 순서 변경
- 검색 기능
- 다국어 지원 (한국어, 영어, 일본어, 중국어 간체/번체)
- 다크/라이트 테마
- 화면 꺼짐 방지 (wakelock)
- 인앱 리뷰 요청
- 온보딩 튜토리얼 (showcaseview)
- 앱 아이콘 & 스플래시 스크린