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
