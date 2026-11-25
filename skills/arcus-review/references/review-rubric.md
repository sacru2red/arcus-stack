# ARCUS Code Review Rubric

Evaluate changes strictly against these four dimensions:

## 1. Symptom Patching vs. Root Cause
- **Red Flag**: Adding `try/catch` that swallows errors, optional chaining (`?.`) without understanding why a value is `undefined`, or arbitrary retries/sleeps.
- **Requirement**: The change must enforce the data or state invariant at the boundary where it originates.

## 2. Failure Modes & Edge Cases
- Empty/null/boundary inputs, partial failures, race conditions, resource leaks, and rollback behavior.
- Security boundaries: untrusted input validation, auth checks, and secret exposure.

## 3. Architectural Hygiene
- Minimal surface area: no dead code, no speculative abstractions, no leaking internal details across module boundaries.

## 4. Verification Evidence
- Are there automated tests covering both the happy path and the failure/edge case?
- Were the tests and typecheckers actually executed?
