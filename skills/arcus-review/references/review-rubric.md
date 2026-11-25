# ARCUS Plan & Code Review Rubric

Evaluate plans (`arcus-plan`) and code changes (`arcus-work-loop`) strictly against these four dimensions:

## 1. Premise & Root-Cause Validity (vs. Symptom Patching)
- **In a Plan**: Does the plan assume a file, tool, path, or invariant exists without verifying it? Does it address a surface symptom instead of the architectural seam?
- **In Code**: Red flags include adding `try/catch` that swallows errors, optional chaining (`?.`) without knowing why a value is `undefined`, or arbitrary retries/sleeps.

## 2. Failure Modes, Dependencies & Edge Cases
- **In a Plan**: Broken cross-references, missing migration/cleanup steps, partial-install failures, or state conflicts between planning and execution.
- **In Code**: Empty/null/boundary inputs, partial failures, race conditions, resource leaks, rollback behavior, and security boundaries (untrusted input, auth, secrets).

## 3. Architectural Hygiene & Blast Radius
- Minimal surface area: no dead code, no duplicated instructions, no speculative abstractions, and no leaking internal details across module boundaries.

## 4. Verification Evidence Quality
- **In a Plan**: Every checklist item (`- [ ]`) must have a concrete `➔ Verify:` command or observable proof, not vague "test it" placeholders.
- **In Code**: Automated tests and typecheckers must cover both the happy path and the failure/edge case, and must have been actually executed.
