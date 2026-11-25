# ARCUS Ultrawork Completion Checklist

Before declaring an `arcus-work` task complete, verify every item below:

- [ ] **Root-Cause Resolution**: Does the change solve the actual root cause rather than masking a symptom?
- [ ] **No Leftover Artifacts**: Are all `TODO` stubs, debug logs (`console.log`, `print`), unused imports, and temporary files removed?
- [ ] **Minimal Diff**: Does `git diff` contain only intentional changes directly required for the task?
- [ ] **Real Verification Evidence**:
  - [ ] Typecheck / compilation passes with zero new errors.
  - [ ] Existing tests pass.
  - [ ] New or updated tests cover the changed behavior and edge cases.
