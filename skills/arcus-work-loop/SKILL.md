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

1. **Resolve or Self-Seed the Task Checklist (4-Tier Discovery — Never Abort If Missing)**:
   - **Domain Grounding First**: If `ONBOARDING.md` (or `CONTEXT.md`) exists in the workspace, consult it first so your implementation respects domain-to-code mappings, business invariants, authz tiers, and legacy red-line minefields (verifying cited code paths against live code).
   - **Role Boundary Note**: [`./references/work-loop-checklist.md`](./references/work-loop-checklist.md) is this skill's **meta sign-off rubric**, NOT the user's project task file. Never abort or exit the loop claiming you "could not find the checklist document on disk."
   - Resolve the active **Task Checklist** using this strict 4-tier priority order:
     1. **Tier 1 (Explicit Path or Inline Prompt)**: If the user's message names a plan/checklist file path or includes `- [ ]` items directly, load those items.
     2. **Tier 2 (In-Conversation `arcus-plan` Output)**: Scan earlier messages in the current conversation (including `## 3. Actionable Execution & Verification Checklist` or `arcus-review` Plan v2 checklists) and adopt all unchecked `- [ ]` items.
     3. **Tier 3 (Workspace Plan / Task Files)**: If the conversation has no prior checklist (e.g., fresh thread or post-handoff), check the workspace for an active plan document (`PLAN.md`, `TODO.md`, `TASKS.md`, or `.audit/*.md`) that matches the current task goal.
     4. **Tier 4 (Mandatory Self-Seeding Fallback — Never Bail Out)**: If Tiers 1–3 yield no checklist, **never stop, complain, or ask where the checklist is**. Perform a fast parallel discovery of the relevant codebase files/tests, construct a concrete 3–7 step `- [ ]` execution & verification checklist yourself in your working state (and native step tracker tool such as `update_steps` / `TodoWrite` when available), and immediately proceed to Step 2.
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
