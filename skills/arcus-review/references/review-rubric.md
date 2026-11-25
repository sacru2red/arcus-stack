# ARCUS Plan & Code Review Rubric

Evaluate plans (`arcus-plan`) and code changes (`arcus-work-loop`) strictly against these five dimensions:

## 1. Premise & Root-Cause Validity (vs. Symptom Patching)
- **In a Plan**: Question the premise itself. Why was this approach chosen over simpler alternatives that the author discarded? Does the plan assume a file, tool, path, or invariant exists without verifying it in the repo?
- **In Code**: Red flags include adding `try/catch` that swallows errors, optional chaining (`?.`) without knowing why a value is `undefined`, or arbitrary retries/sleeps instead of enforcing invariants at the origin boundary.

## 2. Cold-Reader Comprehensibility (Design & Docs)
- Can an uninitiated engineer (or fresh agent session) understand the design from the document and code alone without sitting in the author's chat session?
- **Falsifiable Extraction Check**: State (1) the exact root cause/seam, (2) the state/module boundary changing, and (3) the failure mode if a step fails. Any gap that requires guessing unstated author intent fails this check.

## 3. External Reference Grounding & Failure Modes
- **Beyond the Repo**: Do not stay trapped inside the repository's existing habits. When touching external APIs, libraries, CLIs, or standards, verify against official external documentation or specifications.
- **Edge Cases & Dependencies**: Broken cross-references, partial-install failures, empty/boundary inputs, partial failures, race conditions, resource leaks, rollback behavior, and security boundaries.

## 4. Architectural Hygiene & Blast Radius
- Minimal surface area: no dead code, no duplicated instructions, no speculative abstractions, and no leaking internal details across module boundaries.

## 5. Verification Evidence Quality
- **In a Plan**: Every checklist item (`- [ ]`) must have a concrete `➔ Verify:` command or observable proof that would fail if the step were broken.
- **In Code**: Automated tests and typecheckers must cover both the happy path and the failure/edge case, and must have been actually executed.
