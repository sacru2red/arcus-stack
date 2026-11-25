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
- **Context**: In multi-agent environments like **T3 Code** and **Orca**, operators frequently switch or delegate across **`Antigravity` (`agy`), `Claude Code`, `Codex`, `Cursor`, and `OpenCode`**. Agent-specific frontmatter keys (`disable-model-invocation`, `allowed-tools`, `globs`, `icon`) and custom runtime servers break portability.
- **Decision & Tradeoff**:
  - Build `arcus-stack` exclusively on pure Markdown (`SKILL.md` + `AGENTS.md`) with zero MCP runtime dependencies.
  - Restrict `SKILL.md` YAML frontmatter strictly to `name` and `description`. Express tool constraints and trigger postures in plain Markdown body text.
  - *Rejected Alternative*: Maintaining separate per-agent skill builds or requiring an MCP server process.
- **Enforced By**: [`scripts/validate.ps1`](./scripts/validate.ps1) and [`skills/arcus-skill-maker/references/universal-skill-spec.md`](./skills/arcus-skill-maker/references/universal-skill-spec.md).

---

## `D-002`: Two-Tier Skill Encapsulation (13 Public Core Skills + Private Internal Modules)
- **Date / Pin**: `2026-11-25` (`5f2bb3c`, updated by `D-008`)
- **Status**: `ACTIVE`
- **Context**: Flattening 70+ granular skills (24 principles, 22 playbooks, 17 helper sub-skills) directly under `skills/` pollutes user slash-command menus (`/`) and wastes always-on skill description tokens.
- **Decision & Tradeoff**:
  - Expose only **13 high-level `arcus-*` core skills** at `skills/arcus-*/SKILL.md` (since all 5 agent skill scanners scan exactly one directory level deep under `skills/`).
  - Encapsulate all 60+ internal modules (`principles/`, `playbooks/`, `internal/`, `references/`) inside `skills/arcus-mode/` (and self-contained skill `references/`), loaded on-demand via relative Markdown links.
  - Ensure standalone core skills (`arcus-plan`, `arcus-work-loop`, `arcus-review`) keep their essential templates inside their own `references/` folder so partial installation (`npx skills add --skill arcus-plan`) never causes `ENOENT` on `../arcus-mode/`.
  - *Rejected Alternative*: Flat top-level `skills/principle-*` folders or cross-skill hard dependencies that break on partial installation.
- **Enforced By**: One-level directory layout under `skills/` and [`scripts/validate.ps1`](./scripts/validate.ps1).

---

## `D-003`: Namespace Isolation (`arcus-*`) & Stale Link / Lockfile Pruning on Rename
- **Date / Pin**: `2026-11-25` (`9cca575`, `671cacf`)
- **Status**: `ACTIVE`
- **Context**: Generic skill names or trigger keywords (such as `ulw` / `ultrawork`) collide with co-installed plugins (`oh-my-openagent`, `oh-my-claudecode`, `oh-my-antigravity`), causing ambiguous or double skill activation. Additionally, `npx skills add/update` does not prune upstream-renamed skills (e.g., `arcus-work` → `arcus-work-loop`, `arcus-in-your-own-words` → `arcus-explain`), leaving ghost entries in `~/.agents/.skill-lock.json` and agent skill folders.
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

---

## `D-006`: User-Authorized `DECISIONS.md` Proposals & 3-Tier Opt-Out Persistence
- **Date / Pin**: `2026-11-25` (Current)
- **Status**: `ACTIVE`
- **Context**: Proposing an Architectural Decision Record (`DECISIONS.md` / ADR) when a major trade-off or rule graduation occurs keeps long-term rationale discoverable for `arcus-why`. However, agents must never create files or modify workspace configs without explicit user authorization—and if a user declines for a project, agents across future sessions must remember that opt-out in both Git and non-Git workspaces without blocking autonomous subagents.
- **Decision & Tradeoff**:
  - **Top-Level Interactive Authorization Only**: Subagents (`worker.md`) and mid-flight `arcus-work-loop` runs never block to ask questions; only the top-level interactive turn asks for user authorization (`1: Record D-xxx`, `2: Skip this time`, `3: Opt out for this project`).
  - **3-Tier Opt-Out Persistence Fallback Chain**: When the user authorizes opting out (Option 3), persist via:
    1. **Tier 1 (Git repo — zero working-tree pollution)**: `git config --local arcus.decisions off`
    2. **Tier 2 (Non-Git with `AGENTS.md`/`CLAUDE.md`, or explicit team-shared opt-out)**: Append `<!-- arcus:decisions=off -->`
    3. **Tier 3 (Non-Git folder fallback)**: Merge `"decisions": "off"` into `.agents/settings.json`.
  - Pre-check all three tiers (ignoring `git config` exit codes `1`/`128` when unset/non-Git) and stay silent whenever any tier is `off`.
- **Enforced By**: [`skills/arcus-mode/internal/decisions.md`](./skills/arcus-mode/internal/decisions.md), [`skills/arcus-plan/SKILL.md`](./skills/arcus-plan/SKILL.md), and [`skills/arcus-correct/SKILL.md`](./skills/arcus-correct/SKILL.md).

---

## `D-007`: Live Web Platform Guidance via Encapsulated `modern-web-guidance` CLI
- **Date / Pin**: `2026-11-25` (Current)
- **Status**: `ACTIVE`
- **Context**: Web platform APIs (`<dialog>`, Popover API, Anchor Positioning, Container Queries, View Transitions, Scroll-Driven Animations, Baseline fallbacks) evolve rapidly, causing base model training weights to emit obsolete patterns. However, hardcoding static web API rules in `AGENTS.md` violates `D-005` (Fact-Claim Ban), and adding `modern-web-guidance` as an extra top-level skill would clutter the `arcus-*` slash menu (`D-002`).
- **Decision & Tradeoff**:
  - Encapsulate Google Chrome's `modern-web-guidance` (Apache-2.0, with Section 4(b) modification notice) as a private internal sub-skill at [`skills/arcus-mode/internal/modern-web-guidance.md`](./skills/arcus-mode/internal/modern-web-guidance.md).
  - Remove upstream's pinned `--skill-version` flag and blocking pre-execution permission prompts, replacing them with a non-blocking offline fallback chain (`npx -y modern-web-guidance@latest` ➔ `npx --offline -y` ➔ 1-line skip note) so autonomous subagents (`worker.md`) and `arcus-work-loop` never stall.
  - Wire automatic triggers for HTML/CSS/client-side JS tasks across `rules/AGENTS.md`, `arcus-mode`, `arcus-plan`, `arcus-work-loop`, and `arcus-review`.
- **Enforced By**: [`skills/arcus-mode/internal/modern-web-guidance.md`](./skills/arcus-mode/internal/modern-web-guidance.md) and [`rules/AGENTS.md`](./rules/AGENTS.md).

---

## `D-008`: Engineering & Domain Brain Onboarding (`arcus-onboard` / `ONBOARDING.md`) with Code-vs-Domain Reconciliation
- **Date / Pin**: `2026-11-25` (Current)
- **Status**: `ACTIVE`
- **Context**: High-severity agent mistakes in unfamiliar repositories stem from guessing implicit domain knowledge: mismatches between product terminology and DB/code identifiers, unstated settlement/timezone/rounding invariants, authz & plan-tier boundaries, authoritative systems of record, and frozen legacy code minefields. A generic corporate/HR onboarding template does not help software engineering agents, whereas dumping volatile domain facts into always-on `AGENTS.md` violates `D-005`.
- **Decision & Tradeoff**:
  - Add `arcus-onboard` as the 13th public core skill ([`skills/arcus-onboard/SKILL.md`](./skills/arcus-onboard/SKILL.md)) to generate and maintain a 1–2 page Engineering & Domain Brain (`ONBOARDING.md`, or `CONTEXT.md` when `ONBOARDING.md` is already used for dev setup).
  - Focus the 7 pillars strictly on software engineering & domain architecture (System Boundaries, Ubiquitous Language ↔ Code Mapping, Core Business Formulas & Invariants, Authz Roles & Plan/Tier Gating, Legacy Minefields & Red Lines, Systems of Record, and Error/UX/PR Conventions) per [`domain-brain-template.md`](./skills/arcus-onboard/references/domain-brain-template.md).
  - **Code-vs-Domain Reconciliation (`D-005` harmony)**: Stamp every entry with `[as of YYYY-MM-DD | Source: <File/Schema/System/Owner>]`. When consumer skills (`arcus-plan`, `arcus-work-loop`, `arcus-review`, `arcus-mode`) read `ONBOARDING.md`, they must cross-check cited code paths against live code—trusting live code if refactored and proposing a Mode 2 update for stale onboarding entries.
- **Enforced By**: [`skills/arcus-onboard/SKILL.md`](./skills/arcus-onboard/SKILL.md), [`skills/arcus-onboard/references/domain-brain-template.md`](./skills/arcus-onboard/references/domain-brain-template.md), and [`rules/AGENTS.md`](./rules/AGENTS.md).
