---
name: decisions
description: "Internal sub-skill for proposing and recording architectural decisions (DECISIONS.md / ADR) with explicit user authorization and 3-tier opt-out persistence."
---

# Architectural Decision Records (`DECISIONS.md`) & Opt-Out Protocol

Use this protocol when an architectural trade-off is settled (`arcus-plan`, `arcus-mode`, `arcus-work-loop`) or a recurring mistake is structurally enforced (`arcus-correct`).

## 1. Execution Context Rule (No Mid-Loop or Subagent Interrupts)

- **Subagents (`worker.md`) & Unattended Mid-Loop Runs**: Never call a user-question tool mid-flight and never write to `DECISIONS.md` or opt-out configs unprompted. Instead, include a concise `Proposed Decision (D-xxx candidate)` note in your return summary.
- **Top-Level Interactive Turn Only**: Only the top-level interactive turn (at the end of `arcus-plan`, `arcus-correct`, or the final report of `arcus-work-loop` / `arcus-mode`) may prompt the user for authorization.

## 2. Step 1 — Pre-Check Project Opt-Out & Existing ADR Files

Before proposing any decision record, check whether the project has already opted out. If **any** of the three tiers below is set to `off`, **stay completely silent and do not propose `DECISIONS.md`**:

1. **Tier 1 (Local Git Config)**: In a Git repo, check `git config --local --get arcus.decisions` (ignore non-zero exit codes `1` when unset or `128` when not a Git repo). If the output is `off`, stop.
2. **Tier 2 (Root Agent Rules)**: Check if the workspace's `AGENTS.md` or `CLAUDE.md` contains `<!-- arcus:decisions=off -->`. If present, stop.
3. **Tier 3 (Non-Git Workspace Config)**: Check if `.agents/settings.json` in the workspace contains `"decisions": "off"`. If present, stop.

Next, check if the workspace already has an active decision log (`DECISIONS.md`, `ADR.md`, or `docs/adr/`).

## 3. Step 2 — Explicit User Authorization (Mandatory)

Never create or modify `DECISIONS.md`—and never write an opt-out setting—without explicit user authorization. When a significant architectural trade-off or rule graduation occurs (skip trivial bug fixes), ask the user via your structured question tool (`ask_question` / `AskQuestion`):

- **If no `DECISIONS.md` / ADR exists yet**:
  1. **Create `DECISIONS.md` and record `D-001`** (Recommended for long-lived projects so `arcus-why` can trace rationale)
  2. **Skip this time** (Do not record now, ask again on future architectural decisions)
  3. **Do not use `DECISIONS.md` in this project** (Authorize saving an opt-out marker so agents never ask again in this workspace)
- **If `DECISIONS.md` / `ADR.md` / `docs/adr/` already exists**:
  1. **Append `D-xxx` to the existing decision log**
  2. **Skip this time**
  3. **Turn off future ADR prompts in this project** (Authorize saving an opt-out marker)

## 4. Step 3 — 3-Tier Opt-Out Persistence Fallback Chain (When Option 3 is Authorized)

When the user selects Option 3 (authorizing opt-out), persist the setting using the first applicable tier below:

1. **Tier 1 (Git Repository — Zero Working-Tree Pollution)**:
   - If `.git` exists (and the user did not explicitly ask to commit the setting for the whole team), run:
     `git config --local arcus.decisions off`
2. **Tier 2 (Non-Git with `AGENTS.md` / `CLAUDE.md`, or Explicit Team-Shared Opt-Out)**:
   - If `AGENTS.md` or `CLAUDE.md` exists in the workspace root, append `<!-- arcus:decisions=off -->` at the end of the file.
3. **Tier 3 (Non-Git Folder Without `AGENTS.md` / `CLAUDE.md`)**:
   - Create or read `.agents/settings.json` in the workspace root, merge `"decisions": "off"` without overwriting existing JSON keys, and save.

## 5. Step 4 — `DECISIONS.md` Entry Schema (When Option 1 is Authorized)

Record directional judgments, rejected alternatives, and structural enforcements—**never** volatile API fact claims (*"Library X returns Y"*).

```markdown
## `D-xxx`: <Concise Decision Title>
- **Date / Pin**: `YYYY-MM-DD` (`<commit-sha or N/A>`)
- **Status**: `ACTIVE` (or `SUPERSEDED BY D-yyy`)
- **Context**: Why this decision was needed and what problem/constraint triggered it.
- **Decision & Tradeoff**: What direction was chosen and which alternative was rejected.
- **Enforced By**: The architecture boundary, type, lint script, test, or skill contract that enforces it.
```
