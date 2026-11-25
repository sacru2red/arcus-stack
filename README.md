# 🏹 ARCUS-STACK (`arcus-stack`)

> **A**gent **R**ules, **C**ommands & **U**niversal **S**kills  
> *(An anagram of **SACRU** — Universal Agent Skill & Workflow Stack)*

**`arcus-stack`** 은 **Antigravity (`agy`), Claude Code, Codex, Cursor, OpenCode** 5대 AI 코딩 에이전트에서 100% 호환되는 범용(Universal) 스킬 & 플레이북 스택입니다.

MCP 서버 같은 무거운 런타임 의존성 없이 순수 `SKILL.md` 표준과 `AGENTS.md` 규칙만으로 구성되어 있으며, 다음 4대 오픈소스 하네스의 핵심 철학을 하나로 결합했습니다:
- **[`pstack`](https://github.com/cursor/plugins/tree/main/pstack)**: *"If you want to go fast, go deep first."* (근본 원인 분석, 최소 변경 반경, 검증 가능한 고품질 코드)
- **[`oh-my-openagent`](https://github.com/code-yeongyu/oh-my-openagent)**: `ultrawork` 자율 실행 루프 및 전략/실행 분리
- **[`oh-my-claudecode`](https://github.com/yeachan-heo/oh-my-claudecode)**: 역할별 전문 에이전트 분업(설계·구현·검증) 및 오토파일럿 워크플로우
- **[`oh-my-antigravity`](https://github.com/Joonghyun-Lee-Frieren/oh-my-antigravity)**: 컨텍스트 엔지니어링 기반 단계별 가드레일과 실제 검증 증거(Verification Evidence) 강제

---

## 📦 포함된 코어 스킬 (`arcus-*`)

| 스킬 이름 | 역할 및 설명 | 영감 / 레퍼런스 |
| :--- | :--- | :--- |
| **`arcus-plan`** | **[설계/분석]** 코딩 전 근본 원인(Root Cause), 영향 반경(Blast Radius), 단계별 구현 및 검증 계획을 수립합니다. | `pstack` Deep-First + `OMA` Team Plan |
| **`arcus-work`** | **[자율 실행]** 탐색 → 구현 → 자체 진단 → 실제 테스트/빌드 검증까지 완료 조건을 충족할 때까지 완주하는 Ultrawork 루프입니다. | `OmO` Ultrawork + `OMC` Autopilot |
| **`arcus-review`** | **[엄격한 검증]** 증상 땜질(Symptom Patching) 여부, 아키텍처 경계 위반, 엣지 케이스, 검증 증거 누락을 감사하는 적대적 리뷰어입니다. | `pstack` Playbooks + `OMA` Guarded Review |
| **`arcus-skill-maker`** | **[스킬 흡수기]** 외부의 좋은 스킬/프롬프트를 분석하여 5개 에이전트 모두에서 작동하는 `arcus-*` 표준 스킬로 리믹스·생성합니다. | Universal `SKILL.md` Standard |

---

## 🚀 설치 및 사용 방법 (Private 레포지토리 호환)

GitHub SSH 키 또는 `gh auth login`이 설정된 모든 PC에서 아래 방법으로 설치할 수 있습니다.

### 방법 1. `npx skills` CLI 사용 (5개 에이전트 전역 또는 프로젝트별 설치 — 권장)

```bash
# 새 PC에서 5개 에이전트 전역(Global)으로 한 번에 모든 스킬 설치
npx skills add sacru2red/arcus-stack -g -y

# 현재 프로젝트에만 특정 스킬 골라 설치
npx skills add sacru2red/arcus-stack --skill arcus-plan --skill arcus-work

# 레포 업데이트 후 최신 스킬 동기화
npx skills update
```

### 방법 2. 에이전트 네이티브 플러그인 매니저 사용

- **Antigravity (`agy`)**:
  ```bash
  agy plugin install https://github.com/sacru2red/arcus-stack
  ```
- **Claude Code**:
  ```bash
  /plugin marketplace add https://github.com/sacru2red/arcus-stack
  /plugin install arcus-stack
  ```

### 방법 3. 로컬 클론 + 원클릭 심볼릭 링크 (`scripts/install-global.ps1` / `.sh`)

이 저장소를 클론한 뒤 심볼릭 링크 스크립트를 실행하면, 저장소에서 스킬을 수정하거나 추가할 때마다 5개 에이전트 전역 경로(`~/.gemini/config/skills`, `~/.claude/skills`, `~/.codex/skills`, `~/.config/opencode/skills`, `~/.cursor/skills`, `~/.agents/skills`)에 **실시간으로 자동 반영**됩니다.

```powershell
# Windows (PowerShell)
.\scripts\install-global.ps1
```

```bash
# macOS / Linux
./scripts/install-global.sh
```

---

## 🗂️ 디렉토리 구조

```text
arcus-stack/
├── README.md                    # 프로젝트 문서 및 설치 가이드
├── plugin.json                  # Antigravity (agy) 플러그인 매니페스트
├── .claude-plugin/
│   └── plugin.json              # Claude Code 플러그인 매니페스트
├── AGENTS.md                    # 루트 규칙 브릿지
├── CLAUDE.md                    # Claude Code 규칙 브릿지
├── rules/
│   └── AGENTS.md                # 5대 에이전트 공통 핵심 엔지니어링 원칙
├── scripts/
│   ├── install-global.ps1       # Windows용 5대 에이전트 전역 심볼릭 링크(Junction) 설치기
│   └── install-global.sh        # macOS/Linux용 5대 에이전트 전역 심볼릭 링크 설치기
└── skills/
    ├── arcus-plan/
    │   ├── SKILL.md
    │   └── references/
    │       └── plan-template.md
    ├── arcus-work/
    │   ├── SKILL.md
    │   └── references/
    │       └── ultrawork-checklist.md
    ├── arcus-review/
    │   ├── SKILL.md
    │   └── references/
    │       └── review-rubric.md
    └── arcus-skill-maker/
        ├── SKILL.md
        └── references/
            └── universal-skill-spec.md
```
