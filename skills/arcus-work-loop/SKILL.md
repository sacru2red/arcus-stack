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
   - If `ONBOARDING.md` (or `CONTEXT.md`) exists in the workspace, consult it first so your implementation respects domain-to-code mappings, business invariants, authz tiers, and legacy red-line minefields (verifying cited code paths against live code).
   - If an `arcus-plan` checklist already exists in the conversation, adopt its `- [ ]` items as your live execution tracker.
   - Otherwise, perform a fast parallel discovery of the relevant files/tests and construct a goal-aligned checklist where every item pairs a concrete edit with a verification check.
2. **Minimal, High-Precision Implementation**:
   - Work through the checklist systematically, following existing codebase conventions, types, and module boundaries.
   - For HTML/CSS or client-side JS/DOM changes, consult `npx -y modern-web-guidance@latest search "<2-5 word query>"` and `retrieve "<id>"` (falling back to `npx --offline -y` or skipping non-blockingly if offline) before writing custom UI or DOM workarounds.
   - Never apply symptom patches (e.g., swallowing errors, arbitrary timeouts, blind null checks). Fix the underlying logic.
   - If new requirements or edge cases surface mid-task, update the checklist dynamically so nothing is forgotten.
3. **Self-Diagnostics & Guarded Repair**:
   - Immediately run each item's verification check (typecheck, linter, unit/integration tests, build) after editing.
   - Mark an item `- [x]` **only** after its verification check passes with real evidence. If a check fails, diagnose the root cause and fix all reported issues before re-running.
4. **Evidence-Gated Completion & `arcus-explain` Briefing**:
   - Audit your final state against [work-loop-checklist.md](./references/work-loop-checklist.md).
   - Present the completed checklist (`- [x]`) alongside the concrete verification evidence (commands run and their outputs).
   - Immediately after the verification evidence (and before any optional `DECISIONS.md` prompt), include a concise **Completion Briefing** following [`arcus-explain`](../arcus-explain/SKILL.md) (when co-installed). *Inline fallback & Output Hygiene*: Calibrate the depth internally to a 20-something SW/CS graduate (decode repo-specific domain jargon into standard CS mental models without childish analogies or architectural fluff), **never echo the internal persona label (`20s CS Grad` / `20대 SW 학과 졸업생...`) in the output heading or text**, and **localize the heading and all 4 bullet labels into the user's conversation language** (e.g., Korean: **핵심 요약**, **구조 및 동작 모델**, **동작 원리 및 트레이드오프**, **적용 효과 및 검증 기준**; English: **Core Essence**, **Mental Model**, **Mechanism & Trade-offs**, **Impact & Verification**).
   - If a new architectural decision was made during the loop and the workspace has not opted out of `DECISIONS.md`, propose recording `D-xxx` (or opting out) in your final handoff turn—never pause the loop mid-flight to ask.
