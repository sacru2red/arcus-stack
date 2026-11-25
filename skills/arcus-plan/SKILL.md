---
name: arcus-plan
description: >-
  Deep-first architectural planning and task checklist generator. Use when the
  user invokes "arcus-plan", asks for a deep plan, architectural design,
  root-cause investigation, or an actionable execution and verification
  checklist before coding.
---

# ARCUS Deep-First Planning & Checklist (`arcus-plan`)

> *"If you want to go fast, go deep first."*

Do not write or modify production code during the planning phase. Your goal is to trace the system deeply, identify the exact root cause or architectural seam, and produce a concise, decision-complete plan with an **actionable execution and verification checklist** ready to be critiqued by `arcus-review` or driven directly by `arcus-work-loop`.

## Workflow

1. **Trace to the Root Cause (No Guessing)**:
   - If `ONBOARDING.md` (or `CONTEXT.md`) exists in the workspace, read it first to align on domain-to-code identifier mappings, business formulas/invariants, authz boundaries, systems of record, and legacy minefields (always cross-checking cited file/schema paths against live code; if live code was refactored, trust live code and note the stale onboarding entry for `arcus-onboard` Mode 2 update).
   - Read the actual implementation files, types, and call sites along the data/control flow.
   - Distinguish the **underlying invariant or root cause** from surface symptoms.
   - For web UI, HTML/CSS, or client-side JS/DOM tasks, query live web platform standards first via `npx -y modern-web-guidance@latest search "<2-5 word query>"` and `npx -y modern-web-guidance@latest retrieve "<id>"` (with `npx --offline -y` fallback if offline) instead of designing around legacy patterns.
2. **Map the Blast Radius & Boundaries**:
   - Identify every module, interface, test, and consumer affected by the proposed change.
   - Prefer the smallest structural change that preserves clean boundaries over sprawling edits.
3. **Evaluate Trade-offs, Visual UI Proposals (`arcus-ui-propose`) & Architecture Visualization (`archify`)**:
   - If there are multiple viable designs, compare at most 2 options with explicit pros/cons and recommend the cleanest path.
   - **Visual UI Tasks (`arcus-ui-propose` Trigger)**: For visual UI creation, layout changes, styling updates, or component redesigns (unless the user explicitly asks to skip options), invoke [`arcus-ui-propose`](../arcus-ui-propose/SKILL.md) (when co-installed) or include a dedicated Step 1 in the checklist to capture **1 Baseline ("Before") screenshot** (`00-before.png`) and **3 distinct proposed variant screenshots** (`01-option-a.png`, `02-option-b.png`, `03-option-c.png`) by sequentially applying, capturing, saving patch diffs (`.audit/ui-propose/<task-slug>/option-{a,b,c}.patch` + `files-{a,b,c}/`), and reverting the working branch (`git checkout HEAD -- <files>`) before locking in the final UI implementation.
   - **Diagram & Architecture Visualization Requests (`archify` Priority)**: When the user asks to visualize an architecture, workflow, sequence, data flow, state lifecycle, ERD, class hierarchy, tree, timeline, or waterfall (or asks for a visual 1-page plan/explainer), prioritize [`tt-a1i/archify`](https://github.com/tt-a1i/archify) per [`archify-visualization.md`](../arcus-mode/internal/archify-visualization.md) *(when co-installed)*. *Inline fallback (when `arcus-mode` is not co-installed)*: (1) Locate `archify/bin/archify.mjs` in `.agents/skills` or global agent skill folders (`~/.agents/skills`, `~/.gemini/config/skills`, `~/.t3/userdata/providers/antigravity/*/config/skills`, `~/.claude/skills`, `~/.codex/skills`, `~/.cursor/skills`, `~/.config/opencode/skills`), (2) if missing, auto-bootstrap non-blockingly via `npx -y skills@latest add https://archify.si --skill archify -g --copy --yes`, and run `node "<archify.mjs>" finalize <type> ...` outputting to `<os.tmpdir()>/archify/<slug>/` so `git status` remains completely clean during planning, or (3) fall back to Mermaid / declared `html_render` with a 1-line note if offline.
   - Ask the user a concise question **only** if a missing product/design decision (or choosing among the 3 visual UI proposal screenshots) would materially alter the plan.
4. **Produce the Plan & Actionable Verification Checklist**:
   - Follow the exact structure in [plan-template.md](./references/plan-template.md).
   - Never write vague checklist items like `- [ ] Fix bug` or `- [ ] Update tests`. Every checklist item (`- [ ]`) must pair a **concrete file/module change** with its **exact verification condition** (`➔ Verify: <command or observable proof>`).
5. **Deliver End-of-Plan Briefing via `arcus-explain`**:
   - Immediately after the checklist (and before any optional `DECISIONS.md` authorization prompt), include a concise **Plan Briefing** following [`arcus-explain`](../arcus-explain/SKILL.md) (when co-installed).
   - *Inline fallback & Output Hygiene*: Calibrate the depth internally to a 20-something SW/CS graduate (assume standard CS fundamentals, decode repo-specific jargon into clean CS mental models, no childish analogies or fluff), **never print the internal persona label (`20s CS Grad` / `20대 SW 학과 졸업생...`) in headings or prose**, and **localize the heading and all 4 bullet labels into the user's conversation language** (e.g., in Korean: **핵심 요약**, **구조 및 동작 모델**, **동작 원리 및 트레이드오프**, **적용 효과 및 검증 기준**; in English: **Core Essence**, **Mental Model**, **Mechanism & Trade-offs**, **Impact & Verification**).
6. **Propose `DECISIONS.md` Record (When Architectural Trade-offs Exist)**:
   - If the plan settles a significant architectural trade-off, check the workspace's 3-tier opt-out status (`git config --local --get arcus.decisions` == `off`, `<!-- arcus:decisions=off -->` in `AGENTS.md`/`CLAUDE.md`, or `"decisions": "off"` in `.agents/settings.json`).
   - If not opted out, offer an optional checklist item or prompt asking user authorization to record `D-xxx` in `DECISIONS.md` (or to opt out for this project via the 3-tier fallback chain). Never create `DECISIONS.md` or write opt-out configs without explicit user authorization.
