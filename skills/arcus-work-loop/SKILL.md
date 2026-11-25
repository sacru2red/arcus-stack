---
name: arcus-work-loop
description: >-
  Autonomous checklist-driven execution and verification loop. Use when the user
  invokes "arcus-work-loop", "/arcus-work-loop", "work-loop", or asks to
  autonomously implement, fix, and verify a feature or bug item-by-item until
  every verification condition passes.
---

# ARCUS Work Loop (`arcus-work-loop`)

Execute the task autonomously in an iterative implementation-and-verification loop from discovery through verified completion without stopping prematurely or leaving half-finished stubs.

## Execution Loop

1. **Adopt or Build the Task Checklist**:
   - If an `arcus-plan` checklist already exists in the conversation, adopt its `- [ ]` items as your live execution tracker.
   - Otherwise, perform a fast parallel discovery of the relevant files/tests and construct a goal-aligned checklist where every item pairs a concrete edit with a verification check.
2. **Minimal, High-Precision Implementation**:
   - Work through the checklist systematically, following existing codebase conventions, types, and module boundaries.
   - Never apply symptom patches (e.g., swallowing errors, arbitrary timeouts, blind null checks). Fix the underlying logic.
   - If new requirements or edge cases surface mid-task, update the checklist dynamically so nothing is forgotten.
3. **Self-Diagnostics & Guarded Repair**:
   - Immediately run each item's verification check (typecheck, linter, unit/integration tests, build) after editing.
   - Mark an item `- [x]` **only** after its verification check passes with real evidence. If a check fails, diagnose the root cause and fix all reported issues before re-running.
4. **Evidence-Gated Completion**:
   - Audit your final state against [work-loop-checklist.md](./references/work-loop-checklist.md).
   - Present the completed checklist (`- [x]`) alongside the concrete verification evidence (commands run and their outputs).
