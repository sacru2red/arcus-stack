---
name: principle-minimize-reader-load
description: "Apply when reviewing or shaping code that's hard to trace. Count layers between question and answer, and hidden state in the reader's head; collapse one-caller wrappers and shrink mutable scope."
---

# Minimize Reader Load

Reader load is the work a reader must do to understand code. It has two independent axes: layers to trace between the question and the answer, and hidden or mutable state to hold in their head. Guard both.

- Collapse layers that only forward: wrappers with one caller, adapters with no second implementation, pass-through methods. Inline them.
- Shrink state scope: prefer immutable updates over shared mutation (allowing only bounded local mutation), avoid mutable container defaults in shared state, and use returns over mutations, locals over fields, fields over module state, and module state over globals. Derive instead of sync.
- Give each shared query or state-mutation flow one owning module instead of duplicating calls across consumers. (For TypeScript specifics, see [typescript-best-practices.md](../internal/typescript-best-practices.md).)
- Name an invariant once at the boundary, not in every consumer.

The test: can a new reader answer "where does X come from?" and "what can change X?" in under 30 seconds? If not, cut layers or cut state.
