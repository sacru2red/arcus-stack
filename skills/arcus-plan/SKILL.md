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
   - Read the actual implementation files, types, and call sites along the data/control flow.
   - Distinguish the **underlying invariant or root cause** from surface symptoms.
   - For web UI, HTML/CSS, or client-side JS/DOM tasks, query live web platform standards first via `npx -y modern-web-guidance@latest search "<2-5 word query>"` and `npx -y modern-web-guidance@latest retrieve "<id>"` (with `npx --offline -y` fallback if offline) instead of designing around legacy patterns.
2. **Map the Blast Radius & Boundaries**:
   - Identify every module, interface, test, and consumer affected by the proposed change.
   - Prefer the smallest structural change that preserves clean boundaries over sprawling edits.
3. **Evaluate Trade-offs**:
   - If there are multiple viable designs, compare at most 2 options with explicit pros/cons and recommend the cleanest path.
   - Ask the user a concise question **only** if a missing product/design decision would materially alter the plan.
4. **Produce the Plan & Actionable Verification Checklist**:
   - Follow the exact structure in [plan-template.md](./references/plan-template.md).
   - Never write vague checklist items like `- [ ] Fix bug` or `- [ ] Update tests`. Every checklist item (`- [ ]`) must pair a **concrete file/module change** with its **exact verification condition** (`➔ Verify: <command or observable proof>`).
5. **Propose `DECISIONS.md` Record (When Architectural Trade-offs Exist)**:
   - If the plan settles a significant architectural trade-off, check the workspace's 3-tier opt-out status (`git config --local --get arcus.decisions` == `off`, `<!-- arcus:decisions=off -->` in `AGENTS.md`/`CLAUDE.md`, or `"decisions": "off"` in `.agents/settings.json`).
   - If not opted out, offer an optional checklist item or prompt asking user authorization to record `D-xxx` in `DECISIONS.md` (or to opt out for this project via the 3-tier fallback chain). Never create `DECISIONS.md` or write opt-out configs without explicit user authorization.
