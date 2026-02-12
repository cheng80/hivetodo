# 앱 스토어 출시 체크리스트

> Flutter 앱 출시 시 재사용 가능한 체크리스트. 앱별로 Bundle ID, applicationId 등은 수정하여 사용.

---

## 앱 스토어 (iOS)

- [ ] **Apple Developer Program 가입**
  - [developer.apple.com](https://developer.apple.com) 연간 $99

- [ ] **App Store Connect 앱 등록**
  - Bundle ID 설정
  - 앱 이름, 부제목, 설명 작성
  - 카테고리 선택

- [ ] **스크린샷 준비**
  - iPhone 6.7", 6.5", 5.5" (필수)
  - iPad (선택)

- [ ] **앱 정책·메타데이터**
  - 개인정보 처리방침 URL (데이터 수집 시)
  - 권한 사용 설명 (Info.plist - 알림 등)
  - 나이 등급, 연락처

- [ ] **TestFlight 배포**
  - 내부 테스트 → 외부 테스트
  - TestFlight 빌드 제출

- [ ] **App Store 제출**
  - 가격 책정 (무료/유료)
  - 심사 제출

---

## 플레이 스토어 (Android)

- [ ] **Google Play Console 개발자 등록**
  - [play.google.com/console](https://play.google.com/console) 일회성 $25

- [ ] **앱 등록**
  - applicationId 설정
  - 앱 이름, 짧은 설명, 전체 설명

- [ ] **스크린샷 준비**
  - 폰 7인치, 10인치 (필수)
  - 태블릿 (선택)

- [ ] **앱 정책·메타데이터**
  - 개인정보 처리방침 URL
  - 권한 사용 설명
  - 콘텐츠 등급 설문

- [ ] **서명 설정**
  - release keystore 생성·보관
  - `key.properties`, `build.gradle` 서명 설정

- [ ] **내부/알파/베타 테스트**
  - Internal testing track 등록
  - `requestReview()` 테스트 시 Internal app sharing 또는 Internal test track 사용

- [ ] **프로덕션 출시**
  - 국가·가격 설정
  - 심사 제출

---

## 공통 (앱 코드)

- [ ] **스토어 평점/리뷰 팝업**
  - 패키지: `in_app_review: ^2.0.11`
  - **구현 전 참고**: `docs/IN_APP_REVIEW_GUIDE.md`
  - `requestReview()`: 적절한 시점에 자동 호출 (버튼 사용 금지)
  - `openStoreListing()`: Drawer/설정 "평점 남기기" 버튼
  - iOS: `appStoreId` (App Store Connect > Apple ID)

- [ ] **릴리즈 빌드 점검**
  - `flutter build ios --release` / `flutter build appbundle --release`
  - 프로덕션 설정 확인 (API 키, 디버그 로그 제거 등)
