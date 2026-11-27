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

## `D-002`: Two-Tier Skill Encapsulation (15 Public Core Skills + Private Internal Modules)
- **Date / Pin**: `2026-11-25` (`5f2bb3c`, updated by `D-008`, `D-009`, `D-012`)
- **Status**: `ACTIVE`
- **Context**: Flattening 70+ granular skills (24 principles, 22 playbooks, 17 helper sub-skills) directly under `skills/` pollutes user slash-command menus (`/`) and wastes always-on skill description tokens.
- **Decision & Tradeoff**:
  - Expose only **15 high-level `arcus-*` core skills** at `skills/arcus-*/SKILL.md` (since all 5 agent skill scanners scan exactly one directory level deep under `skills/`).
  - Encapsulate all 60+ internal modules (`principles/`, `playbooks/`, `internal/`, `references/`) inside `skills/arcus-mode/` (and self-contained skill `references/`), loaded on-demand via relative Markdown links.
  - Ensure standalone core skills (`arcus-plan`, `arcus-work-loop`, `arcus-review`, `arcus-security`, `arcus-ui-propose`) keep their essential templates inside their own `references/` folder so partial installation (`npx skills add --skill arcus-plan`) never causes `ENOENT` on `../arcus-mode/`.
  - *Rejected Alternative*: Flat top-level `skills/principle-*` folders or cross-skill hard dependencies that break on partial installation.
- **Enforced By**: One-level directory layout under `skills/` and [`scripts/validate.ps1`](./scripts/validate.ps1) (exactly 15 non-dot `skills/arcus-*` folders, each with a `SKILL.md` whose `name` equals the folder; dot-prefixed tool state such as `skills/.omc/` is ignored), with regression cases in [`scripts/test-validate.ps1`](./scripts/test-validate.ps1).

---

## `D-003`: Namespace Isolation (`arcus-*`) & Stale Link / Lockfile Pruning on Rename
- **Date / Pin**: `2026-11-25` (`9cca575`, `671cacf`; install scope and copied-install handling revised `2026-11-27`)
- **Status**: `ACTIVE`
- **Context**: Generic skill names or trigger keywords (such as `ulw` / `ultrawork`) collide with co-installed plugins (`oh-my-openagent`, `oh-my-claudecode`, `oh-my-antigravity`), causing ambiguous or double skill activation. Additionally, `npx skills add/update` does not prune upstream-renamed skills (e.g., `arcus-work` → `arcus-work-loop`, `arcus-in-your-own-words` → `arcus-explain`), leaving ghost entries in `~/.agents/.skill-lock.json` and agent skill folders.
- **Decision & Tradeoff**:
  - Prefix all public skills with `arcus-` and remove colliding third-party trigger keywords (`ulw`, `ultrawork`) from descriptions.
  - Automatically prune stale `arcus-*` junctions/symlinks and `.skill-lock.json` entries in `scripts/install-global.ps1` and `scripts/install-global.sh`, and document `npx skills remove <old-skill> -g -y` in all 5 language READMEs.
  - *Revision `2026-11-27`*: the installers write only to an explicit allowlist (the 6 agent skill folders plus T3 Code Antigravity instances) instead of every `~/.*/skills`, link only `skills/arcus-*` folders that contain `SKILL.md`, and prune only links that point into this repo's `skills/`. Links elsewhere and real directories without `SKILL.md` are never touched. A real `arcus-*` directory with `SKILL.md` is replaced by the link only when its files, folders and bytes (hidden entries included) match the repo copy. One that differs is first moved to `~/.arcus-stack-backups/<timestamp>/<agent-folder>/<skill>`, outside every agent's scan path, and an agent folder that resolves to the repo's own `skills/` is skipped. The lock file is rewritten as BOM-less UTF-8 so `npx skills` keeps parsing it. The cost is that a new agent folder must be added to the list by hand. Proven by [`scripts/test-install-global.ps1`](./scripts/test-install-global.ps1) and [`scripts/test-install-global.sh`](./scripts/test-install-global.sh).
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

---

## `D-009`: Visual UI 4-Screenshot Proposal (`arcus-ui-propose`) & PR/MR Before/After Visual Evidence Pipeline
- **Date / Pin**: `2026-11-25` (extended `2026-11-26`, revert mechanism revised `2026-11-27`)
- **Status**: `ACTIVE`
- **Context**: In visual UI tasks, agents typically commit to the first design they think of without showing the current baseline or alternative layouts. Conversely, spawning 3 full git worktrees and 3 separate dev servers just to preview UI variants is slow, consumes ports/RAM, and breaks when local dev environments only support a single active instance. When opening PRs or GitLab MRs for UI diffs, agents also either omit Before/After visual proof, reuse stale draft screenshots, paste broken local filesystem paths into remote PR bodies, or accidentally commit raw binary PNGs to the feature branch.
- **Decision & Tradeoff**:
  - Add `arcus-ui-propose` as the 14th public core skill ([`skills/arcus-ui-propose/SKILL.md`](./skills/arcus-ui-propose/SKILL.md)) and auto-wire it into `arcus-plan` and `arcus-mode` for visual UI tasks.
  - **Sequential Working-Branch Cycle with Dirty-Tree Protection**:
    1. Hide `.audit/` via `.git/info/exclude`, record `00-status.txt`, pin the baseline with `BASE=$(git stash create)` and `IDX=$BASE^2` (or `HEAD` for both on a clean tracked tree, stopping when `git stash create` fails) without touching the working tree, and capture **1 Baseline ("Before") screenshot** (`00-before.png`) at a locked viewport/theme.
    2. For each of **3 genuinely distinct variants (`Option A`, `Option B`, `Option C`)**: apply the edit directly on the working branch ➔ wait for hot-reload/render ➔ capture `0N-option-X.png` ➔ export `option-X.patch` to `.audit/ui-propose/<task-slug>/` ➔ revert via `git restore --source=$BASE --worktree -- <files>` + `git restore --source=$IDX --staged -- <files>`.
    3. Present all 4 screenshots side-by-side with a trade-off matrix while leaving the working tree exactly as the user had it, then instantaneously apply (`git apply`) whichever option (or hybrid graft) the user selects.
    4. *Revision `2026-11-27`*: the original cycle saved the whole dirty tree as `00-base-dirty.patch` and re-applied it after each `git checkout HEAD`. Re-applying failed whenever some hunks were already present, which could drop user edits, and the untracked `.audit/` folder made the Step 4 status check unpassable. Restoring files from a pinned `git stash create` commit is idempotent and never re-applies a patch. Its second parent holds the staged index, so `git restore --staged` from it keeps the user's staging too. `git stash create` exits non-zero with intent-to-add or unmerged files and before the first commit; treating that as a clean tree would lose edits git never stored, so the cycle stops instead. The cost is Git 2.23+ for `git restore`. Proven by [`scripts/test-ui-propose-revert.sh`](./scripts/test-ui-propose-revert.sh).
  - **PR/MR Before/After Visual Evidence Pipeline**:
    1. Sync `## Visual Changes` (UI diffs only; dropped if non-UI) between `## Blast Radius` and `## Verification` in both `worker.md` and `opening-a-pr.md`, keeping single-view tables inside the 40-line cap and offloading multi-screen or multi-viewport grids to a linked PR comment.
    2. Capture a fresh post-polish `99-after-final.png` matching `00-before.png` (or capture `before.png` from a temporary detached `merge-base` worktree when `arcus-ui-propose` did not run, degrading non-blockingly when `merge-base` cannot boot or capture is unavailable), and guard `git diff --cached --name-only` so zero `.audit/ui-propose/` or scratch PNGs are committed.
    3. Resolve the forge before uploading: auto-upload on GitLab via `glab api "projects/:fullpath/uploads" --form "file=@<path>"` (or a configured repo media uploader), and use the GitHub Safe Handoff Default (2-column drag-and-drop placeholder table in the remote PR body plus exact absolute local paths and inline Markdown previews in the chat handoff reply) whenever no CLI attachment API exists.
    4. *Rejected Alternatives*: Committing raw binary PNGs to the feature branch (bloats git history and pollutes code diffs) or auto-pushing an orphan media branch (creates unrequested remote refs, conflicts with branch policies, and risks leaking screenshots outside PR scope).
- **Enforced By**: [`skills/arcus-ui-propose/SKILL.md`](./skills/arcus-ui-propose/SKILL.md), [`skills/arcus-ui-propose/references/ui-proposal-protocol.md`](./skills/arcus-ui-propose/references/ui-proposal-protocol.md), [`skills/arcus-mode/playbooks/opening-a-pr.md`](./skills/arcus-mode/playbooks/opening-a-pr.md), [`skills/arcus-mode/worker.md`](./skills/arcus-mode/worker.md), [`skills/arcus-work-loop/SKILL.md`](./skills/arcus-work-loop/SKILL.md), [`skills/arcus-review/references/review-rubric.md`](./skills/arcus-review/references/review-rubric.md), and [`rules/AGENTS.md`](./rules/AGENTS.md).

---

## `D-010`: Archify-First Visualization Routing (`archify-visualization`) with OS Temp Output Isolation & Non-Blocking 3-Tier Fallback
- **Date / Pin**: `2026-11-25` (Current)
- **Status**: `ACTIVE`
- **Context**: When users request system architecture, workflow, sequence, data-flow, state lifecycle, ERD, class, tree, timeline, or waterfall visualizations (or 1-page visual explainers), agents default to static text or basic Mermaid blocks. [`tt-a1i/archify`](https://github.com/tt-a1i/archify) (Apache-2.0) generates validated, theme-aware interactive standalone HTML/SVG diagrams and 1-page explainers, but bundling its ~5.4 MB skill runtime inside `arcus-stack` would bloat the repository and lag upstream updates, while its default `./.archify/` output folder and `proactive` mode would dirty git working trees during read-only planning (`arcus-plan`) or catch-ups (`arcus-ketchup`).
- **Decision & Tradeoff**:
  - Encapsulate `archify` routing as an internal sub-skill at [`skills/arcus-mode/internal/archify-visualization.md`](./skills/arcus-mode/internal/archify-visualization.md) (with Apache-2.0 Section 4(b) modification notice) and wire on-demand triggers across `rules/AGENTS.md`, `arcus-mode`, `arcus-plan`, `arcus-explain`, and `arcus-ketchup` (with `*(when co-installed)*` guards and self-contained inline fallbacks per `D-002`).
  - **Working-Tree Clean Output Isolation**: Unless the user explicitly requests saving diagram artifacts inside the repository, write all candidate and finalized `.html` / `.receipt.json` files to `<os.tmpdir()>/archify/<type>-<slug>-<ts>/` so `git status` stays untouched.
  - **3-Tier Non-Blocking Resolution Chain**:
    1. **Tier 1 (Cross-Platform 5-Agent + T3 Code Locator)**: Search workspace `.agents/skills` and global agent skill directories (`~/.agents/skills`, `~/.gemini/config/skills`, `~/.t3/userdata/providers/antigravity/*/config/skills`, `~/.claude/skills`, `~/.codex/skills`, `~/.cursor/skills`, `~/.config/opencode/skills`) via `os.homedir()` for `archify/bin/archify.mjs` and run `finalize`.
    2. **Tier 2 (Auto-Bootstrap)**: If not installed and online, run `npx -y skills@latest add https://archify.si --skill archify -g --copy --yes` non-blockingly and re-run Tier 1.
    3. **Tier 3 (Offline / Sandbox Fallback)**: If offline or restricted, fall back immediately to inline Mermaid (or declared host `html_render`) with a 1-line note without blocking the session.
- **Enforced By**: [`skills/arcus-mode/internal/archify-visualization.md`](./skills/arcus-mode/internal/archify-visualization.md) and [`rules/AGENTS.md`](./rules/AGENTS.md).

---

## `D-011`: Zero-Downtime Expand-Contract Migrations (`safe-migration.md`) Over Single-Wave Cutover
- **Date / Pin**: `2026-11-26` (Current)
- **Status**: `ACTIVE`
- **Context**: Existing refactoring rules (`skills/arcus-mode/playbooks/refactoring.md` and `principle-migrate-callers-then-delete-legacy-apis.md`) ban compatibility shims and parallel old-and-new paths, while `principle-outcome-oriented-execution.md` permits scoped intermediate breakage. Applying those rules verbatim to live production database schemas, persisted queues or caches, or rolling-deploy external wire contracts causes blocking table locks, `N-1`/`N` rolling-deploy failures, failed rollbacks, and data loss.
- **Decision & Tradeoff**:
  - Add [`skills/arcus-mode/playbooks/safe-migration.md`](./skills/arcus-mode/playbooks/safe-migration.md) as the 23rd internal playbook enforcing a 4-phase Expand -> Backfill & Verify -> Contract lifecycle split across separate deployable PRs (PR A Expand and dual-write, bounded chunked idempotent backfill with parity checks, bake window, then PR B Contract).
  - Explicitly scope single-wave cutover in `refactoring.md` and `principle-migrate-callers-then-delete-legacy-apis.md` to internal code-only APIs, and forbid intermediate breakage in `principle-outcome-oriented-execution.md` for live DB schemas, persisted data, and rolling-deploy wire contracts.
  - Wire partial-install-safe (`D-002`) inline fallback guards into `arcus-plan`, `arcus-work-loop`, and `arcus-review` (`review-rubric.md`), and surface the exemption directly in `skills/arcus-mode/SKILL.md`.
  - *Rejected Alternative*: Applying single-wave destructive migrations (or shipping Expand and Contract in a single PR) to live production schemas and rolling-deploy wire contracts, which breaks `N-1` nodes during deploys or rollbacks and risks long table locks.
- **Enforced By**: [`skills/arcus-mode/playbooks/safe-migration.md`](./skills/arcus-mode/playbooks/safe-migration.md), [`skills/arcus-mode/playbooks/refactoring.md`](./skills/arcus-mode/playbooks/refactoring.md), [`skills/arcus-mode/principles/principle-migrate-callers-then-delete-legacy-apis.md`](./skills/arcus-mode/principles/principle-migrate-callers-then-delete-legacy-apis.md), [`skills/arcus-mode/principles/principle-outcome-oriented-execution.md`](./skills/arcus-mode/principles/principle-outcome-oriented-execution.md), [`skills/arcus-review/references/review-rubric.md`](./skills/arcus-review/references/review-rubric.md), and [`rules/AGENTS.md`](./rules/AGENTS.md).

---

## `D-012`: Standalone Security, Authz & Supply-Chain Audit Core Skill (`arcus-security`)
- **Date / Pin**: `2026-11-26` (Current)
- **Status**: `ACTIVE`
- **Context**: Routine code reviews (`arcus-review`) focus on correctness, architecture boundaries, and regressions. Folding threat modeling, horizontal/vertical authz (IDOR/BOLA) matrices, taint-to-sink tracing, secret redaction, local PoC verification, and cross-ecosystem dependency/SAST scanning into `arcus-review` as a third mode ("Mode C") would slow down everyday reviews, mix security triage states (`OPEN`, `FIXED_VERIFIED`, `MITIGATED`, `ACCEPTED_RISK`, `FALSE_POSITIVE`) with general code findings (`F-01`..), and hide a dedicated `/arcus-security` entrypoint for pre-launch and high-risk PR audits.
- **Decision & Tradeoff**:
  - Add `arcus-security` as the 15th public core skill ([`skills/arcus-security/SKILL.md`](./skills/arcus-security/SKILL.md)) with its self-contained protocol at [`skills/arcus-security/references/security-audit-protocol.md`](./skills/arcus-security/references/security-audit-protocol.md) and zero required links outside `skills/arcus-security/` per `D-002`.
  - Apply `D-004` context isolation (fresh read-only subagent or Cold-Reader Reset fallback) and separate the Security Findings Ledger (`S-01`, `S-02`, ...) from general review ledgers (`F-01`, `F-02`, ...).
  - **Local/Isolated PoCs Only**: Prohibit firing exploit payloads against staging, production, live `.env` endpoints, or external hosts. Prove `CRITICAL`/`HIGH` issues with verified `file:line` traces and clean local, mocked, or ephemeral (`127.0.0.1`) negative regression tests, leaving zero untracked throwaway exploit scripts.
  - **Strict Secret Redaction**: Report only `file:line`, secret class, and a masked preview (such as `sk_live_***`), never raw secrets, tokens, or real PII.
  - **Non-Blocking Scanner Fallback**: Run ecosystem native audits (`npm`/`pnpm`/`yarn audit`, `pip-audit`, `cargo audit`, `govulncheck`) and optional `PATH`-only scanners (`gitleaks`, `semgrep`, `osv-scanner`) non-blockingly, marking missing or offline tools `SKIPPED` without ever stalling to install tools.
  - Wire narrow escalation hooks across `arcus-mode`, `arcus-plan`, `arcus-work-loop`, and `arcus-review` so security checks fire only on authn/authz, billing, PII/secrets, untrusted input sinks, SSRF/egress, deserialization, CI workflows, or dependency manifests.
  - *Rejected Alternative*: Adding a Mode C inside `arcus-review` (rejected because it bloats routine diff reviews, conflates `F-xx` and `S-xx` ledgers, and lacks an explicit `/arcus-security` user command).
- **Enforced By**: [`skills/arcus-security/SKILL.md`](./skills/arcus-security/SKILL.md), [`skills/arcus-security/references/security-audit-protocol.md`](./skills/arcus-security/references/security-audit-protocol.md), [`scripts/validate.ps1`](./scripts/validate.ps1), and [`rules/AGENTS.md`](./rules/AGENTS.md).

---

## `D-013`: Backend & Data-Access Reliability Guardrails (`backend-reliability.md`)
- **Date / Pin**: `2026-11-26` (Current)
- **Status**: `ACTIVE`
- **Context**: Backend and data-access work frequently regresses in production through unbounded full-table reads, N+1 query loops, database transactions held open across slow network/LLM/payment/queue I/O, missing outbound timeouts or cancellation propagation, indiscriminate retry loops that mask 4xx/logic bugs, missing backpressure/rate limits, and logs leaking credentials or unredacted PII. However, adding an extra top-level skill for routine backend guardrails would bloat `D-002`'s curated core skill menu, placing backend prose inside always-on `rules/AGENTS.md` would tax every non-backend turn, and hardcoding ORM/SDK-specific advice would violate `D-005` (no volatile framework/version fact claims).
- **Decision & Tradeoff**:
  - Encapsulate backend, data-access, and distributed reliability guardrails as the 20th private internal sub-skill at [`skills/arcus-mode/internal/backend-reliability.md`](./skills/arcus-mode/internal/backend-reliability.md), symmetrical to [`typescript-best-practices.md`](./skills/arcus-mode/internal/typescript-best-practices.md), incurring zero always-on token cost on frontend or docs-only sessions.
  - Keep every rule strictly language- and framework-agnostic (`D-005`), delegating cross-boundary convergence mechanics to [`principle-make-operations-idempotent.md`](./skills/arcus-mode/principles/principle-make-operations-idempotent.md) rather than duplicating its prose.
  - Enforce a strict **transient-vs-logic retry boundary**: allow bounded, jittered exponential backoff only for transient transport faults or HTTP 429/503 responses on idempotent operations, while forbidding arbitrary retries that hide logic errors or 4xx bugs (preserving `rules/AGENTS.md` root-cause discipline).
  - Wire on-demand triggers symmetrically across `arcus-mode`, `arcus-plan`, `arcus-work-loop`, `arcus-review`, and `review-rubric.md` with `*(when co-installed; inline fallback: ...)*` guards for `D-002` partial-install safety.
  - *Rejected Alternative*: Adding an extra public `arcus-backend` skill, duplicating backend checklists into always-on `AGENTS.md`, or encoding framework/ORM-specific API rules that rot across versions.
- **Enforced By**: [`skills/arcus-mode/internal/backend-reliability.md`](./skills/arcus-mode/internal/backend-reliability.md), [`skills/arcus-review/references/review-rubric.md`](./skills/arcus-review/references/review-rubric.md), and [`scripts/validate.ps1`](./scripts/validate.ps1).

---

## `D-014`: Per-Skill Third-Party Notices Generated from Root `NOTICE`
- **Date / Pin**: `2026-11-27` (Current)
- **Status**: `ACTIVE`
- **Context**: `npx skills add <repo> --skill <name>` copies only that skill folder, measured with `skills@1.9.0`. The root `NOTICE` and `LICENSES/` never reach a partial install, so 7 skills that hold pstack (MIT), Archify, modern-web-guidance or Korean-catalog (MIT and Apache-2.0) material shipped without the copyright and permission notices those licenses require on every copy.
- **Decision & Tradeoff**:
  - The root `NOTICE` stays the single source. [`scripts/sync-notices.ps1`](./scripts/sync-notices.ps1) writes `skills/<skill>/THIRD_PARTY_NOTICES.md` for every skill that `NOTICE` lists files for. Each file copies the matching `NOTICE` sections verbatim, including Apache-2.0 Section 4(d) lines, drops other skills' file lines, recounts the files, and embeds each referenced license text once.
  - The file is not a `SKILL.md`, so it adds no slash-menu entry and no always-on description tokens. The cost is a regenerate step after every `NOTICE` edit.
  - *Rejected Alternative*: A license header in each of the 72 adapted files. MIT asks for the notice once per copy, not per file, but a header can only point at a license text, and a partial install does not ship that text. Keeping only the root `NOTICE` drops the notices on partial installs.
- **Enforced By**: [`scripts/validate.ps1`](./scripts/validate.ps1) check 6 (`sync-notices.ps1 -Check` fails on a missing, stale, hand-edited or orphaned notice), with regression cases in [`scripts/test-validate.ps1`](./scripts/test-validate.ps1).
