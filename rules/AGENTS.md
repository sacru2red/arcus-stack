# ARCUS-STACK Core Engineering Principles

**ARCUS** (**A**gent **R**ules, **C**ommands & **U**niversal **S**kills) integrates the core engineering philosophies of `pstack` ("Go deep first to go fast") and `oh-my-*` ("Autonomous multi-agent orchestration with real verification evidence"). Architectural decisions and historical trade-offs live in [`DECISIONS.md`](../DECISIONS.md) (read on-demand via `arcus-why`).

## 1. Deep First, Less Code (`pstack` Philosophy)
- **Root Cause Over Symptom Patching**: Never slap a defensive null-check or retry loop over a bug you do not fully understand. Trace the data flow and invariants to the root cause first.
- **Minimal Blast Radius**: Write the smallest, cleanest, and most verifiable change that solves the problem completely. Avoid unrelated formatting or speculative abstractions.
- **Explicit Boundaries**: Respect module boundaries, type safety, and domain invariants.

## 2. Guarded Execution, Isolated Review & Rule Hygiene
- **Separate Strategy from Execution**: For non-trivial tasks, establish a concrete plan and checklist (`arcus-plan`) before modifying production files.
- **Context-Isolated Review & Ledger**: Design reviews and code/PR reviews (`arcus-review`) run in an isolated subagent context on a pinned snapshot so the reviewer does not inherit the author's blind spots. Multi-round reviews track findings in a Review Ledger and judge code changes *before* reading author replies.
- **Rule Hygiene & No Volatile Fact Claims**: Never write static claims about library/API behavior (*"API X works like Y"*) in rules; they rot on version upgrades. Repeatedly violated rules must be escalated into architecture, types, or lints (`arcus-correct`), while unused or redundant rules are pruned.
- **Evidence-Driven Completion**: A task is never complete until verified by real execution evidence (typecheck, linter, unit/integration tests, or reproducible CLI check).

## 3. Active Rule Enforcement Table (`arcus-correct`)

| Rule / Invariant | Enforced By |
| :--- | :--- |
| Universal 5-agent `SKILL.md` frontmatter (`name` + `description` only, no broken relative links) | Automated PowerShell validation check & [`universal-skill-spec.md`](../skills/arcus-skill-maker/references/universal-skill-spec.md) |
| Two-tier encapsulation (only 12 public `skills/arcus-*/SKILL.md` entrypoints; helpers under `skills/arcus-mode/`) | One-level scanner boundary & [`DECISIONS.md` (`D-002`)](../DECISIONS.md) |
| Stale `arcus-*` junctions and `.skill-lock.json` entries pruned on rename/update | [`scripts/install-global.ps1`](../scripts/install-global.ps1) & [`scripts/install-global.sh`](../scripts/install-global.sh) |
| Context-isolated review, Cold-Reader test, and code-first Review Ledger | [`skills/arcus-review/SKILL.md`](../skills/arcus-review/SKILL.md) & [`review-ledger-protocol.md`](../skills/arcus-review/references/review-ledger-protocol.md) |

## 4. Available Core Skills (`arcus-*`)
- `arcus-mode`: Master operating mode enforcing the 24 deep-first principles, 22 task playbooks, unslopped prose, and deliberate subagent delegation.
- `arcus-plan`: Deep-first root-cause analysis, blast-radius mapping, and an actionable execution and verification checklist tailored to the task goal.
- `arcus-work-loop`: Autonomous checklist-driven execution loop that implements, diagnoses, and checks off each task item with real verification evidence.
- `arcus-review`: Context-isolated critique and review for both architectural plans (`arcus-plan`) and code changes (`arcus-work-loop`), maintaining a persistent Review Ledger.
- `arcus-in-your-own-words`: Restate the user's goal and core problem in your own words to verify alignment before acting.
- `arcus-create-verification`: Generate and prove a project-local verification skill (`verify-<app>`) and user-POV feature map.
- `arcus-maintain-verification`: Audit and update an existing project verification skill via parallel source readers and a live driving pass.
- `arcus-ketchup`: Catch the user up on what changed since their last message in plain words, visuals, and decision-ready action items.
- `arcus-why`: Answer "why does X work this way" from `DECISIONS.md`, git commit history, and PR discussions rather than guessing from current code.
- `arcus-correct`: Eliminate repeated agent mistakes via architecture, types, lints, or behavior tests, and prune dead, redundant, or brittle fact-claim rules.
- `arcus-automate-me`: Mine recent conversation transcripts and interview the user to draft or update a personal `<handle>-mode` skill.
- `arcus-skill-maker`: Meta-skill for absorbing, remixing, and standardizing external skills into universal 5-agent compatible `arcus-*` skills.
