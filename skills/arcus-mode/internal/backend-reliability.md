---
name: backend-reliability
description: "Internal sub-skill for bounded database queries, short transaction boundaries, outbound timeouts and cancellation, transient-only retries, backpressure, and redacted structured logging."
---

# Backend, data access, and reliability discipline

Apply when planning, writing, or reviewing backend services, database queries, transaction flows, or outbound HTTP and RPC calls.

## Queries and data access
- **Bound every list query.** Require explicit pagination or row limits on list queries. Never issue unbounded full-table reads in request handlers or batch jobs.
- **Eliminate N+1 queries inside loops.** Replace per-item database reads inside loops with batched queries or joins.
- **Inspect query plans and indexes for hot filters.** Check query plans or index coverage for filters, sorts, and joins on hot or large tables before shipping.

## Transaction boundaries
- **Keep external I/O outside database transactions.** Never hold a database transaction open across external network, LLM, payment, or queue I/O. Open transactions during remote waits exhaust connection pools and increase lock contention.
- **Pair cross-boundary writes with idempotency keys.** For state-changing operations that cross service or database boundaries, pass explicit idempotency keys and follow [principle-make-operations-idempotent.md](../principles/principle-make-operations-idempotent.md) so retries converge to one outcome.

## Outbound resilience and backpressure
- **Set explicit timeouts and propagate cancellation.** Configure explicit timeouts on every outbound HTTP, RPC, or database call, and forward caller cancellation signals downstream.
- **Retry only transient faults on idempotent operations.** Allow bounded, jittered exponential backoff only for transient transport faults or HTTP 429 and 503 responses on idempotent calls. Never mask logic errors or 4xx bugs with arbitrary retries, which violates root-cause discipline in `rules/AGENTS.md`.
- **Enforce rate limits and bounded concurrency.** Protect public or expensive endpoints with rate limits, queue bounds, or concurrency caps to prevent downstream overload.

## Observability and log hygiene
- **Emit structured logs with correlation IDs.** Attach a request or correlation ID to structured log records and propagate it across service hops so failures trace across services.
- **Never log secrets or unredacted PII.** Strip or redact secrets, bearer tokens, passwords, and personal data before serializing logs or reporting errors.
