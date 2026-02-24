# TagDo 스토어 등록 메타데이터 (Google Play / Apple App Store)

최종 업데이트: 2026-02-17  
앱: `TagDo` (`com...` 패키지명은 실제 값으로 교체)

이 문서는 **공식 문서 기준 필수 항목**과, 바로 복붙 가능한 **TagDo 입력안(ko-KR / en-US)** 을 함께 정리한 등록용 메타데이터 문서입니다.

---

## 1) 공식 기준으로 확인한 필수 항목

### A. Google Play (Play Console)

#### 스토어 리스팅 필수
- `App name` (최대 30자)
- `Short description` (최대 80자)
- `Full description` (최대 4000자)
- `App icon` (512 x 512 PNG, max 1024KB)
- `Feature graphic` (1024 x 500, JPG 또는 24-bit PNG)
- `Screenshots` (게시를 위해 최소 2장, 최대 8장/디바이스 타입)
- `Contact email` (필수)

#### 심사/정책 제출 필수(앱 콘텐츠)
- `Data safety form` (모든 공개 앱 필수)
- `Privacy policy URL` (Data safety 및 사용자 데이터 정책 연계)
- `Ads declaration` (광고 포함 여부)
- `Target audience and content`
- `Content rating`
- `App access` (로그인/제한 기능이 있으면 접근 정보 필수)

---

### B. Apple App Store (App Store Connect)

#### 앱 정보(App Information) / 버전 정보 필수
- `Name` (2~30자)
- `Subtitle` (최대 30자)
- `Privacy Policy URL` (iOS/macOS 필수)
- `Age Rating` (필수)
- `Primary Category` (필수)
- `Screenshots` (디바이스 타입별 1~10장, 필수)
- `Description` (최대 4000자, 필수)
- `Keywords` (최대 100 bytes, 필수)
- `Support URL` (필수)
- `Copyright` (필수)

#### 앱 심사 정보(App Review Information) 필수
- `Contact name`
- `Contact email`
- `Contact phone`
- `Demo account` (로그인 앱인 경우)

#### 참고 (선택 항목)
- `Promotional Text` (최대 170자, 선택)
- `Marketing URL` (선택)

---

## 2) TagDo 제출용 메타데이터 초안

아래 값은 콘솔 입력용 초안입니다. URL/패키지명/전화번호는 실제 운영값으로 교체하세요.

### A. 공통 기본 정보

- 앱 이름: `TagDo`
- 카테고리: `Productivity`
- 지원 이메일: `cheng80@gmail.com`
- 개인정보처리방침 URL: `https://cheng80.myqnapcloud.com/tagdo/privacy.html`
- 이용약관 URL: `https://cheng80.myqnapcloud.com/tagdo/terms.html`
- 지원 URL(Apple): `https://cheng80.myqnapcloud.com/tagdo/index.html`  
  (권장: support 전용 페이지를 만들어 이메일/문의 방법을 명시)

---

## 3) Google Play 입력안 (ko-KR / en-US)

### A. Product details

#### ko-KR
- App name: `TagDo`
- Short description (<=80):
  - `태그로 정리하고 마감일 알림까지 챙기는 심플한 할 일 관리 앱`
- Full description (<=4000):

```text
TagDo는 태그 기반으로 할 일을 쉽고 빠르게 관리하는 Todo 앱입니다.

[핵심 기능]
- 태그/색상으로 할 일 분류
- 마감일 설정 및 알림
- 완료/미완료 상태 관리
- 다크 모드/라이트 모드
- 다국어 지원 (한국어, 영어, 일본어, 중국어)

[개인정보/데이터]
- 모든 데이터는 기기에 로컬 저장됩니다.
- 서버로 개인정보를 수집/전송하지 않습니다.

[권한 안내]
- 알림 권한(선택): 마감일 알림 기능에 사용됩니다.
- 알림 권한을 허용하지 않으면 알림 기능은 제한되지만, 기본 할 일 관리 기능은 이용할 수 있습니다.
```

#### en-US
- App name: `TagDo`
- Short description (<=80):
  - `Simple todo app with tags and due-date reminders.`
- Full description (<=4000):

```text
TagDo is a simple and focused todo app that helps you organize tasks with tags.

[Key Features]
- Organize todos with custom tags and colors
- Set due dates and receive reminders
- Manage completed and pending tasks
- Light / Dark theme support
- Multi-language support (Korean, English, Japanese, Chinese)

[Privacy & Data]
- All data is stored locally on your device.
- No personal data is collected or transmitted to external servers.

[Permission]
- Notification permission (optional): used for due-date reminders.
- If denied, reminder notifications are unavailable, but core todo features still work.
```

### A-1. Store tags (Play Console, 최대 5개)

Google Play `스토어 설정 > 태그 관리`에서 앱 특성을 설명하는 태그를 최대 5개 선택할 수 있습니다.

TagDo 권장(우선순위):
- `할 일 목록` 또는 `To-do list`
- `작업 관리` 또는 `Task management`
- `생산성` 또는 `Productivity`
- `알림` 또는 `Reminder`
- `체크리스트` 또는 `Checklist`

선택 기준:
- 앱의 핵심 사용 시나리오(할 일/체크/알림)에 직접 연관된 태그 우선
- 게임/엔터테인먼트/금융 등 비관련 태그는 제외
- 콘솔에 노출되는 실제 태그 명칭은 계정/언어/카테고리에 따라 일부 다를 수 있으므로, 의미가 가장 가까운 항목으로 선택

---

### B. Graphics checklist (Play)

#### Play 필수/권장 이미지 규격 (픽셀)

| 항목 | 필수 여부 | 규격 |
|---|---|---|
| App icon | 필수 | `512 x 512` PNG (32-bit, alpha), 최대 1024KB |
| Feature graphic | 필수 | `1024 x 500` JPG 또는 24-bit PNG |
| Phone screenshots | 필수 | 최소 2장, 최대 8장/기기타입 |

#### Play 스크린샷 실제 제작 해상도 (TagDo 권장)

Play는 폭넓은 범위를 허용하므로, 아래 2종만 준비해도 안정적으로 운영 가능합니다.

- 세로 기본본(권장): `1080 x 1920` (9:16)
- 가로 기본본(선택): `1920 x 1080` (16:9)

추가 규칙(공식):
- 최대 한 변 `3840px`
- 긴 변은 짧은 변의 2배 초과 불가

노출 최적화(권장):
- 앱은 `1080px 이상` 스크린샷 4장 이상 권장
- 태블릿 노출을 원하면 태블릿 스크린샷도 별도 업로드 권장

---

### C. Data safety 입력 가이드 (TagDo 현재 코드 기준)

> 최종 제출 전, 포함 SDK/라이브러리의 실제 데이터 전송 동작을 반드시 재검증하세요.

- 앱이 사용자 데이터를 기기 밖으로 전송하지 않는다면:
  - Data collected: `No`
  - Data shared: `No`
- Privacy policy URL: 필수 입력
- Notification permission은 **권한 항목**이며, Data safety의 데이터 수집 여부와는 별도로 실제 전송 여부로 판단

---

## 4) Apple App Store 입력안 (ko / en)

### A. App Information

- Name: `TagDo` (<=30)
- Subtitle (ko): `태그로 정리하는 할 일 관리` (<=30)
- Subtitle (en): `Tag-based Todo Planner` (<=30)
- Primary Category: `Productivity`
- Age Rating: 일반 생산성 앱 기준 설문 응답
- Privacy Policy URL: `https://cheng80.myqnapcloud.com/tagdo/privacy.html`

---

### B. Version metadata (localized)

#### Promotional Text (선택, <=170)
- ko:
  - `태그와 알림으로 할 일을 더 간단하게 관리하세요. 모든 데이터는 기기에만 저장됩니다.`
- en:
  - `Manage tasks with tags and reminders. Your data stays on your device.`

#### Description (필수, <=4000)

ko:
```text
TagDo는 태그 기반으로 할 일을 효율적으로 관리할 수 있는 Todo 앱입니다.

주요 기능
- 태그/색상으로 할 일 분류
- 마감일 알림
- 다크 모드/라이트 모드
- 다국어 지원

개인정보 및 데이터
- 데이터는 기기에 로컬 저장됩니다.
- 서버로 개인정보를 수집/전송하지 않습니다.

권한
- 알림 권한(선택): 마감일 알림 기능에 사용
- 미허용 시 알림 기능은 제한되며, 기본 기능은 정상 동작
```

en:
```text
TagDo helps you manage your tasks efficiently with a simple tag-based workflow.

Key features
- Organize todos with tags and colors
- Due-date reminders
- Light and dark themes
- Multi-language support

Privacy and data
- Data is stored locally on your device.
- No personal data is collected or sent to external servers.

Permission
- Notification permission (optional): used for reminder alerts
- If denied, reminder alerts are limited while core features still work
```

#### Keywords (필수, <=100 bytes)

- ko (예시):  
  `할일,투두,태그,알림,체크리스트,생산성,오프라인`
- en (예시):  
  `todo,task,reminder,planner,productivity,tag,checklist,offline`

#### Support URL (필수)
- `https://cheng80.myqnapcloud.com/tagdo/index.html`

#### Marketing URL (선택)
- `https://cheng80.myqnapcloud.com/tagdo/index.html`

#### Copyright (필수)
- `2026 KIM TAEK KWON` (권리자명 기준 권장)
- 참고: App Store의 Copyright는 **도메인명보다 권리자(개인/법인) 명칭**이 안전합니다.
- 웹페이지 푸터 표기는 도메인 기준(`© 2026 cheng80.myqnapcloud.com`)으로 운영해도 무방합니다.

---

### C. Screenshot checklist (Apple)

프로젝트 설정 확인 결과:
- `ios/Runner.xcodeproj/project.pbxproj` → `TARGETED_DEVICE_FAMILY = "1,2"`
- 즉, **TagDo는 iPhone + iPad 지원 앱**이며 두 기기군 스크린샷이 모두 필요합니다.

#### Apple 스크린샷 필수 규칙

- 포맷: `.jpeg`, `.jpg`, `.png`
- 수량: 디바이스 타입별 `1~10장`
- iPhone용 최소 1장 이상 필수
- iPad 지원 앱은 iPad용 최소 1장 이상 필수

#### Apple 실제 제작 해상도 (TagDo 준비 기준)

| 기기군 | 준비 권장 해상도(세로) | 비고 |
|---|---:|---|
| iPhone (6.9") | `1320 x 2868` | 최신 대화면 기준, 이 해상도 세트 권장 |
| iPhone (대체) | `1290 x 2796` 또는 `1260 x 2736` | 6.9" 허용 해상도 대체값 |
| iPhone (6.5") | `1284 x 2778` 또는 `1242 x 2688` | 6.9" 미제공 시 사용 |
| iPad (13") | `2064 x 2752` | iPad 지원 앱 권장 기본 |
| iPad (대체) | `2048 x 2732` | 13" 허용 해상도 대체값 |

TagDo 권장 최소 세트(실무):
- iPhone 6.9" 세로 `1320 x 2868`로 5장
- iPad 13" 세로 `2064 x 2752`로 5장
- 총 10장(스토어 설명 흐름: 목록 → 추가/수정 → 태그 → 알림 → 설정)

---

## 5) 제출 전 최종 체크

- [x] NAS 도메인 HTTPS URL 확정 (`cheng80.myqnapcloud.com`)
- [x] 최종 배포 경로 확인 (`docs/web`가 웹 루트이므로 URL은 `/tagdo/...` 형태 사용)
- [ ] Play/App Store 각각 locale 별 텍스트 입력
- [ ] 스크린샷 최신 UI 기준으로 교체
- [ ] Play Data safety 실제 SDK 동작 재검증
- [ ] Apple Support URL 페이지에 연락 방법(이메일/문의 정보) 명시
- [ ] 권한 설명 문구가 실제 앱 동작과 1:1 일치하는지 재확인

---

## 6) 참고한 공식 문서

### Google Play
- Create and set up your app  
  https://support.google.com/googleplay/android-developer/answer/9859152
- Add preview assets to showcase your app  
  https://support.google.com/googleplay/android-developer/answer/9866151
- Provide information for Google Play's Data safety section  
  https://support.google.com/googleplay/android-developer/answer/10787469
- Prepare your app for review  
  https://support.google.com/googleplay/android-developer/answer/9859455

### Apple App Store Connect
- App information  
  https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/
- Platform version information  
  https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information/
- Required, localizable, and editable properties  
  https://developer.apple.com/help/app-store-connect/reference/app-information/required-localizable-and-editable-properties
- Screenshot specifications  
  https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications

