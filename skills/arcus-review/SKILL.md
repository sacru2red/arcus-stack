---
name: arcus-review
description: >-
  Strict, adversarial critique and review skill for both architectural plans
  (arcus-plan) and code changes (diffs/PRs). Use when the user invokes
  "arcus-review", "/arcus-review", or asks for a critique review of a plan,
  architectural audit, code review, PR review, or verification check.
---

# ARCUS Guarded Plan & Code Review (`arcus-review`)

Perform a rigorous, adversarial engineering review focused on root-cause alignment, architectural boundaries, failure modes, and verification evidence. Skip superficial bikeshedding.

Automatically detect the review target from context:
- **Mode A — Plan & Design Critique** (when invoked after `arcus-plan` or on a design proposal before code is written).
- **Mode B — Code & Diff Review** (when invoked on uncommitted changes, commits, or a PR after `arcus-work-loop`).

## Review Procedure

1. **Inspect the Full Target & Surrounding Context**:
   - **For a Plan (Mode A)**: Read the proposed plan/checklist AND inspect the actual repository files, call sites, and manifests the plan claims to touch. Never trust a plan's assumptions without checking the repo.
   - **For Code (Mode B)**: Read the full diff (`git diff` or target files) AND the surrounding callers/callees—do not review lines in isolation.
2. **Audit Against Core Engineering Invariants**:
   - Apply the rubric in [review-rubric.md](./references/review-rubric.md):
     - **Root-Cause & Premise Validity**: Does the plan or diff solve the real root cause, or is it a symptom patch built on a flawed premise?
     - **Boundary, Dependency & Invariant Safety**: Will partial installations, missing links, types, concurrency, or state transitions break?
     - **Blast Radius & Hidden Regressions**: What existing callers, edge cases, or workflows could break?
     - **Verification Evidence Quality**: Are the checklist verification steps (Mode A) or executed tests (Mode B) concrete enough to actually fail when the behavior is broken?
3. **Report Prioritized Findings**:
   - Categorize findings into `[CRITICAL / BLOCKING]`, `[HIGH / BUG RISK]`, and `[NIT / SUGGESTION]`.
   - For each finding, cite the exact plan section or file/line range, explain the concrete failure scenario, and provide a minimal fix.
   - Conclude with an actionable summary of how to revise the plan (before `arcus-work-loop`) or fix the code (before shipping).
