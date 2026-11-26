---
name: principle-migrate-callers-then-delete-legacy-apis
description: "Apply when introducing a new internal API while old callers still exist. Migrate callers and delete the old API in the same wave instead of preserving compatibility layers."
---

# Migrate Callers Then Delete Legacy APIs

- Update tests to assert the new contract, and delete tests that only protect pre-refactor implementation details

**When this applies:**
- No external users depend on backward compatibility
- The project can absorb coordinated breaking changes
- The new API is part of a simplification or refactor initiative

**When this does not apply:**
- Live database schemas, persisted queues or caches, and rolling-deploy or external wire contracts must not use single-wave cutover. Route those changes to [../playbooks/safe-migration.md](../playbooks/safe-migration.md) and execute Expand-Contract across separate PRs.
