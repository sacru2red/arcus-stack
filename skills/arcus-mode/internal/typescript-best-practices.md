---
name: typescript-best-practices
description: "Internal sub-skill for TypeScript type inference, satisfaction checks, per-domain sentinel contracts, domain-driven naming, immutable-by-default state updates, and single-owner query or mutation modules."
---

# TypeScript, naming, and state discipline

Apply when planning, writing, or reviewing TypeScript code, domain models, or stateful modules.

## Naming
- **Verify domain meaning before naming.** Check domain models, schemas, and `ONBOARDING.md` (when present) rather than deriving file, type, or variable names from transient UI copy.
- **Follow active repository grammar, not legacy pockets.** Match the repository's active naming rules (linters, style docs, and recent modules). Do not copy outdated historical notation into new code or treat legacy naming as an untouchable preference when refactoring.

## TypeScript types
- **Infer locally and annotate boundaries.** Omit redundant local type annotations that the compiler infers naturally. Declare explicit type contracts at module boundaries such as exported signatures, component props, external payloads, and persisted schemas.
- **Prefer satisfaction checks over forced assertions.** When possible, use `satisfies`, type guards, and narrowing instead of forced overrides (`as T`, `as unknown as`, `!`). Narrowing with `as const` and unavoidable external or DOM attribute casts (such as newly shipped HTML attributes per [modern-web-guidance.md](./modern-web-guidance.md)) remain valid when narrowing cannot express the type.
- **Connect inference through generics.** Thread generic parameters through the enclosing call or container so callback parameters infer end-to-end instead of repeating annotations at each callback. Annotate callback parameters explicitly only when inference degrades to `any` or produces unreadable compiler errors.
- **Define empty and sentinel contracts per domain.** Never collapse absent, unset, and valid values into one sentinel or loose falsy check (`!v`, `v || fallback`). Define explicit contracts for `null`, `undefined`, `""`, and `0` per domain instead of assuming one global meaning (for example, a PATCH payload may treat `undefined` as omitted and `null` as cleared, while each numeric or form domain decides whether `0` or `""` is valid).

## State and data access
- **Update `const` state through immutable transforms by default.** Allow mutation only inside a local, non-escaping scope where it is provably safe.
- **Avoid mutable `Set` and `Map` as default state containers.** Prefer plain arrays and records for shared state, store defaults, serialized boundaries, and default parameters. Confine mutable `Set` and `Map` to local lookup scopes; if you expose `ReadonlySet` or `ReadonlyMap`, ensure no mutable backing reference escapes and replace the instance on state updates.
- **Give duplicate queries and mutations one owner.** Assign a single authoritative module or hook per resource query or mutation so request contracts, cache keys, invalidation, and error handling live in one place.
