# ARCUS Plan & Code Review Rubric

Evaluate plans (`arcus-plan`) and code changes (`arcus-work-loop`) strictly against these five dimensions:

## 1. Premise & Root-Cause Validity (vs. Symptom Patching)
- **In a Plan**: Question the premise itself. Why was this approach chosen over simpler alternatives that the author discarded? Does the plan assume a file, tool, path, or invariant exists without verifying it in the repo?
- **In Code**: Red flags include adding `try/catch` that swallows errors, optional chaining (`?.`) without knowing why a value is absent, forced type-safety bypasses (in TypeScript, `as T` or `as unknown as` where `satisfies` or narrowing works), collapsing absent, unset, empty, and zero values into one sentinel instead of enforcing per-domain contracts, or arbitrary retries/sleeps instead of enforcing invariants at the origin boundary.

## 2. Cold-Reader Comprehensibility (Design & Docs)
- Can an uninitiated engineer (or fresh agent session) understand the design from the document and code alone without sitting in the author's chat session?
- **Falsifiable Extraction Check**: State (1) the exact root cause/seam, (2) the state/module boundary changing, and (3) the failure mode if a step fails. Any gap that requires guessing unstated author intent fails this check.

## 3. External Reference Grounding & Failure Modes
- **Beyond the Repo**: Do not stay trapped inside the repository's existing habits. When touching external APIs, libraries, CLIs, or standards, verify against official external documentation or specifications.
- **Edge Cases & Dependencies**: Broken cross-references, partial-install failures, empty/boundary inputs, partial failures, race conditions, resource leaks, rollback behavior, and security boundaries. For live database schemas, persisted queues/caches, or rolling-deploy wire contracts, flag single-PR Expand+Contract, destructive or blocking DDL (`DROP`/`RENAME` column, rewriting `ALTER TYPE`, full-table `SET NOT NULL` without `NOT VALID` + `VALIDATE CONSTRAINT`, blocking index without `CONCURRENTLY`/online DDL), unbatched full-table updates, or `N-1`/`N` rolling-deploy incompatibility *(see [`safe-migration.md`](../../arcus-mode/playbooks/safe-migration.md) when co-installed)*.
- **Backend & Outbound Reliability**: Missing timeouts or cancellation on outbound HTTP/RPC/DB calls, unbounded or non-idempotent retries masking 4xx/logic bugs, missing rate limits or backpressure on public or expensive endpoints, and secrets or unredacted PII in logs *(see [`backend-reliability.md`](../../arcus-mode/internal/backend-reliability.md) when co-installed)*.

## 4. Architectural Hygiene & Blast Radius
- Minimal surface area: no dead code, no duplicated instructions, no speculative abstractions, and no leaking internal details across module boundaries.
- Domain naming & state ownership: identifiers reflect verified domain meaning rather than UI display copy (following active repo grammar rather than copying legacy pockets), shared state defaults avoid mutable containers, and duplicate data-fetching or mutation flows converge on one owning module. *(In TypeScript, check against [`typescript-best-practices.md`](../../arcus-mode/internal/typescript-best-practices.md) when co-installed: local inference vs. boundary contracts, generic inference over repeated callback types, immutable `const` transforms with safe local exceptions, and avoiding mutable `Set`/`Map` defaults.)*
- Data access & transaction boundaries: list queries enforce explicit pagination or row limits, N+1 loops are eliminated via batching or joins, hot/large-table filters have index or query-plan coverage, and DB transactions never stay open across external network, LLM, payment, or queue I/O *(use idempotency keys across boundaries; see [`backend-reliability.md`](../../arcus-mode/internal/backend-reliability.md) when co-installed)*.

## 5. Verification Evidence Quality
- **In a Plan**: Every checklist item (`- [ ]`) must have a concrete `➔ Verify:` command or observable proof that would fail if the step were broken.
- **In Code**: Automated tests and typecheckers must cover both the happy path and the failure/edge case, and must have been actually executed.
- **In Visual UI PRs/MRs**: For PRs or MRs touching visual UI files, verify that `## Visual Changes` includes Before/After evidence captured after final polish at matching route, viewport, scroll position, and light or dark theme, with zero broken local paths in remote PR descriptions and zero accidental `.audit/` binary PNG commits.
