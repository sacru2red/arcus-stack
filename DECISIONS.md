# 🏛️ ARCUS-STACK Architectural Decisions (`DECISIONS.md`)

This document records the core architectural and directional decisions of **`arcus-stack`**.

> **Hygiene Contract (Enforced by `arcus-correct` & `arcus-why`)**:
> - This file is loaded **on-demand** (never `@`-inlined into always-on `AGENTS.md`), preserving per-turn context budget.
> - Record **directional judgments, rejected alternatives, and structural enforcements**—never volatile implementation fact claims (such as *"API X behaves like Y"* or drifting line numbers).
> - Every entry pins the commit SHA or date it was established and declares its status (`ACTIVE` or `SUPERSEDED BY D-xxx`).

---

## `D-001`: Zero-MCP, Universal `SKILL.md` & `AGENTS.md` Standard Across 5 Agents
- **Date / Pin**: `2026-11-25` (`e1c549a`)
- **Status**: `ACTIVE`
- **Context**: In multi-agent environments like **T3 Code** and **Orca**, operators frequently switch or delegate across **Antigravity (`agy`), Claude Code, Codex, Cursor, and OpenCode**. Agent-specific frontmatter keys (`disable-model-invocation`, `allowed-tools`, `globs`, `icon`) and custom runtime servers break portability.
- **Decision & Tradeoff**:
  - Build `arcus-stack` exclusively on pure Markdown (`SKILL.md` + `AGENTS.md`) with zero MCP runtime dependencies.
  - Restrict `SKILL.md` YAML frontmatter strictly to `name` and `description`. Express tool constraints and trigger postures in plain Markdown body text.
  - *Rejected Alternative*: Maintaining separate per-agent skill builds or requiring an MCP server process.
- **Enforced By**: Automated frontmatter & relative-link verification check in repo validation and [`skills/arcus-skill-maker/references/universal-skill-spec.md`](./skills/arcus-skill-maker/references/universal-skill-spec.md).

---

## `D-002`: Two-Tier Skill Encapsulation (12 Public Core Skills + Private Internal Modules)
- **Date / Pin**: `2026-11-25` (`5f2bb3c`)
- **Status**: `ACTIVE`
- **Context**: Flattening 70+ granular skills (24 principles, 22 playbooks, 15 helper sub-skills) directly under `skills/` pollutes user slash-command menus (`/`) and wastes always-on skill description tokens.
- **Decision & Tradeoff**:
  - Expose only **12 high-level `arcus-*` core skills** at `skills/arcus-*/SKILL.md` (since all 5 agent skill scanners scan exactly one directory level deep under `skills/`).
  - Encapsulate all 60+ internal modules (`principles/`, `playbooks/`, `internal/`, `references/`) inside `skills/arcus-mode/` (and self-contained skill `references/`), loaded on-demand via relative Markdown links.
  - Ensure standalone core skills (`arcus-plan`, `arcus-work-loop`, `arcus-review`) keep their essential templates inside their own `references/` folder so partial installation (`npx skills add --skill arcus-plan`) never causes `ENOENT` on `../arcus-mode/`.
  - *Rejected Alternative*: Flat top-level `skills/principle-*` folders or cross-skill hard dependencies that break on partial installation.
- **Enforced By**: One-level directory layout under `skills/` and relative-link validation script.

---

## `D-003`: Namespace Isolation (`arcus-*`) & Stale Link / Lockfile Pruning on Rename
- **Date / Pin**: `2026-11-25` (`9cca575`, `671cacf`)
- **Status**: `ACTIVE`
- **Context**: Generic skill names or trigger keywords (such as `ulw` / `ultrawork`) collide with co-installed plugins (`oh-my-openagent`, `oh-my-claudecode`, `oh-my-antigravity`), causing ambiguous or double skill activation. Additionally, `npx skills add/update` does not prune upstream-renamed skills (e.g., `arcus-work` → `arcus-work-loop`), leaving ghost entries in `~/.agents/.skill-lock.json` and agent skill folders.
- **Decision & Tradeoff**:
  - Prefix all public skills with `arcus-` and remove colliding third-party trigger keywords (`ulw`, `ultrawork`) from descriptions.
  - Automatically prune stale `arcus-*` junctions/symlinks and `.skill-lock.json` entries in `scripts/install-global.ps1` and `scripts/install-global.sh`, and document `npx skills remove <old-skill> -g -y` in all 5 language READMEs.
- **Enforced By**: [`scripts/install-global.ps1`](./scripts/install-global.ps1), [`scripts/install-global.sh`](./scripts/install-global.sh), and frontmatter description audits.

---

## `D-004`: Context-Isolated Review Sandbox & Code-First Review Ledger
- **Date / Pin**: `2026-11-25` (Current)
- **Status**: `ACTIVE`
- **Context**: When the same session that designed a plan (`arcus-plan`) or wrote code (`arcus-work-loop`) reviews its own work, it inherits the exact confirmation bias, file-reading trail, and discarded alternatives that produced the design. In multi-round reviews, reading the author's explanation before checking the code biases the reviewer into accepting unverified fixes.
- **Decision & Tradeoff**:
  - **Context Isolation**: `arcus-review` (both Mode A Plan Critique and Mode B Code/PR Review) must delegate to a fresh, context-isolated subagent (with Cold-Reader Reset as a single-thread fallback). The parent must pass only the pinned snapshot, verbatim target artifact, and ledger—never its own defensive rationale.
  - **Cold-Reader & External Grounding**: Design reviews test whether an uninitiated reader can extract the root cause, boundaries, and failure modes from the doc alone, and verify third-party API claims against external documentation.
  - **Review Ledger with Blind Round 2+ Verdict**: Every review maintains a Findings Ledger (`F-01`, `F-02`, ...) physically separated from Author Replies. On Round 2+, the reviewer evaluates open ledger items against the new code snapshot *before* reading the author's replies.
- **Enforced By**: [`skills/arcus-review/SKILL.md`](./skills/arcus-review/SKILL.md), [`skills/arcus-review/references/review-rubric.md`](./skills/arcus-review/references/review-rubric.md), and [`skills/arcus-review/references/review-ledger-protocol.md`](./skills/arcus-review/references/review-ledger-protocol.md).

---

## `D-005`: Rule Lifecycle Hygiene & Ban on Volatile Fact Claims in Rules
- **Date / Pin**: `2026-11-25` (Current)
- **Status**: `ACTIVE`
- **Context**: Always-on rule files (`AGENTS.md`, `CLAUDE.md`) degrade over time in four ways: (1) rules that are repeatedly violated prove prose is insufficient; (2) rules that are never read/referenced are dead weight; (3) rules with 0 violations that merely restate base-model knowledge or existing linter checks waste tokens on every turn; (4) static fact claims about library/API behavior (*"API X works like Y"*) silently become false when dependencies upgrade.
- **Decision & Tradeoff**:
  - `arcus-correct` audits rules against all four signals: escalate repeatedly violated rules into architecture/types/lints; delete orphaned rules; prune 100%-obeyed rules that duplicate base-model defaults or automated checks; and strip volatile API fact claims from rule files.
  - Keep `rules/AGENTS.md` strictly for active behavioral constraints and their enforcement table, while storing historical rationale in on-demand `DECISIONS.md`.
- **Enforced By**: [`skills/arcus-correct/SKILL.md`](./skills/arcus-correct/SKILL.md), [`skills/arcus-why/SKILL.md`](./skills/arcus-why/SKILL.md), and [`rules/AGENTS.md`](./rules/AGENTS.md).
