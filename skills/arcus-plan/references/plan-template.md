# ARCUS Plan Template

Use this structure when presenting an `arcus-plan` output:

## 1. Context & Root Cause / Core Seam
- **Observed Behavior / Requirement**: What needs to change and why.
- **Root Cause / Architectural Seam**: The exact file(s), function(s), and invariant(s) responsible (link to specific file paths and lines).

## 2. Blast Radius & Invariants
- **Files to Modify**: List of target files and the exact responsibility of each edit.
- **Invariants to Preserve**: Contracts, types, backwards compatibility, or performance constraints that must not break.

## 3. Step-by-Step Execution Plan
1. **[Step 1 Title]**: Concrete change description.
2. **[Step 2 Title]**: Concrete change description.
3. **[Step 3 Title]**: Concrete test additions or updates.

## 4. Verification Evidence Plan
- **Automated Checks**: Exact commands to execute (e.g., `npm test`, `pytest`, `cargo check`).
- **Edge Cases Covered**: Specific failure modes or boundary inputs that will be verified.
