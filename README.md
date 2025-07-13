
# 🏥 OlymForce | 올림포스 – 의료 내시경 A/S 서비스 디지털 혁신 프로젝트

<p align="center">
 <img width="200" alt="Image" src="https://github.com/user-attachments/assets/fb1c2e82-750c-4745-8b4a-7e5cfc2d40b0" />
</p>

---

## 🔎 기업 소개

**OlymForce**는 의료기기 A/S 서비스를 전문적으로 개선하기 위해 Salesforce 생태계를 기반으로 디지털 전환을 추진하는 기업입니다.  
본 프로젝트는 **의료용 내시경 장비의 A/S 접수부터 처리, 완료, 승인까지의 모든 흐름을 Salesforce Service Cloud, Experience Cloud, Sales Cloud로 통합**하는 것을 목표로 합니다.

---

## 📌 프로젝트 개요

- **목표:** A/S 처리 속도 개선, 정보 일원화, 고객 응대 품질 향상
- **기술 스택:** Salesforce Cloud (Service, Sales, Experience), Apex, Flow, LWC, GPT 연동
- **개발 범위:** 고객 요청 → 케이스 생성 → 자동 요약 → 승인 → 상태 변경 → SLA 관리

---

## 🧭 기업 A/S 프로세스

> 📷 아래 다이어그램은 A/S 프로세스를 시각화한 이미지입니다.

<p align="center">
  <img width="700" height="700" alt="Image" src="https://github.com/user-attachments/assets/5317336a-fe30-44bd-80f7-e5b3b30e8f1e" />
</p>

---

## 🧱 ERD (데이터 모델)

> 📷 본 프로젝트에 사용된 Salesforce 객체 간 구조를 나타낸 ERD입니다.

<p align="center">
  <img width="1000" alt="Image" src="https://github.com/user-attachments/assets/858a1c49-e67f-423e-ba6d-b5e63fadcb3d" />
</p>

---

## 📋 요구사항 명세서
<p align="center">
  <img width="1000" alt="Image" src="https://github.com/user-attachments/assets/ef9991ea-a634-414a-af3e-d3983c099951" />
</p>


---

## 🚀 주요 기능 설명

### 1. 🧠 AI 기반 케이스 요약 자동 생성 (`Case_Summary_Auto_Fill`)

- 케이스가 생성되거나 업데이트될 때, GPT API를 통해 증상 설명 요약을 자동 생성
- 사용자는 별도 입력 없이 정리된 설명을 참조할 수 있어 커뮤니케이션 효율 증가
- Apex 없이 Flow에서 `generatePromptResponse` 액션을 통해 구현
- 트리거 기반 자동 실행으로 관리자 유지보수 용이

📷  
<p align="center">
  <img width="600" alt="Image" src="https://github.com/user-attachments/assets/a335f31f-21f1-4fc4-a6e8-aba54a03e2da" />
</p>

---

### 2. 🧾 Task에서 Case 직접 생성하는 화면 플로우 (`Create_Case_From_Task`)

- Task(업무) 레코드에서 연결된 Contact, Asset을 선택 후 Case 생성 가능
- 전화/이메일/Web 유형에 따라 자동 분기되어 케이스 필드 자동 세팅
- Experience Cloud에서도 사용 가능하도록 설계
- 사용자 입력에 따른 동적 구성으로 관리자 없이도 직관적인 사용 가능

📷  
<p align="center">
<img width="1000" alt="Image" src="https://github.com/user-attachments/assets/47afaf65-3285-4cbd-b9dc-53c642e941db" />
  <br>
  <img width="500" alt="Image" src="https://github.com/user-attachments/assets/3135885f-e9f0-48ae-96f8-6cc645db97de" />
</p>

---

### 3. 🎛 상담사 상태 설정 기능 (`agentStatusManager` LWC)

- 상담사의 근무 상태를 실시간으로 표시 및 변경할 수 있는 유틸리티 바 컴포넌트
- LWC UI에서 선택 시, Apex 호출을 통해 사용자 상태 업데이트
- 상태별 색상 및 텍스트 자동 반영
- 상담 가능/불가/자리비움/오프라인 4단계 지원

📷  
<p align="center">
 <img width="500" alt="Image" src="https://github.com/user-attachments/assets/f0f19a08-fda5-49d0-81eb-dc28d6084b6c" />
</p>

---

### 4. 👥 케이스에 연결된 연락처 선택기 (`displayContacts` LWC)

- 케이스 상세 페이지에 배치 가능한 LWC로 관련된 연락처 목록을 불러와 선택
- 선택 시 버튼 UI가 변경되어 직관적이며, 서버에 바로 저장됨
- Apex 호출 → 데이터 반영 후 페이지 자동 새로고침

📷  
<p align="center">
  <img width="500" alt="Image" src="https://github.com/user-attachments/assets/5277618f-6988-40ea-8ef0-c59c5a771c52" />
</p>

---

### 5. 🤖 GPT 기반 고객 응대 도우미 (`gptCaseHelper`)

- GPT를 활용한 고객 질문 자동 응답 도우미
- LWC 채팅 UI로 사용자가 입력한 내용에 대해 대화형 응답 제공
- 기존 케이스와 연동하여 고객 정보 기반으로 맥락 파악 가능
- Experience Cloud / App Page / Record Page 등 다양한 위치에 배치 가능

📷  
<p align="center">
  <img width="500" alt="Image" src="https://github.com/user-attachments/assets/2e3c80ab-8ac8-43fc-b848-6fee21067229" />
</p>

---

## 🔧 기타 Apex 기능 요약

| 클래스명 | 목적 및 사용 이유 |
|----------|------------------|
| `AgentStatusController` | 상담사 상태 저장 및 조회 (LWC용 Apex Controller) |
| `GPTController` | GPT API 연동 처리 및 응답 반환 |
| `CaseCountOnAgentStatusHandler` | 상담사별 케이스 건수 집계 |
| `CaseEntitlementAssignment` | 케이스별 SLA Entitlement 자동 할당 |
| `CaseMilestoneHandler`, `MilestoneUtils` | 케이스 마일스톤 시간 계산 및 체크 |
| `ClearOwnerOnCaseInsertHandler` | 신규 케이스 생성 시 소유자 초기화 |
| `SubmitForApprovalForCaseRequest` | 승인 프로세스 제출 자동화 |
| `CaseTriggerHandlerHelper` | 케이스 관련 트리거 로직 공통 처리 |
| `TaskController` | Task 기반 Case 생성 제어용 Apex |

---

## 🛠 기술 스택

| 분류 | 사용 기술 |
|------|-----------|
| 플랫폼 | Salesforce Service Cloud, Sales Cloud, Experience Cloud |
| 백엔드 | Apex (Controller, Trigger, Utility Class) |
| 프론트엔드 | Lightning Web Components (LWC), Flow |
| 자동화 | Record-Triggered Flow, Approval Process |
| 외부 연동 | GPT API (OpenAI) |
| 버전관리 | GitHub, VS Code (Salesforce Extension Pack) |
| 기타 | SLDS, Utility Bar, Dynamic Forms, OmniChannel 일부 |

---

## 📚 참고자료

- [Salesforce 공식 개발자 문서](https://developer.salesforce.com/docs)
- [LWC 문서](https://developer.salesforce.com/docs/component-library/documentation/en/lwc)
- [Salesforce Flow 가이드](https://help.salesforce.com/s/articleView?id=sf.flow_build.htm)
- [OpenAI API 문서](https://platform.openai.com/docs)

---

