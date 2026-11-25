# ARCUS Review Ledger & Blind Re-Evaluation Protocol

To prevent findings from being lost across review rounds—and to prevent reviewers from being swayed by an author's excuses before checking the actual code—every `arcus-review` maintains a **Review Ledger**.

---

## 1. Snapshot Pinning (Before Reading or Reviewing)

Every review round must pin the exact snapshot it evaluated so later rounds can verify what changed:
- **Committed / PR Review**: Pin `base_sha..head_sha` (`git rev-parse HEAD`).
- **Uncommitted Working-Tree Review**: Pin `HEAD` SHA plus the diff content hash (`git diff HEAD | git hash-object --stdin`), and freeze working-tree edits while the review runs.
- **Plan / Design Review (Mode A)**: Pin the repository `HEAD` SHA plus the plan file path (or verbatim block hash).

---

## 2. Structural Separation: Findings Table vs. Author Replies

**Never mix author replies into the Findings Table.** On Round 2+, the reviewer must read the open findings and evaluate the new code snapshot **before** reading the author's replies or commit messages. Keeping them in separate sections makes blind code-first verification physically enforceable.

### Section A: Findings Ledger Table (Read FIRST on Round 2+)

| ID | Round | Pinned Snapshot | Severity | Target (`File:Line` or Plan Section) | Concrete Failure Scenario & Required Fix | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `F-01` | R1 | `9cca575` | `CRITICAL` | `skills/arcus-review/SKILL.md:10` | Same-session review inherits author bias. Require isolated subagent delegation. | `OPEN` |
| `F-02` | R1 | `9cca575` | `HIGH` | `scripts/install-global.ps1:27` | Renamed skills leave dangling links on update. Prune stale `arcus-*` entries. | `RESOLVED` |

Allowed `Status` values:
- `OPEN`: Newly filed or not yet resolved.
- `RESOLVED`: Verified fixed directly in the latest code/plan snapshot.
- `UNRESOLVED`: Still broken or only partially patched in the latest code/plan snapshot.
- `VALID_PUSHBACK`: The code did not change, and independent verification confirms the author's counter-argument/invariant holds.
- `DISPUTED`: Reviewer and author disagree after checking both code and rationale; escalate to the operator with both sides stated plainly.

### Section B: Author Replies & Resolution Log (Read ONLY in Phase 2 of Round 2+)

Authors (or fixing agents) append their notes here by finding ID, never inside Section A:
- `F-01`: Added isolated subagent delegation protocol in commit `<sha>`.
- `F-02`: Why we didn't change X: handled upstream by boundary check in `foo.ts:42`.

---

## 3. Round 2+ Blind Verification Procedure (Code Before Replies)

When running a follow-up review round (Round 2, Round 3, ...), follow this strict two-phase order:

1. **Phase 1 — Code-Only Verdict (Blind to Author Replies)**:
   - Read **Section A (Findings Ledger Table)** to get all non-`RESOLVED` items (`OPEN`, `UNRESOLVED`, `DISPUTED`).
   - Do **not** read Section B, PR comment replies, or commit message explanations yet.
   - Inspect the newly pinned code/plan snapshot directly at each target location and form your preliminary verdict (`RESOLVED` or `UNRESOLVED`) purely from what the code/doc actually does.
2. **Phase 2 — Reconcile with Author Replies & Scan New Changes**:
   - Only after recording your code-first preliminary verdict, read **Section B (Author Replies)** or PR thread replies for any item that appeared `UNRESOLVED`.
   - Verify any counter-claim against the real codebase and external references, updating the status to `RESOLVED`, `UNRESOLVED`, `VALID_PUSHBACK`, or `DISPUTED`.
   - Finally, review new diffs introduced since the previous pinned snapshot and append any new issues (`F-03`, `F-04`, ...) to the ledger.
