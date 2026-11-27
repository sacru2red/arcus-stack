# ARCUS-STACK Core Engineering Principles

**ARCUS** (**A**gent **R**ules, **C**ommands & **U**niversal **S**kills) integrates the core engineering philosophies of `pstack` ("Go deep first to go fast") and `oh-my-*` ("Autonomous multi-agent orchestration with real verification evidence"). Architectural decisions and historical trade-offs live in [`DECISIONS.md`](../DECISIONS.md) (read on-demand via `arcus-why`).

## 1. Deep First, Less Code (`pstack` Philosophy)
- **Root Cause Over Symptom Patching**: Never slap a defensive null-check or retry loop over a bug you do not fully understand. Trace the data flow and invariants to the root cause first.
- **Minimal Blast Radius**: Write the smallest, cleanest, and most verifiable change that solves the problem completely. Avoid unrelated formatting or speculative abstractions.
- **Explicit Boundaries**: Respect module boundaries, type safety, and domain invariants.

## 2. Guarded Execution, Isolated Review & Rule Hygiene
- **Separate Strategy from Execution**: For non-trivial tasks, establish a concrete plan and checklist (`arcus-plan`) before modifying production files.
- **Context-Isolated Review & Ledger**: Design reviews and code/PR reviews (`arcus-review`) run in an isolated subagent context on a pinned snapshot so the reviewer does not inherit the author's blind spots. Multi-round reviews track findings in a Review Ledger and judge code changes *before* reading author replies.
- **Rule Hygiene & No Volatile Fact Claims**: Never write static claims about library/API behavior (*"API X works like Y"*) in rules; they rot on version upgrades. For HTML, CSS, or client-side JS/DOM tasks, query live web platform standards via `npx -y modern-web-guidance@latest search "<query>"` and `retrieve "<id>"` ([`skills/arcus-mode/internal/modern-web-guidance.md`](../skills/arcus-mode/internal/modern-web-guidance.md)) rather than relying on outdated training-weight patterns. For architecture, workflow, sequence, data-flow, lifecycle/state, ERD, class, tree, timeline, or waterfall visualization and 1-page visual explainer requests, prioritize [`tt-a1i/archify`](https://github.com/tt-a1i/archify) via [`skills/arcus-mode/internal/archify-visualization.md`](../skills/arcus-mode/internal/archify-visualization.md) (writing temporary outputs to `os.tmpdir()/archify/` so the git working tree stays clean) before falling back to static Mermaid. Repeatedly violated rules must be escalated into architecture, types, or lints (`arcus-correct`), while unused or redundant rules are pruned.
- **Evidence-Driven Completion**: A task is never complete until verified by real execution evidence (typecheck, linter, unit/integration tests, or reproducible CLI check).

## 3. Active Rule Enforcement Table (`arcus-correct`)

| Rule / Invariant | Enforced By |
| :--- | :--- |
| Universal 5-agent `SKILL.md` frontmatter (`name` + `description` only, no broken relative links) | [`scripts/validate.ps1`](../scripts/validate.ps1) & [`universal-skill-spec.md`](../skills/arcus-skill-maker/references/universal-skill-spec.md) |
| Two-tier encapsulation (only 15 public `skills/arcus-*/SKILL.md` entrypoints; helpers under `skills/arcus-mode/`) | One-level scanner boundary & [`DECISIONS.md` (`D-002`, `D-008`, `D-009`, `D-012`)](../DECISIONS.md) |
| Stale `arcus-*` junctions and `.skill-lock.json` entries pruned on rename/update | [`scripts/install-global.ps1`](../scripts/install-global.ps1) & [`scripts/install-global.sh`](../scripts/install-global.sh) |
| Context-isolated review, Cold-Reader test, and code-first Review Ledger | [`skills/arcus-review/SKILL.md`](../skills/arcus-review/SKILL.md) & [`review-ledger-protocol.md`](../skills/arcus-review/references/review-ledger-protocol.md) |
| User-authorized `DECISIONS.md` proposals & 3-tier opt-out persistence (Git config / `AGENTS.md` comment / `.agents/settings.json`) | [`skills/arcus-mode/internal/decisions.md`](../skills/arcus-mode/internal/decisions.md) & [`DECISIONS.md` (`D-006`)](../DECISIONS.md) |
| Live modern web platform lookup (`npx -y modern-web-guidance@latest search/retrieve`) before authoring or reviewing HTML/CSS/client-side JS | [`skills/arcus-mode/internal/modern-web-guidance.md`](../skills/arcus-mode/internal/modern-web-guidance.md) & [`DECISIONS.md` (`D-007`)](../DECISIONS.md) |
| Engineering & Domain Brain (`ONBOARDING.md` 7-pillar domain-to-code mappings, business invariants, authz tiers, and legacy minefields with `[as of YYYY-MM-DD \| Source: ...]` tags) | [`skills/arcus-onboard/SKILL.md`](../skills/arcus-onboard/SKILL.md) & [`DECISIONS.md` (`D-008`)](../DECISIONS.md) |
| Visual UI 4-screenshot proposal (`00-before.png` + `01-option-a..c.png` via sequential working-branch apply ➔ capture ➔ patch save ➔ `git restore` revert before user selection) | [`skills/arcus-ui-propose/SKILL.md`](../skills/arcus-ui-propose/SKILL.md) & [`DECISIONS.md` (`D-009`)](../DECISIONS.md) |
| Archify-first visualization routing (`tt-a1i/archify` 10 diagram types, 1-page visual explainers, and codebase architecture diagnosis isolated under `os.tmpdir()/archify/` with non-blocking 3-tier fallback) | [`skills/arcus-mode/internal/archify-visualization.md`](../skills/arcus-mode/internal/archify-visualization.md) & [`DECISIONS.md` (`D-010`)](../DECISIONS.md) |
| Zero-downtime Expand-Contract migrations for live DB schemas, persisted queues/caches, and rolling-deploy wire contracts (separate Expand/dual-write PR, chunked idempotent backfill + parity check, separate Contract PR; exempt from single-wave cutover) | [`skills/arcus-mode/playbooks/safe-migration.md`](../skills/arcus-mode/playbooks/safe-migration.md) & [`DECISIONS.md` (`D-011`)](../DECISIONS.md) |
| PoC-backed security, authz/IDOR, redacted secret hygiene, and non-blocking supply-chain auditing (local/isolated PoCs only, `S-01`.. ledger) | [`skills/arcus-security/SKILL.md`](../skills/arcus-security/SKILL.md) & [`DECISIONS.md` (`D-012`)](../DECISIONS.md) |

## 4. Available Core Skills (`arcus-*`)
- `arcus-mode`: Master operating mode enforcing the 24 deep-first principles, 23 task playbooks, unslopped prose, and deliberate subagent delegation.
- `arcus-plan`: Deep-first root-cause analysis, blast-radius mapping, and an actionable execution and verification checklist tailored to the task goal.
- `arcus-work-loop`: Autonomous checklist-driven execution loop that implements, diagnoses, and checks off each task item with real verification evidence.
- `arcus-review`: Context-isolated critique and review for both architectural plans (`arcus-plan`) and code changes (`arcus-work-loop`), maintaining a persistent Review Ledger.
- `arcus-explain`: Explain goals, architectural plans, completed code changes, or complex concepts calibrated internally to a 20-something SW/CS graduate level (CS mental models, mechanism & trade-offs, no childish analogies or fluff; never echo the internal persona label in visible headings/text, and localize all headings and 4 bullet labels to the user's active conversation language); automatically briefs at the end of `arcus-plan`, `arcus-work-loop`, and non-trivial `arcus-mode` runs.
- `arcus-security`: Context-isolated, PoC-backed security, authz/IDOR, redacted secret hygiene, and non-blocking supply-chain audit skill with local-only negative tests and a persistent Security Findings Ledger (`S-01`, `S-02`, ...).
- `arcus-ui-propose`: Capture 1 baseline ("Before") screenshot and 3 distinct proposed variant screenshots (Option A, B, C) for visual UI work by sequentially applying, capturing, saving patch files, and reverting on the working branch until the user selects an option.
- `arcus-create-verification`: Generate and prove a project-local verification skill (`verify-<app>`) and user-POV feature map.
- `arcus-maintain-verification`: Audit and update an existing project verification skill via parallel source readers and a live driving pass.
- `arcus-ketchup`: Catch the user up on what changed since their last message in plain words, visuals, and decision-ready action items.
- `arcus-why`: Answer "why does X work this way" from `DECISIONS.md`, git commit history, and PR discussions rather than guessing from current code.
- `arcus-correct`: Eliminate repeated agent mistakes via architecture, types, lints, or behavior tests, and prune dead, redundant, or brittle fact-claim rules.
- `arcus-automate-me`: Mine recent conversation transcripts and interview the user to draft or update a personal `<handle>-mode` skill.
- `arcus-onboard`: Build and maintain a 1–2 page Engineering & Domain Brain (`ONBOARDING.md`) covering the 7 non-guessable domain and codebase pillars (system boundaries, domain term ↔ code/DB mappings, business formulas & invariants, authz & plan/tier gating, legacy minefields & red lines, systems of record, and error/UX/PR conventions) with date and provenance tags.
- `arcus-skill-maker`: Meta-skill for absorbing, remixing, and standardizing external skills into universal 5-agent compatible `arcus-*` skills.
