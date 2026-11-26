---
name: arcus-review
description: >-
  Strict, context-isolated critique and review skill for both architectural
  plans (arcus-plan) and code changes (diffs/PRs) with a persistent review
  ledger. Use when the user invokes "arcus-review", "/arcus-review", or asks for
  a critique review of a plan, architectural audit, code review, PR review, or
  verification check.
---

# ARCUS Context-Isolated Plan & Code Review (`arcus-review`)

> *"A reviewer that shares the author's context shares the author's blind spots."*

Never review a plan or diff inside the same mental context that created it. Perform a rigorous, adversarial review in an isolated context using a pinned snapshot and a persistent **Review Ledger**.

## 1. Context Isolation First (Sandbox the Review)

- **Primary (Spawn a Fresh Subagent)**: When a subagent tool (`invoke_subagent`, `delegate_task`, `Agent`, or `spawn_agent`) is available and you are in the parent session that authored the plan or code, delegate the review to a **fresh, read-only subagent**.
  - **No Framing / No Leading the Witness**: Pass ONLY:
    1. The pinned snapshot identifier (see [review-ledger-protocol.md](./references/review-ledger-protocol.md)).
    2. The target file paths, diff command, or the **verbatim** unedited plan text/file path.
    3. The existing Findings Ledger Table (if Round 2+).
    4. The path to this `SKILL.md`.
  - Never include your reasoning, why you rejected alternatives, or defensive explanations in the subagent kickoff prompt.
- **Fallback (Already in an Isolated Subagent / No Subagent Tool)**: Perform an explicit **Cold-Reader Reset**. Treat all unrecorded chat history as non-existent and judge strictly from the on-disk snapshot and external documentation.

## 2. Mode Detection & Review Procedure

### Mode A — Isolated Plan & Design Critique (After `arcus-plan`)
1. **Pin Snapshot & Verify Repo Grounding**: Pin `HEAD` SHA and read the actual repository files the plan claims to touch (plus `ONBOARDING.md` / `CONTEXT.md` if present, verifying whether the plan respects documented domain mappings, business invariants, and legacy minefields). Never trust a plan's claims without checking the codebase.
2. **Cold-Reader Extraction Test**: Using *only* the plan document and repo files, extract: (a) the exact root cause/seam, (b) the data/state boundary being changed, and (c) what breaks if step N fails. Any unstated assumption the reader must guess is logged as a ledger finding (`F-xx`).
3. **External Reference Check**: When the design involves external APIs, third-party libraries, CLI flags, or protocol specs, look up current external references/docs rather than relying purely on internal repo conventions. For HTML, CSS, or client-side JS/DOM designs and diffs, verify platform capabilities and Baseline fallbacks via `npx -y modern-web-guidance@latest search "<2-5 word query>"` and `retrieve "<id>"`.
4. **Audit & Ledger Output**: Apply [review-rubric.md](./references/review-rubric.md) and output the prioritized findings and **Review Ledger** per [review-ledger-protocol.md](./references/review-ledger-protocol.md).

### Mode B — Isolated Code & PR Review (After `arcus-work-loop` or on PRs)
1. **Pin Snapshot**: Pin `base..head` SHA (or `HEAD` SHA + `git diff HEAD | git hash-object --stdin` for uncommitted changes).
2. **Round 2+ Blind Ledger Check First**: If a Review Ledger exists from an earlier round, follow [review-ledger-protocol.md](./references/review-ledger-protocol.md) strictly—judge every open finding from the **code snapshot alone** *before* opening the author's replies or explanations (`RESOLVED`, `UNRESOLVED`, `VALID_PUSHBACK`, `DISPUTED`).
3. **Full Diff, Callers & External Docs Audit**: Inspect the diff, surrounding callers/callees, `ONBOARDING.md` / `CONTEXT.md` domain invariants and minefields (when present), external library docs, and (for TypeScript or stateful changes) [`typescript-best-practices.md`](../arcus-mode/internal/typescript-best-practices.md) *(when co-installed)* against [review-rubric.md](./references/review-rubric.md).
4. **Report Ledger & Prioritized Findings**: Output the updated Findings Ledger Table (`F-01`, `F-02`, ...) categorized into `[CRITICAL / BLOCKING]`, `[HIGH / BUG RISK]`, and `[NIT / SUGGESTION]` with exact `file:line` citations, failure scenarios, and minimal fixes.
