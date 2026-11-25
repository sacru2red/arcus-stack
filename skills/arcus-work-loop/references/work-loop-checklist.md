# ARCUS Work Loop Completion Rubric & Checklist Resolution Protocol

> **CRITICAL ROLE DISTINCTION (Do Not Confuse This File with the User's Task Checklist)**:
> - **This file (`work-loop-checklist.md`)** is the **skill's internal quality & sign-off rubric**.
> - The **User's Task Checklist** (the specific `- [ ] Step 1..N` implementation items for the current feature/bug) does **not** live inside this skill folder.
> - **Zero-Bailout Invariant**: Never terminate `arcus-work-loop` early because a checklist `.md` file was not found on disk. Always resolve or self-seed the task checklist via the 4-Tier Resolution Order in Section 1 below.

---

## 1. 4-Tier Task Checklist Resolution & Live Tracking Rules

Before writing code, locate—or create—the active **Task Checklist** in this exact order:

1. **Tier 1 — User Prompt / Named File**: Check if the user passed `- [ ]` items inline or named a specific file path (e.g., `docs/plan.md`, `TODO.md`).
2. **Tier 2 — Conversation History (`arcus-plan` / `arcus-review` output)**: Scan earlier turns in the chat transcript for the most recent `Actionable Execution & Verification Checklist` (such as Plan v2 after `arcus-review`) and adopt its `- [ ]` items.
3. **Tier 3 — Workspace Plan Artifacts**: If running in a fresh thread or after context compaction with no chat checklist, check for a matching workspace plan file (`PLAN.md`, `TODO.md`, `TASKS.md`, or `.audit/*.md`).
4. **Tier 4 — Mandatory Self-Seed (Fallback When No Checklist Exists Anywhere)**:
   - If Tiers 1–3 find no checklist, **do not exit the loop and do not ask the user where the checklist document is**.
   - Inspect the target files in the repository, generate a 3–7 item task checklist right now (pairing each concrete edit with `➔ Verify: <command>`), register the steps in your session's step tracker (`update_steps` / `TodoWrite` if available), and execute them immediately.

### Live Maintenance Rules (During Execution)
- **Action + Proof Pairing**: Every task item must follow `- [ ] [Target File/Module] Change ➔ Verify: [Command / Expected Output]`.
- **Dynamic Upkeep**: When an edit reveals a new caller, migration step, or edge case, add a new `- [ ]` line immediately rather than keeping it only in memory.
- **Evidence-Gated Checkoff**: Never mark `- [x]` based on "I wrote the code". Mark `- [x]` only after running the verification command and observing the passing result.

---

## 2. Final Sign-Off Gate (Audit Against This Rubric Before Declaring Done)
Verify every quality gate below before handing the turn back to the user:

- [ ] **All Task Checklist Items Checked (`[x]`)**: Every planned and discovered item has been executed and verified.
- [ ] **Root-Cause Resolution**: Does the change solve the actual root cause rather than masking a symptom?
- [ ] **No Leftover Artifacts**: Are all `TODO` stubs, debug logs (`console.log`, `print`), unused imports, and temporary files removed?
- [ ] **Minimal Diff**: Does `git diff` contain only intentional changes directly required for the task?
- [ ] **Real Verification Evidence**:
  - [ ] Typecheck / compilation passes with zero new errors.
  - [ ] Existing tests pass.
  - [ ] New or updated tests cover the changed behavior and edge cases.
- [ ] **End-of-Loop `arcus-explain` Briefing (Localized & Persona-Label-Free)**:
  - [ ] Immediately after the `- [x]` checklist and verification evidence (and before any optional `DECISIONS.md` authorization prompt), summarize the completed work in 4 concise points using **only the single label matching the user's conversation language** (e.g., in English: **Core Essence**, **Mental Model**, **Mechanism & Trade-offs**, **Impact & Verification**; in Korean: **핵심 요약**, **구조 및 동작 모델**, **동작 원리 및 트레이드오프**, **적용 효과 및 검증 기준**—never slash-combined bilingual labels) per [`arcus-explain`](../../arcus-explain/SKILL.md) (when co-installed), calibrating depth internally without ever echoing the persona name (`20s CS Grad` / `20대 SW 학과 졸업생...`) in the output.
