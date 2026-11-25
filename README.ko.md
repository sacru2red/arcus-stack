# 🏹 ARCUS-STACK (`arcus-stack`)

<p align="center">
  <a href="./README.md">English</a> |
  <strong>한국어</strong> |
  <a href="./README.ja.md">日本語</a> |
  <a href="./README.zh-CN.md">简体中文</a> |
  <a href="./README.es.md">Español</a>
</p>

> **A**gent **R**ules, **C**ommands & **U**niversal **S**kills  
> *(**SACRU**의 애너그램 — 5대 에이전트 통합 스킬 & 워크플로우 스택)*

**`arcus-stack`** 은 **Antigravity (`agy`), Claude Code, Codex, Cursor, OpenCode** 5대 AI 코딩 에이전트 어디서나 동일하게 작동하는 범용 스킬 & 워크플로우 스택입니다.

---

## 💡 왜 만들었나요?

**T3 Code**나 **Orca** 같은 멀티 에이전트 환경에서 작업하다 보면, 상황에 따라 여러 에이전트(`agy`, Claude Code, Codex, Cursor, OpenCode)를 번갈아 호출하거나 동시에 띄워 쓰게 됩니다. 하지만 도구마다 스킬을 읽는 경로와 설정 문법이 제각각이라, **내가 쓰던 좋은 스킬을 다른 에이전트를 호출할 때는 똑같이 쓸 수 없다는 점**이 매우 불편했습니다.

**`arcus-stack` 은 이 파편화 문제를 해결하기 위해 만들었습니다.** 무거운 MCP 서버 의존성 없이 5개 도구가 공통으로 인식하는 표준 `SKILL.md`와 `AGENTS.md` 규격만 사용하여, 어떤 환경에서 어떤 에이전트를 부르든 똑같은 스킬과 작업 원칙을 바로 사용할 수 있습니다.

다음 5개의 오픈소스 프로젝트의 핵심 장점을 하나로 모았습니다:
- **[`pstack`](https://github.com/cursor/plugins/tree/main/pstack)**: *"빠르게 가려면 먼저 깊게 파고들어라."* (근본 원인 파악, 최소한의 코드 변경, 검증 가능한 코드 작성)
- **[`oh-my-openagent`](https://github.com/code-yeongyu/oh-my-openagent)**: 작업이 끝날 때까지 스스로 반복 실행하는 `ultrawork` 루프와 전략·실행 분리
- **[`oh-my-claudecode`](https://github.com/yeachan-heo/oh-my-claudecode)**: 설계·구현·검증 역할 분담 및 자율 실행 워크플로우
- **[`oh-my-antigravity`](https://github.com/Joonghyun-Lee-Frieren/oh-my-antigravity)**: 단계별 품질 가드레일과 실제 실행 증거 기반의 완료 검증
- **[`GoogleChrome/modern-web-guidance`](https://github.com/GoogleChrome/modern-web-guidance)**: HTML, CSS, 클라이언트 JS 작업 시 최신 웹 표준 가이드를 실시간 조회(`npx -y modern-web-guidance@latest`)하는 모던 웹 베스트 프랙티스 (Apache-2.0)

나아가 `arcus-stack`을 써야 하는 이유는 단순한 멀티 에이전트 호환성에 그치지 않습니다. 기존 AI 코딩의 고질적인 한계 두 가지를 구조적으로 해결합니다:

### 1. 내 편향에 속지 않는 컨텍스트 격리 리뷰와 지적 장부 (`arcus-review`)

설계나 구현을 진행한 바로 그 세션에서 검토까지 수행하면, 에이전트는 자신이 왜 그 전제를 택했는지 이미 알고 있어 전제 자체를 의심하지 않고 함께 버린 대안은 다시 꺼내지 않습니다. **맥락을 공유한 검토자는 사각지대도 공유합니다.** `arcus-review`는 이를 막기 위해 **컨텍스트 격리**와 **지적 장부(Review Ledger)** 로 동작합니다:

- **구현 컨텍스트와 격리된 리뷰**: 검토할 커밋이나 스냅샷을 고정한 뒤, 작성자의 대화 맥락이나 변명에 오염되지 않은 새로운 격리 서브에이전트가 설계 문서와 코드를 처음 보는 눈으로 검토합니다. 레포 내부에만 머물지 않고 외부 공식 레퍼런스를 교차 확인하며, 배경지식이 없는 독자에게 설계 문서만 주었을 때 온전히 이해되는지 시험합니다.
- **지적 장부 (Review Ledger — `F-01`, `F-02`, ...)**: 리뷰마다 발견된 문제들을 고유 번호가 붙은 장부 테이블로 관리하며, 지적 장부와 작성자의 답글 영역을 물리적으로 분리합니다.
- **선(先) 코드 확인 · 후(後) 답글 대조**: 2회차 이후 리뷰에서는 새 코드를 보거나 **작성자의 답글(해명)을 열어보기 전에, 고정된 최신 코드·문서 스냅샷만 먼저 보고** 장부의 기존 지적 사항이 실제로 해결됐는지(`RESOLVED`), 미해결인지(`UNRESOLVED`), 반박이 타당한지(`VALID_PUSHBACK`), 이견이 갈리는지(`DISPUTED`)부터 먼저 판정합니다:

| ID | 회차 | 고정 스냅샷 | 심각도 | 대상 위치 | 문제 시나리오 및 요구 조치 | 상태 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `F-01` | R1 | `4e058ee` | `CRITICAL` | `worker.md:7` | 자율 실행 서브에이전트 도중 질문 호출 시 작업이 멈춤. 최상위 턴으로 질문 위임 필요. | `RESOLVED` |
| `F-02` | R1 | `4e058ee` | `HIGH` | `SKILL.md:44` | 부분 설치 시 상대 경로 참조 실패 가능성. 본문 내 폴백 규칙 내장. | `VALID_PUSHBACK` |

*(판정 상태: `OPEN` 신규 · `RESOLVED` 해결됨 · `UNRESOLVED` 미해결 · `VALID_PUSHBACK` 반박 타당 · `DISPUTED` 이견/결정 필요)*

### 2. 구식 학습 데이터를 넘어서는 모던 웹 표준 & 브라우저 호환성 자동 적용 (`modern-web-guidance`)

AI 모델은 학습 시점의 한계 때문에 이미 최신 CSS나 웹 표준 API로 깔끔하게 해결된 기능도 구식 JS 땜질 코드로 짜는 경우가 많습니다. `arcus-stack`을 쓰면 HTML, CSS, 클라이언트 JS(React, Vue, Svelte 등 프레임워크 내부 포함) 작업을 할 때 별도의 스킬을 직접 호출하거나 매번 `caniuse.com`에 들어가 브라우저 지원 여부를 확인할 필요가 없습니다. 설계(`arcus-plan`), 구현(`arcus-work-loop`), 리뷰(`arcus-review`) 단계에서 내부적으로 `modern-web-guidance`가 자동 실행됩니다:

1. **최신 웹 표준 가이드 실시간 조회**: 에이전트가 자신의 오래된 학습 기억에 의존해 구식 JS 땜질 코드를 짜는 대신, 작업 시작 전에 `npx -y modern-web-guidance@latest search "<기능>"` 및 `retrieve "<가이드ID>"`를 자동 호출해 Google Chrome 팀의 최신 웹 표준 가이드를 먼저 읽습니다.
2. **브라우저 지원 현황(Baseline) 자동 판별**: 조회된 가이드 문서에는 각 웹 API의 **Web Platform Baseline 등급**(`Widely available`, `Newly available`, `Limited availability`)과 4대 브라우저(Chrome, Edge, Firefox, Safari)별 지원 버전이 함께 포함되어 있습니다.
3. **맞춤형 폴백(Fallback) 코드 자동 적용**: 모든 브라우저에 널리 보급된 기능(`Widely available`)은 군더더기 없이 바로 사용하고, 일부 브라우저에서 아직 지원하지 않는 최신 기능은 가이드에 명시된 `@supports`나 점진적 향상(Graceful Degradation) 폴백 코드를 자동으로 함께 작성합니다.

---

## 📦 코어 스킬 (`arcus-*`)

| 스킬 이름 | 분류 | 역할 및 설명 |
| :--- | :--- | :--- |
| **`arcus-mode`** | 마스터 모드 | 불필요한 미사여구 없이 간결한 답변과 검증된 코드만 받도록 에이전트의 기본 작업 수준을 높여줍니다. 작업 성격에 맞춰 24가지 엔지니어링 원칙과 22가지 플레이북, 서브에이전트 위임 규칙을 자동으로 적용합니다. |
| **`arcus-plan`** | 설계 및 체크리스트 | 코드를 바로 고치다 방향이 꼬이거나 요구사항을 빠뜨리는 일을 막아줍니다. 코딩 전에 문제의 근본 원인과 변경 영향 범위를 파악하고, 현재 작업 목표에 맞는 단계별 실행·검증 체크리스트(`- [ ]`)를 만들어 줍니다. |
| **`arcus-work-loop`** | 자율 실행 루프 | 중간에 멈추거나 덜 끝난 코드를 남기지 않고 작업을 끝까지 완수합니다. 작업 체크리스트를 하나씩 수행하고 실제 테스트와 빌드 검증을 통과한 항목만 완료(`- [x]`)로 채워 나가며 끝까지 반복 진행합니다. |
| **`arcus-review`** | 격리된 계획·코드 리뷰 | 작성자의 맥락과 편향을 물려받지 않도록 격리된 서브에이전트에서 고정된 스냅샷을 기준으로 설계와 코드를 검토합니다. 배경지식 없는 독자 관점의 문서 이해도 시험, 외부 레퍼런스 대조, 지적 장부 기반의 선(先) 코드 확인 리뷰를 수행합니다. |
| **`arcus-in-your-own-words`** | 목표 확인 | 에이전트가 내 의도를 잘못 이해하고 엉뚱한 코드를 짜는 시간 낭비를 줄여줍니다. 작업을 시작하기 전에 사용자가 원하는 목표와 해결하려는 핵심 문제를 에이전트 자신의 말로 요약해 확인받습니다. |
| **`arcus-create-verification`** | 앱 검증 스킬 생성 | 기능이 바뀔 때마다 사람이 일일이 앱을 켜서 수동으로 확인하는 수고를 덜어줍니다. 실제 사용자처럼 앱을 실행하고 주요 기능을 조작해 정상 동작 증거를 남기는 프로젝트 전용 검증 스킬(`verify-<앱이름>`)을 만들어 줍니다. |
| **`arcus-maintain-verification`** | 앱 검증 스킬 갱신 | 앱 코드가 바뀔 때 기존 검증 절차가 낡아서 깨지는 문제를 막아줍니다. 변경된 소스 코드와 실제 앱 실행 결과를 대조해 프로젝트의 검증 스킬과 기능 목록을 최신 상태로 유지합니다. |
| **`arcus-ketchup`** | 진행 상황 요약 | 긴 대화 기록을 처음부터 다시 읽지 않아도 지금 내가 무엇을 결정해야 하는지 한눈에 파악할 수 있습니다. 마지막 메시지 이후 바뀐 내용과 사용자의 결정이 필요한 항목을 쉬운 말과 다이어그램으로 요약해 줍니다. |
| **`arcus-why`** | 변경 이력 추적 | 기존 코드가 왜 이렇게 작성되었는지 추측하느라 헤매는 시간을 아껴줍니다. 현재 코드만 보고 넘겨짚지 않고 `DECISIONS.md`, Git 커밋 기록, PR 논의를 추적해 당시의 설계 이유와 선택 배경을 근거와 함께 알려줍니다. |
| **`arcus-correct`** | 반복 실수 방지 및 룰 정리 | 에이전트에게 같은 지적을 반복해야 하는 피로감을 없애고 불필요한 규칙이 토큰을 낭비하지 않게 관리합니다. 반복 위반되는 규칙은 코드 구조·타입·린트·테스트로 막고, 안 읽히거나 당연한 규칙 및 버전 변화에 취약한 사실 주장은 정리합니다. |
| **`arcus-automate-me`** | 개인 스타일 학습 | 새 대화를 열 때마다 내 코딩 취향과 응답 스타일을 다시 설명할 필요가 없어집니다. 최근 작업 대화 기록을 분석하고 간단한 객관식 질문을 거쳐 내 작업 방식을 그대로 따르는 개인 맞춤형 모드 스킬을 만들어 줍니다. |
| **`arcus-skill-maker`** | 스킬 변환 및 제작 | 특정 도구에서만 작동하던 외부 스킬을 5개 에이전트 어디서나 쓸 수 있게 해줍니다. 외부 스킬이나 프롬프트를 분석해 모든 에이전트에서 호환되는 `arcus-*` 규격 스킬로 깔끔하게 변환합니다. |

---

## 🎯 사용 가이드: `arcus-mode` vs `arcus-work-loop` 차이 및 추천 워크플로우

### 1. `arcus-mode` 와 `arcus-work-loop` 는 무엇이 다른가요?

| 구분 | 👑 **`arcus-mode` (마스터 운영 모드 / OS)** | 🔄 **`arcus-work-loop` (체크리스트 실행 엔진)** |
| :--- | :--- | :--- |
| **핵심 역할** | 세션 전체의 엔지니어링 판단 기준, 간결한 문체, 서브에이전트 조율 방식을 통제하는 **상위 운영체제(OS)** 역할을 합니다. | 이미 정해진 작업 체크리스트(`- [ ]`)를 받아 **구현 ➔ 테스트 ➔ 실패 시 수정 ➔ 완료(`[x]`)**만 끝날 때까지 반복하는 **실행 전용 엔진**입니다. |
| **적용 범위** | 넓음: 상황별로 24가지 설계 원칙과 22가지 플레이북(원인 조사, 리팩토링, 설계 경쟁 비교, 성능 개선, PR 관리 등) 중 알맞은 절차를 스스로 골라 적용합니다. | 집중됨: `arcus-plan`에서 만든 체크리스트를 이어받아(없으면 즉시 생성하여) 각 항목의 실제 빌드·테스트 검증을 통과할 때까지 멈추지 않고 완주합니다. |
| **언제 쓰나요?** | - 세션을 처음 시작할 때 시니어 엔지니어 수준의 작업 규율을 켜두고 싶을 때<br>- 단순 구현이 아니라 원인 분석, 아키텍처 탐색, 성능 튜닝 등 복합적인 판단이 필요할 때 | - `$arcus-plan`으로 계획과 체크리스트가 확정된 뒤, 중간에 멈추지 말고 체크리스트를 끝까지 구현하고 검증해 오라고 시킬 때 |

### 2. 단계별 추천 파이프라인

1. **설계 및 체크리스트 수립 (`$arcus-plan`)**: 코드를 고치기 전에 근본 원인과 변경 범위를 파악하고, 검증 조건이 포함된 실행 체크리스트(`- [ ]`)를 만듭니다.
2. **격리된 계획서 크리틱 (`$arcus-review`)**: 작성자의 편향이 섞이지 않은 격리된 서브에이전트를 띄워 계획서의 전제와 허점을 미리 점검받습니다.
3. **체크리스트 자율 실행 (`$arcus-work-loop`)**: 확정된 체크리스트를 하나씩 구현·검증하여 모든 항목이 `- [x]`가 될 때까지 완주합니다.
4. **최종 코드 리뷰 및 의사결정 기록 (`$arcus-review` / `DECISIONS.md`)**: 지적 장부(Review Ledger)를 기반으로 구현 코드를 격리 리뷰합니다. 중요한 아키텍처 결정이나 규칙 승격(`$arcus-correct`)이 있었다면 사용자의 명시적 인가를 받아 `DECISIONS.md`에 기록하거나, 원치 않을 경우 프로젝트별 거절 설정(`.git/config`, `AGENTS.md` 주석, `.agents/settings.json`)을 영구 기억합니다.

---

## 🏗️ 아키텍처: 2계층 스킬 캡슐화 구조

수십 개의 세부 스킬을 최상위 `skills/` 폴더에 그대로 풀어놓으면 슬래시 명령어(`/`) 목록이 너무 길어지고 에이전트의 컨텍스트를 불필요하게 차지합니다. `arcus-stack` 은 이를 **2계층 캡슐화 구조**로 해결했습니다.

1. **사용자 호출용 코어 스킬 (12종)**: 최상위 `skills/arcus-*/SKILL.md`에 위치합니다. 사용자의 스킬 목록에는 꼭 필요한 이 12개의 핵심 스킬만 깔끔하게 표시됩니다.
2. **내부 캡슐화 모듈 (60여 종)**: `skills/arcus-mode/` 하위 폴더(`principles/`, `playbooks/`, `internal/`, `references/`) 안에 들어 있습니다. 모든 에이전트의 스킬 스캐너는 `skills/` 바로 아래 1단계 폴더만 목록에 등록하기 때문에, 24개 엔지니어링 원칙, 22개 플레이북, 17개 내부 보조 스킬(`unslop`, `bro`, `architect`, `swarm`, `arena`, `interrogate`, `checklist`, `decisions`, `modern-web-guidance` 등)은 사용자 메뉴를 어지럽히지 않고 에이전트가 작업 중 필요할 때만 내부 링크를 따라 읽어들입니다.

---

## 🚀 설치 및 업데이트 방법

### 방법 1. `npx skills` CLI 사용 (5개 에이전트 전역 또는 프로젝트별 설치 — 권장)

```bash
# 내 PC의 5개 에이전트 전역 환경에 모든 스킬을 한 번에 설치
npx skills add sacru2red/arcus-stack -g -y

# 현재 프로젝트에만 원하는 스킬을 골라 설치
npx skills add sacru2red/arcus-stack --skill arcus-mode --skill arcus-plan --skill arcus-work-loop
```

#### 🔄 `npx skills` 로 최신 버전 업데이트하기
새로운 스킬이 추가되거나 기존 스킬이 개선되었을 때, 아래 명령어를 다시 실행하면 최신 버전으로 덮어쓰기 업데이트됩니다:
```bash
npx skills add sacru2red/arcus-stack -g -y
# 또는
npx skills update
```

> **이름이 변경되거나 삭제된 스킬 정리 안내:** `npx skills`의 `add`/`update` 명령은 저장소에서 이름이 바뀌거나 사라진 옛 스킬(예: `arcus-work` → `arcus-work-loop`)을 자동으로 삭제하지 않습니다. 업데이트 후에도 옛 스킬 이름이 목록에 함께 보인다면 아래 명령어로 옛 스킬을 한 번 제거해 주세요:
> ```bash
> npx skills remove arcus-work -g -y
> ```

### 방법 2. 에이전트 자체 플러그인 매니저 사용

- **Antigravity (`agy`)**:
  ```bash
  # 설치 및 업데이트 (재실행 시 최신 버전 반영)
  agy plugin install https://github.com/sacru2red/arcus-stack
  ```
- **Claude Code**:
  ```bash
  # 설치
  /plugin marketplace add https://github.com/sacru2red/arcus-stack
  /plugin install arcus-stack

  # 업데이트
  /plugin update arcus-stack
  ```

### 방법 3. 로컬 클론 + 전역 심볼릭 링크 (`scripts/install-global.ps1` / `.sh`)

이 저장소를 직접 클론한 뒤 심볼릭 링크 스크립트를 실행하면, 5개 에이전트의 전역 스킬 경로(T3 Code 내부의 Antigravity 격리 경로 포함)에 즉시 연결됩니다.

```powershell
# Windows (PowerShell)
.\scripts\install-global.ps1
```

```bash
# macOS / Linux
./scripts/install-global.sh
```

#### 🔄 로컬 클론 방식에서 업데이트하기
심볼릭 링크가 로컬 저장소 폴더를 직접 가리키므로 `git pull`만 하면 모든 에이전트에 즉시 반영됩니다. 새로운 스킬 폴더가 추가된 경우에만 스크립트를 한 번 더 실행해 주세요:
```bash
git pull && ./scripts/install-global.sh   # (Windows는 .\scripts\install-global.ps1)
```

---

## 🗂️ 디렉토리 구조

```text
arcus-stack/
├── README.md                    # 영문 메인 문서 (English)
├── README.ko.md                 # 한국어 문서 (Korean)
├── README.ja.md                 # 일본어 문서 (Japanese)
├── README.zh-CN.md              # 중국어 간체 문서 (Simplified Chinese)
├── README.es.md                 # 스페인어 문서 (Spanish)
├── DECISIONS.md                 # 아키텍처 의사결정 장부 (D-001..D-007)
├── plugin.json                  # Antigravity (agy) 플러그인 매니페스트
├── .claude-plugin/
│   └── plugin.json              # Claude Code 플러그인 매니페스트
├── .agents/
│   └── skills.json              # 로컬 워크스페이스 스킬 인식 매니페스트
├── AGENTS.md                    # 루트 규칙 연결 파일
├── CLAUDE.md                    # Claude Code 규칙 연결 파일
├── rules/
│   └── AGENTS.md                # 5대 에이전트 공통 핵심 엔지니어링 원칙
├── scripts/
│   ├── install-global.ps1       # Windows용 5대 에이전트(+T3 Code) 전역 심볼릭 링크 설치기
│   └── install-global.sh        # macOS/Linux용 5대 에이전트(+T3 Code) 전역 심볼릭 링크 설치기
└── skills/                      # ⭐ 사용자 노출 12대 코어 스킬
    ├── arcus-mode/              # 마스터 모드 + 내부 캡슐화 모듈
    │   ├── SKILL.md
    │   ├── worker.md
    │   ├── playbooks/           # [내부 전용] 22개 작업 플레이북
    │   ├── principles/          # [내부 전용] 24개 엔지니어링 원칙
    │   ├── internal/            # [내부 전용] 17개 보조 스킬 (unslop, bro, modern-web-guidance 등)
    │   └── references/          # [내부 전용] bugbot-triage.md
    ├── arcus-plan/
    ├── arcus-work-loop/
    ├── arcus-review/
    ├── arcus-in-your-own-words/
    ├── arcus-create-verification/
    ├── arcus-maintain-verification/
    ├── arcus-ketchup/
    ├── arcus-why/
    ├── arcus-correct/
    ├── arcus-automate-me/
    └── arcus-skill-maker/
```
