---
name: arcus-review
description: >-
  Strict, evidence-driven code review and architectural audit skill. Use when
  the user invokes "arcus-review" or asks for a rigorous code review, PR review,
  pre-commit audit, or verification check of recent changes.
---

# ARCUS Guarded Code Review (`arcus-review`)

Perform a rigorous, adversarial engineering review focused on correctness, root-cause alignment, architectural boundaries, and verification evidence. Skip superficial bikeshedding.

## Review Procedure

1. **Inspect the Full Diff & Context**:
   - Read the actual diff (`git diff` or target files) AND the surrounding call sites/callers—do not review lines in isolation.
2. **Audit Against Core Engineering Invariants**:
   - Apply the rubric in [review-rubric.md](./references/review-rubric.md):
     - **Root-Cause Validity**: Is this a symptom patch or a true fix?
     - **Boundary & Invariant Safety**: Are types, concurrency, error propagation, and state transitions sound?
     - **Blast Radius & Regressions**: Could existing callers break?
     - **Verification Evidence**: Do tests actually prove the fix and fail without it?
3. **Report Prioritized Findings**:
   - Categorize findings into `[CRITICAL / BLOCKING]`, `[HIGH / BUG RISK]`, and `[NIT / SUGGESTION]`.
   - For each finding, cite the exact file and line range, explain the concrete failure scenario, and provide a minimal fix.
   - If no issues are found, explicitly state what invariants and evidence were verified.
