# ARCUS Plan & Verification Checklist Template

Use this structure when presenting an `arcus-plan` output:

## 1. Context & Root Cause / Core Seam
- **Observed Behavior / Requirement**: What needs to change and why.
- **Root Cause / Architectural Seam**: The exact file(s), function(s), and invariant(s) responsible (link to specific file paths and lines).

## 2. Blast Radius & Invariants
- **Files to Modify**: List of target files and the exact responsibility of each edit.
- **Invariants to Preserve**: Contracts, types, backwards compatibility, or performance constraints that must not break.

## 3. Actionable Execution & Verification Checklist
Write each step as an unchecked box (`- [ ]`) that pairs the **concrete action** with its **observable verification proof**. During execution (`arcus-work-loop`), items are marked `- [x]` only after their verification condition passes.

- [ ] **Step 1 — [Target File / Module]**: Concrete change description.
  - ➔ **Verify**: Exact check or command (e.g., `npm test -- path/to/test`, typecheck passes, or specific boundary behavior confirmed).
- [ ] **Step 2 — [Target File / Module]**: Concrete change description.
  - ➔ **Verify**: Exact check or command.
- [ ] **Step 3 — [Edge Cases & Regression Tests]**: Specific failure modes, empty/boundary inputs, or regression tests added/updated.
  - ➔ **Verify**: Test suite execution command and expected passing output.

## 4. Plan Briefing (`arcus-explain` — 20s CS Grad Tone)
Immediately after the checklist, explain the plan in the tone of briefing a **20-something Software Engineering / CS undergraduate graduate (fresh junior engineer)** per [`arcus-explain`](../../arcus-explain/SKILL.md) (when co-installed; no childish analogies, no pompous architectural fluff, translate repo-specific domain jargon into standard CS mental models):
- **One-Line Essence (`What`)**: One plain sentence capturing what this plan changes and why.
- **CS Mental Model (`How to picture it`)**: Map the design seam to a familiar CS construct or data-flow model.
- **Mechanism & Trade-offs (`Why this way`)**: The concrete input ➔ transformation ➔ output flow and why this approach wins over alternatives.
- **Impact & Done Criteria (`So what`)**: What changes in runtime/developer behavior and what verification proof closes the loop.

## 5. Architectural Decision Record Proposal (Optional — Only for Non-Trivial Trade-offs)
If this plan settles a major architectural trade-off and the workspace has not opted out (`git config --local --get arcus.decisions` != `off`, no `<!-- arcus:decisions=off -->` in `AGENTS.md`/`CLAUDE.md`, and no `"decisions": "off"` in `.agents/settings.json`), ask the user for authorization:
1. Record `D-xxx` in `DECISIONS.md` (or existing `ADR.md` / `docs/adr/`).
2. Skip for this task.
3. Opt out for this project (with user authorization, persist via Tier 1 `git config --local arcus.decisions off`, Tier 2 `<!-- arcus:decisions=off -->` in `AGENTS.md`/`CLAUDE.md`, or Tier 3 `.agents/settings.json` merge).
