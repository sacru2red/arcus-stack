# ARCUS Work Loop Completion & Live Checklist Protocol

## 1. Live Task Checklist Rules (During Execution)
- **Action + Proof Pairing**: Every task item must follow `- [ ] [Target] Change ➔ Verify: [Command / Expected Output]`.
- **Dynamic Upkeep**: When an edit reveals a new caller, migration step, or edge case, add a new `- [ ]` line immediately rather than keeping it only in memory.
- **Evidence-Gated Checkoff**: Never mark `- [x]` based on "I wrote the code". Mark `- [x]` only after running the verification command and observing the passing result.

## 2. Final Sign-Off Gate (Before Declaring Done)
Verify every item below before handing the turn back to the user:

- [ ] **All Task Checklist Items Checked (`[x]`)**: Every planned and discovered item has been executed and verified.
- [ ] **Root-Cause Resolution**: Does the change solve the actual root cause rather than masking a symptom?
- [ ] **No Leftover Artifacts**: Are all `TODO` stubs, debug logs (`console.log`, `print`), unused imports, and temporary files removed?
- [ ] **Minimal Diff**: Does `git diff` contain only intentional changes directly required for the task?
- [ ] **Real Verification Evidence**:
  - [ ] Typecheck / compilation passes with zero new errors.
  - [ ] Existing tests pass.
  - [ ] New or updated tests cover the changed behavior and edge cases.
- [ ] **End-of-Loop `arcus-explain` Briefing (Localized & Persona-Label-Free)**:
  - [ ] Immediately after the `- [x]` checklist and verification evidence (and before any optional `DECISIONS.md` authorization prompt), summarize the completed work in 4 concise points (**Core Essence / 핵심 요약**, **Mental Model / 구조 및 동작 모델**, **Mechanism & Trade-offs / 동작 원리 및 트레이드오프**, **Impact & Verification / 적용 효과 및 검증 기준**) localized into the user's conversation language per [`arcus-explain`](../../arcus-explain/SKILL.md) (when co-installed), calibrating depth internally without ever echoing the persona name (`20s CS Grad` / `20대 SW 학과 졸업생...`) in the output.
