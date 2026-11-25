---
name: arcus-work
description: >-
  Autonomous end-to-end execution loop (Ultrawork / Autopilot). Use when the
  user invokes "arcus-work", "ulw", "ultrawork", or asks to autonomously
  implement, fix, and verify a feature or bug end-to-end until completion.
---

# ARCUS Ultrawork Execution (`arcus-work`)

Execute the task autonomously from deep discovery through verified completion without stopping prematurely or leaving half-finished stubs.

## Execution Loop

1. **Deep Discovery & Micro-Plan**:
   - Locate all relevant files, existing patterns, and test suites in parallel.
   - Establish the root cause or cleanest integration point before making edits.
2. **Minimal, High-Precision Implementation**:
   - Follow existing codebase conventions, types, and module boundaries.
   - Never apply symptom patches (e.g., swallowing errors, arbitrary timeouts, blind null checks). Fix the underlying logic.
   - Delegate independent research or isolated workstreams to subagents when available and beneficial.
3. **Self-Diagnostics & Guarded Repair**:
   - Immediately run diagnostics (typecheck, linter, unit/integration tests, build) after editing.
   - If a check fails, diagnose the root cause of the failure and fix all reported issues before re-running.
4. **Evidence-Gated Completion**:
   - Review your work against [ultrawork-checklist.md](./references/ultrawork-checklist.md).
   - Report the final summary with concrete verification evidence (commands run and their results).
