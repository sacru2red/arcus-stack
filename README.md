# 🏹 ARCUS-STACK (`arcus-stack`)

<p align="center">
  <strong>English</strong> |
  <a href="./README.ko.md">한국어</a> |
  <a href="./README.ja.md">日本語</a> |
  <a href="./README.zh-CN.md">简体中文</a> |
  <a href="./README.es.md">Español</a>
</p>

> **A**gent **R**ules, **C**ommands & **U**niversal **S**kills  
> *(An anagram of **SACRU** — Universal Agent Skill & Workflow Stack)*

**`arcus-stack`** is a universal skill and workflow pack that works out of the box across **Antigravity (`agy`), Claude Code, Codex, Cursor, and OpenCode**.

---

## 💡 Why `arcus-stack`?

When working in multi-agent environments like **T3 Code** or **Orca**, you constantly switch between or delegate across different coding agents (`agy`, Claude Code, Codex, Cursor, OpenCode). However, every agent expects skills and rules in different directories and frontmatter formats—making it frustratingly difficult to share the same workflows across all of them.

**`arcus-stack` was built to solve this fragmentation.** With zero MCP runtime overhead and strictly universal `SKILL.md` and `AGENTS.md` standards, it lets you invoke the exact same battle-tested skills no matter which agent or harness you are running.

It distills and unifies the best ideas from five open-source projects:
- **[`pstack`](https://github.com/cursor/plugins/tree/main/pstack)**: *"If you want to go fast, go deep first."* (Root-cause analysis, minimal blast radius, verifiable code)
- **[`oh-my-openagent`](https://github.com/code-yeongyu/oh-my-openagent)**: `ultrawork` autonomous execution loops and strategy/execution separation
- **[`oh-my-claudecode`](https://github.com/yeachan-heo/oh-my-claudecode)**: Specialized role delegation (planning, execution, review) and autopilot workflows
- **[`oh-my-antigravity`](https://github.com/Joonghyun-Lee-Frieren/oh-my-antigravity)**: Context-engineered guardrails and mandatory verification evidence
- **[`GoogleChrome/modern-web-guidance`](https://github.com/GoogleChrome/modern-web-guidance)**: Live web platform best-practice lookup (`npx -y modern-web-guidance@latest`) for HTML, CSS, and client-side JS/DOM (Apache-2.0)

---

## 📦 Core Skills (`arcus-*`)

| Skill | Category | Benefit & Description |
| :--- | :--- | :--- |
| **`arcus-mode`** | Master Mode | Raises the baseline quality of every response and edit without verbose filler. Automatically applies 24 engineering principles, 22 task playbooks, and disciplined subagent delegation. |
| **`arcus-plan`** | Planning & Checklist | Prevents wasted implementation turns caused by jumping straight into code. Traces the root cause, maps affected files, and builds a goal-aligned execution and verification checklist (`- [ ]`) you can track to completion. |
| **`arcus-work-loop`** | Autonomous Execution | Finishes complex tasks end-to-end without stopping halfway or leaving TODO stubs. Works through the task checklist item by item, marking steps done (`- [x]`) only after real test and build verification passes. |
| **`arcus-review`** | Isolated Plan & Code Review | Prevents confirmation bias by reviewing plans and code in a context-isolated subagent on a pinned snapshot. Runs Cold-Reader comprehension tests on designs, checks external docs, and maintains a code-first Review Ledger across rounds. |
| **`arcus-in-your-own-words`** | Goal Alignment | Eliminates misunderstandings before a single line of code is touched. Restates your goal and core problem in the agent's own words to confirm alignment. |
| **`arcus-create-verification`** | App Verification | Saves you from manually launching and clicking through your app after every change. Generates and proves a project-local verification skill (`verify-<app>`) that drives your app like a real user. |
| **`arcus-maintain-verification`** | Verification Upkeep | Keeps your project's automated verification skill from rotting as features evolve. Compares source code against live app behavior to fix outdated verification recipes. |
| **`arcus-ketchup`** | Catch-up Briefing | Lets you see what changed and what needs your decision at a glance without reading long chat logs. Summarizes progress since your last message in plain language, diagrams, and decision-ready action items. |
| **`arcus-why`** | History & Rationale | Saves time guessing why existing code was written a certain way. Traces `DECISIONS.md`, Git commits, and PR discussions to return cited design decisions and historical trade-offs. |
| **`arcus-correct`** | Mistake Prevention & Rule Hygiene | Stops you from repeating the same corrections while keeping rule files lean. Escalates recurring mistakes into architecture, types, lint rules, or tests, and prunes dead, redundant, or brittle fact-claim rules. |
| **`arcus-automate-me`** | Personal Style | Frees you from re-explaining your coding preferences and workflow habits in every session. Mines your recent transcripts and runs a quick interview to build a personal `*-mode` skill. |
| **`arcus-skill-maker`** | Skill Converter | Makes external skills locked to a single tool usable across all 5 agents. Converts any workflow or external skill into the universal `arcus-*` standard. |

---

## 🎯 How to Use: `arcus-mode` vs. `arcus-work-loop` & Recommended Workflow

### 1. `arcus-mode` vs. `arcus-work-loop` — What's the Difference?

| Dimension | 👑 **`arcus-mode` (Master Operating System)** | 🔄 **`arcus-work-loop` (Checklist Execution Engine)** |
| :--- | :--- | :--- |
| **Role** | Sets the agent's overall engineering persona, prose discipline, and decision rules for the entire session. | Drives a concrete implementation-and-verification checklist item by item until every check passes. |
| **Scope** | Broad: selects from 24 engineering principles and 22 task playbooks (investigation, bug-fix, refactoring, arena comparison, PR babysitting, etc.), enforces concise `unslop` writing, and coordinates subagents. | Focused: takes the `- [ ]` checklist from `arcus-plan` (or builds one), edits code, runs tests/builds, repairs failures, and marks items `- [x]` only with real verification proof. |
| **When to Invoke** | At the start of a session when you want senior-level engineering judgment, or when tackling open-ended problems (architecture, debugging, perf tuning, PR management). | Right after `arcus-plan` (and `arcus-review`) when the plan is decided and you want the agent to execute and verify every checklist step to completion without stopping halfway. |

### 2. Recommended Step-by-Step Pipeline

1. **Align & Plan (`$arcus-plan`)**: Investigate the root cause, map affected files, and generate an actionable execution & verification checklist (`- [ ]`).
2. **Isolated Critique (`$arcus-review`)**: Spawn a context-isolated subagent to critique the plan (Cold-Reader test & premise check) before touching production code.
3. **Autonomous Execution (`$arcus-work-loop`)**: Execute the approved checklist in a self-verifying loop until every item is checked off (`- [x]`).
4. **Final Code Review & Decision Log (`$arcus-review` / `DECISIONS.md`)**: Run an isolated diff review against the Review Ledger. When major architectural trade-offs or rule graduations (`$arcus-correct`) occur, agents ask for your explicit authorization to record them in `DECISIONS.md` (or remember your project opt-out via `.git/config`, `AGENTS.md`, or `.agents/settings.json`).

### 3. Context-Isolated Review & The Review Ledger (`arcus-review`)

When the same agent session that wrote a plan or code reviews its own work, it inherits its own confirmation bias and blind spots. `arcus-review` breaks this cycle through **Context Isolation** and a **Review Ledger**:

- **Context-Isolated Sandbox**: Reviews run in a fresh subagent session on a pinned snapshot (`HEAD` SHA or diff hash) without the author's chat history or defensive framing. For design docs, it runs a **Cold-Reader Test** to verify an uninitiated reader can understand the design from the document alone, and checks external documentation beyond the repository.
- **Persistent Review Ledger (`F-01`, `F-02`, ...)**: Every review tracks findings in a structured ledger table physically separated from the author's replies.
- **Code-First Blind Verdict on Round 2+**: In multi-round reviews, the reviewer evaluates every open finding in the ledger (`OPEN`, `UNRESOLVED`, `DISPUTED`) by inspecting the **new code/doc snapshot first—before reading the author's replies or explanations**—to prevent being swayed by excuses before checking the facts:

| ID | Round | Pinned Snapshot | Severity | Target | Failure Scenario & Fix | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `F-01` | R1 | `4e058ee` | `CRITICAL` | `worker.md:7` | Mid-loop question prompts block autonomous subagents. Defer prompt to top-level turn. | `RESOLVED` |
| `F-02` | R1 | `4e058ee` | `HIGH` | `SKILL.md:44` | Relative path breaks on partial install. Inline fallback rules. | `VALID_PUSHBACK` |

*(Statuses: `OPEN` · `RESOLVED` · `UNRESOLVED` · `VALID_PUSHBACK` · `DISPUTED`)*

---

## 🏗️ Architecture: Two-Tier Skill Encapsulation

Importing dozens of granular skills directly into the top-level `skills/` directory pollutes your slash-command menu (`/`) and bloats agent context. `arcus-stack` solves this with a **two-tier encapsulation layout**:

1. **User-Facing Core Skills (12 skills)**: Placed at `skills/arcus-*/SKILL.md`. Only these 12 high-level entrypoints appear in your skill menu.
2. **Encapsulated Internal Modules (60+ files)**: Placed inside `skills/arcus-mode/` (`principles/`, `playbooks/`, `internal/`, `references/`). Because agent skill scanners only scan one level deep under `skills/`, helper modules like `unslop`, `bro`, `architect`, `swarm`, `arena`, `interrogate`, `modern-web-guidance`, 24 principles, 22 playbooks, and 17 internal sub-skills remain invisible in user menus while being loaded on-demand by the agent via relative links.

---

## 🚀 Installation & Updating

### Method 1. `npx skills` CLI (Recommended — Global or Per-Project)

```bash
# Install all skills globally across all 5 agents on your machine
npx skills add sacru2red/arcus-stack -g -y

# Install specific skills into the current project only
npx skills add sacru2red/arcus-stack --skill arcus-mode --skill arcus-plan --skill arcus-work-loop
```

#### 🔄 Updating via `npx skills`
To pull the latest skills and updates from GitHub at any time, simply re-run the global install command (or run `npx skills update`):
```bash
npx skills add sacru2red/arcus-stack -g -y
# or
npx skills update
```

> **Note on Renamed or Removed Skills:** `npx skills` does not automatically delete skills that were renamed or removed upstream (for example, `arcus-work` renamed to `arcus-work-loop`). If an old skill name still appears in your agent list after updating, remove it once with:
> ```bash
> npx skills remove arcus-work -g -y
> ```

### Method 2. Native Agent Plugin Managers

- **Antigravity (`agy`)**:
  ```bash
  # Install
  agy plugin install https://github.com/sacru2red/arcus-stack

  # Update (re-run install to fetch latest)
  agy plugin install https://github.com/sacru2red/arcus-stack
  ```
- **Claude Code**:
  ```bash
  # Install
  /plugin marketplace add https://github.com/sacru2red/arcus-stack
  /plugin install arcus-stack

  # Update
  /plugin update arcus-stack
  ```

### Method 3. Local Clone + Global Symlinks (`scripts/install-global.ps1` / `.sh`)

If you clone this repository locally and run the symlink script, all 12 skills are linked directly to the global directories of all 5 agents (including T3 Code's isolated Antigravity sandbox).

```powershell
# Windows (PowerShell)
.\scripts\install-global.ps1
```

```bash
# macOS / Linux
./scripts/install-global.sh
```

#### 🔄 Updating a Local Clone
Because symlinks point directly to your local clone, `git pull` updates every agent immediately. If new skill folders were added, re-run the script once:
```bash
git pull && ./scripts/install-global.sh   # (or .\scripts\install-global.ps1 on Windows)
```

---

## 🗂️ Directory Structure

```text
arcus-stack/
├── README.md                    # English documentation (Main)
├── README.ko.md                 # Korean documentation
├── README.ja.md                 # Japanese documentation
├── README.zh-CN.md              # Simplified Chinese documentation
├── README.es.md                 # Spanish documentation
├── DECISIONS.md                 # On-demand architectural decision records (D-001..D-007)
├── plugin.json                  # Antigravity (agy) plugin manifest
├── .claude-plugin/
│   └── plugin.json              # Claude Code plugin manifest
├── .agents/
│   └── skills.json              # Workspace skill discovery manifest
├── AGENTS.md                    # Root rules bridge
├── CLAUDE.md                    # Claude Code rules bridge
├── rules/
│   └── AGENTS.md                # Core engineering rules shared across all 5 agents
├── scripts/
│   ├── install-global.ps1       # Windows global symlink installer (5 agents + T3 Code)
│   └── install-global.sh        # macOS/Linux global symlink installer (5 agents + T3 Code)
└── skills/                      # ⭐ 12 User-Facing Core Skills
    ├── arcus-mode/              # Master mode + encapsulated internal modules
    │   ├── SKILL.md
    │   ├── worker.md
    │   ├── playbooks/           # [Internal] 22 task playbooks
    │   ├── principles/          # [Internal] 24 engineering principles
    │   ├── internal/            # [Internal] 17 helper sub-skills (unslop, bro, modern-web-guidance, etc.)
    │   └── references/          # [Internal] bugbot-triage.md
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
