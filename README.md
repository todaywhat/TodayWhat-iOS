# 오늘 뭐임 (iOS, watchOS)

## ✨ Summary
아이폰과 맥의 위젯, 애플워치, 맥의 Menubar에서 편리하게 급식/시간표를 확인할 수 있는 서비스

<br>

## 🔗 Links
AppStore - https://apps.apple.com/app/id1629567018

<br>

## 📸 Screenshots
![todaywhat-banner](https://github.com/user-attachments/assets/18ba98d4-949e-48a3-ba4c-946764d310c3)

<br>

<br>

## 📚 Tech Stack
- SwiftUI
- The Composable Architecture
- Swift Concurrency (Async/Await)
- GRDB.swift
- Swift Package Manager
- WidgetKit
- Watch Connectivity

<br>

## 🏃‍♀️ Run Project
- 프로젝트 루트에 XCConfig 폴더를 생성
- Debug.xcconfig, Release.xcconfig 파일을 생성
- xcconfig파일들 안에 `API_KEY = \(Nesi API Key Here)`
- TodayWhat.xcodeproj 실행

<br>

## ⭐️ Key Functions

### 위젯
- 홈화면 위젯에서 급식/시간표 정보 확인

<div>
  <img src="https://user-images.githubusercontent.com/74440939/213869859-d030a057-f588-41e9-95c4-ec009019a7a7.png" width="150">
  <img src="https://user-images.githubusercontent.com/74440939/213869902-fcaf9989-85cd-407a-ad44-5c9284cad4b2.png" width="150">
</div>


### 학교 설정
- 학교 검색
- 학년/반/번호 입력
- 학과 선택 (선택 사항)

<img src="https://user-images.githubusercontent.com/74440939/213870990-8a19fc76-255e-4400-b4a5-a4004aebbba8.png" width="150">


### 메인
- 오늘 급식 정보 확인
  - 알레르기가 포함된 급식일 시 글씨 색 변경
- 오늘 시간표 정보 확인
- 주말 스킵 기능

<div>
  <img src="https://user-images.githubusercontent.com/74440939/213870158-63102e91-66f6-48fb-b6e4-291be18168cb.png" width="150">
  <img src="https://user-images.githubusercontent.com/74440939/213870122-acf17e43-41bf-45de-8bf7-77882bad0426.png" width="150">
</div>


### 알레르기 설정
- 알레르기를 선택하여 로컬에 저장

<img src="https://user-images.githubusercontent.com/74440939/213870204-5f53a397-3ee5-4dea-93ff-56aef4541c7b.png" width="150">

### 애플워치에서 확인
- 아이폰과 연동하여 급식/시간표 확인

<div>
  <img src="https://user-images.githubusercontent.com/74440939/213870873-65efbf65-774b-4141-b996-2e6c0446a547.png" width="150">
  <img src="https://user-images.githubusercontent.com/74440939/213870876-056d91d3-2e57-4bb2-bc48-86e17585cc4f.png" width="150">
</div>
