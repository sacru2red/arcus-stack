# ARCUS Plan & Verification Checklist Template

Use this structure when presenting an `arcus-plan` output:

## 1. Context & Root Cause / Core Seam
- **Observed Behavior / Requirement**: What needs to change and why.
- **Root Cause / Architectural Seam**: The exact file(s), function(s), and invariant(s) responsible (link to specific file paths and lines).

## 2. Blast Radius & Invariants
- **Files to Modify**: List of target files and the exact responsibility of each edit.
- **Invariants to Preserve**: Contracts, types, backwards compatibility, or performance constraints that must not break.

## 3. Actionable Execution & Verification Checklist
Write each step as an unchecked box (`- [ ]`) that pairs the **concrete action** with its **observable verification proof**. During execution (`arcus-work`), items are marked `- [x]` only after their verification condition passes.

- [ ] **Step 1 — [Target File / Module]**: Concrete change description.
  - ➔ **Verify**: Exact check or command (e.g., `npm test -- path/to/test`, typecheck passes, or specific boundary behavior confirmed).
- [ ] **Step 2 — [Target File / Module]**: Concrete change description.
  - ➔ **Verify**: Exact check or command.
- [ ] **Step 3 — [Edge Cases & Regression Tests]**: Specific failure modes, empty/boundary inputs, or regression tests added/updated.
  - ➔ **Verify**: Test suite execution command and expected passing output.
