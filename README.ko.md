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

다음 4대 오픈소스 프로젝트의 핵심 장점을 하나로 모았습니다:
- **[`pstack`](https://github.com/cursor/plugins/tree/main/pstack)**: *"빠르게 가려면 먼저 깊게 파고들어라."* (근본 원인 파악, 최소한의 코드 변경, 검증 가능한 코드 작성)
- **[`oh-my-openagent`](https://github.com/code-yeongyu/oh-my-openagent)**: 작업이 끝날 때까지 스스로 반복 실행하는 `ultrawork` 루프와 전략·실행 분리
- **[`oh-my-claudecode`](https://github.com/yeachan-heo/oh-my-claudecode)**: 설계·구현·검증 역할 분담 및 자율 실행 워크플로우
- **[`oh-my-antigravity`](https://github.com/Joonghyun-Lee-Frieren/oh-my-antigravity)**: 단계별 품질 가드레일과 실제 실행 증거 기반의 완료 검증

---

## 📦 코어 스킬 (`arcus-*`)

| 스킬 이름 | 분류 | 역할 및 설명 |
| :--- | :--- | :--- |
| **`arcus-mode`** | 마스터 모드 | 불필요한 미사여구 없이 간결한 답변과 검증된 코드만 받도록 에이전트의 기본 작업 수준을 높여줍니다. 작업 성격에 맞춰 24가지 엔지니어링 원칙과 22가지 플레이북, 서브에이전트 위임 규칙을 자동으로 적용합니다. |
| **`arcus-plan`** | 설계 및 기획 | 코드를 바로 고치다 방향이 꼬이는 일을 막아줍니다. 코딩을 시작하기 전에 문제의 근본 원인과 변경 영향 범위를 먼저 파악하고, 단계별 구현 및 검증 계획을 세웁니다. |
| **`arcus-work`** | 자율 실행 | 중간에 멈추거나 덜 끝난 코드를 남기지 않고 작업을 끝까지 완수합니다. 코드 탐색부터 구현, 자체 진단, 실제 테스트와 빌드 검증까지 완료 기준을 통과할 때까지 스스로 진행합니다. |
| **`arcus-review`** | 코드 리뷰 | 눈앞의 에러만 가리는 임시방편 코드를 걸러내어 배포 후 장애를 예방합니다. 근본 원인이 해결되었는지, 구조적 경계나 놓친 예외 상황은 없는지, 실제 테스트 증거가 있는지 꼼꼼하게 점검합니다. |
| **`arcus-in-your-own-words`** | 목표 확인 | 에이전트가 내 의도를 잘못 이해하고 엉뚱한 코드를 짜는 시간 낭비를 줄여줍니다. 작업을 시작하기 전에 사용자가 원하는 목표와 해결하려는 핵심 문제를 에이전트 자신의 말로 요약해 확인받습니다. |
| **`arcus-create-verification`** | 앱 검증 스킬 생성 | 기능이 바뀔 때마다 사람이 일일이 앱을 켜서 수동으로 확인하는 수고를 덜어줍니다. 실제 사용자처럼 앱을 실행하고 주요 기능을 조작해 정상 동작 증거를 남기는 프로젝트 전용 검증 스킬(`verify-<앱이름>`)을 만들어 줍니다. |
| **`arcus-maintain-verification`** | 앱 검증 스킬 갱신 | 앱 코드가 바뀔 때 기존 검증 절차가 낡아서 깨지는 문제를 막아줍니다. 변경된 소스 코드와 실제 앱 실행 결과를 대조해 프로젝트의 검증 스킬과 기능 목록을 최신 상태로 유지합니다. |
| **`arcus-ketchup`** | 진행 상황 요약 | 긴 대화 기록을 처음부터 다시 읽지 않아도 지금 내가 무엇을 결정해야 하는지 한눈에 파악할 수 있습니다. 마지막 메시지 이후 바뀐 내용과 사용자의 결정이 필요한 항목을 쉬운 말과 다이어그램으로 요약해 줍니다. |
| **`arcus-why`** | 변경 이력 추적 | 기존 코드가 왜 이렇게 작성되었는지 추측하느라 헤매는 시간을 아껴줍니다. 현재 코드만 보고 넘겨짚지 않고 Git 커밋 기록과 PR 논의를 추적해 당시의 설계 이유와 선택 배경을 근거와 함께 알려줍니다. |
| **`arcus-correct`** | 반복 실수 방지 | 에이전트에게 같은 지적을 반복해야 하는 피로감을 없애줍니다. 자주 틀리는 패턴을 찾아 단순 문서 지시가 아니라 코드 구조, 타입, 린트 규칙, 테스트로 막아 다음부터는 같은 실수를 할 수 없게 만듭니다. |
| **`arcus-automate-me`** | 개인 스타일 학습 | 새 대화를 열 때마다 내 코딩 취향과 응답 스타일을 다시 설명할 필요가 없어집니다. 최근 작업 대화 기록을 분석하고 간단한 객관식 질문을 거쳐 내 작업 방식을 그대로 따르는 개인 맞춤형 모드 스킬을 만들어 줍니다. |
| **`arcus-skill-maker`** | 스킬 변환 및 제작 | 특정 도구에서만 작동하던 외부 스킬을 5개 에이전트 어디서나 쓸 수 있게 해줍니다. 외부 스킬이나 프롬프트를 분석해 모든 에이전트에서 호환되는 `arcus-*` 규격 스킬로 깔끔하게 변환합니다. |

---

## 🏗️ 아키텍처: 2계층 스킬 캡슐화 구조

수십 개의 세부 스킬을 최상위 `skills/` 폴더에 그대로 풀어놓으면 슬래시 명령어(`/`) 목록이 너무 길어지고 에이전트의 컨텍스트를 불필요하게 차지합니다. `arcus-stack` 은 이를 **2계층 캡슐화 구조**로 해결했습니다.

1. **사용자 호출용 코어 스킬 (12종)**: 최상위 `skills/arcus-*/SKILL.md`에 위치합니다. 사용자의 스킬 목록에는 꼭 필요한 이 12개의 핵심 스킬만 깔끔하게 표시됩니다.
2. **내부 캡슐화 모듈 (60여 종)**: `skills/arcus-mode/` 하위 폴더(`principles/`, `playbooks/`, `internal/`, `references/`) 안에 들어 있습니다. 모든 에이전트의 스킬 스캐너는 `skills/` 바로 아래 1단계 폴더만 목록에 등록하기 때문에, 24개 엔지니어링 원칙, 22개 플레이북, 14개 내부 보조 스킬(`unslop`, `bro`, `architect`, `swarm`, `arena`, `interrogate` 등)은 사용자 메뉴를 어지럽히지 않고 에이전트가 작업 중 필요할 때만 내부 링크를 따라 읽어들입니다.

---

## 🚀 설치 및 업데이트 방법

### 방법 1. `npx skills` CLI 사용 (5개 에이전트 전역 또는 프로젝트별 설치 — 권장)

```bash
# 내 PC의 5개 에이전트 전역 환경에 모든 스킬을 한 번에 설치
npx skills add sacru2red/arcus-stack -g -y

# 현재 프로젝트에만 원하는 스킬을 골라 설치
npx skills add sacru2red/arcus-stack --skill arcus-mode --skill arcus-plan --skill arcus-work
```

#### 🔄 `npx skills` 로 최신 버전 업데이트하기
새로운 스킬이 추가되거나 기존 스킬이 개선되었을 때, 아래 명령어를 다시 실행하면 최신 버전으로 덮어쓰기 업데이트됩니다:
```bash
npx skills add sacru2red/arcus-stack -g -y
# 또는
npx skills update
```

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
    │   ├── internal/            # [내부 전용] 14개 보조 스킬 (unslop, bro, architect 등)
    │   └── references/          # [내부 전용] bugbot-triage.md
    ├── arcus-plan/
    ├── arcus-work/
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
