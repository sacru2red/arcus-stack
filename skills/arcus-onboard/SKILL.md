---
name: arcus-onboard
description: >-
  Build and maintain a 1-2 page Engineering & Domain Brain (ONBOARDING.md)
  capturing the 7 non-guessable domain and codebase facts a new engineer or
  coding agent needs in week one (system boundaries, domain term to code/DB
  mappings, core business formulas & invariants, authz & plan/tier gating,
  legacy minefields & red lines, systems of record, and error/UX/PR conventions)
  with date and provenance tags. Use when the user invokes "arcus-onboard",
  "/arcus-onboard", "onboard", or asks to build or update a project domain or
  minefield onboarding doc.
---

# Engineering & Domain Brain Onboarding (`arcus-onboard`)

Capture the implicit domain rules, identifier mappings, business formulas, authz boundaries, systems of record, and legacy code minefields scattered across people's heads and old threads into a concise **1–2 page `ONBOARDING.md`** that both engineers and AI agents consult before planning or modifying code.

## 1. Execution Context & Security Guardrails

- **Top-Level Interactive Turn Only**: Subagents (`worker.md`) and mid-flight autonomous loops (`arcus-work-loop`) must never block to run interviews and must never silently alter formulas, thresholds, or red-line minefields in `ONBOARDING.md` without explicit user confirmation in a top-level turn.
- **No Secret Scraping**: During repository mining, inspect only template/schema files (`.env.example`, `.env.sample`, `.env.template`, DB schemas, public docs). **Never** read live `.env*` files or copy API keys, tokens, credentials, or PII into `ONBOARDING.md`.
- **Non-Clobber & Domain Preservation Pre-Check**: `ONBOARDING.md` is the default target path. If `ONBOARDING.md` already exists and contains developer environment setup instructions (e.g., local build/Docker steps) or existing domain notes/older templates, preserve all user-confirmed facts and ask the user whether to merge the 7-section Domain Brain into `ONBOARDING.md` or write to `CONTEXT.md` instead of overwriting.
- **Code-vs-Domain Reconciliation (`D-005` / `D-008`)**: Code-anchored entries (Sections 2, 4, 5) cite `Source: <file/schema path>`. When reading `ONBOARDING.md`, always cross-check cited paths and symbols against live code. If live code was refactored or a migration completed, trust live code for structure and propose a Mode 2 update for the stale `ONBOARDING.md` entry.

## 2. Mode 1 — Bootstrap the Engineering & Domain Brain (`ONBOARDING.md`)

1. **Phase 1 — Bounded High-Signal Repo Mining**:
   - Exclude build, vendor, and cache trees (`node_modules`, `dist`, `build`, `.next`, `vendor`, lockfiles).
   - Scan high-signal architectural seams: `README*`, DB schemas/migrations (Prisma/SQL/ORM models), auth/RBAC middleware, API routers, error handlers, `.env.example` templates, and explicit `@deprecated` / `WARNING` / `DO NOT TOUCH` markers.
   - Pre-fill a draft of the 7 sections in [domain-brain-template.md](./references/domain-brain-template.md) with facts verified from code, and mark candidate minefields, unconfirmed term mappings, and unguessable business rules as `[TBD — needs user confirmation]`. Never promote routine `// TODO` comments into hard "Never Modify" red lines without user confirmation.
2. **Phase 2 — Targeted Interview (Only What Cannot Be Inferred)**:
   - Present the pre-filled findings briefly and interview the user **only** on the `[TBD]` items that cannot be proven from code alone (e.g., authoritative system of record, exact settlement/rounding formula, confirmed legacy minefields).
   - Use your environment's structured question tool (`ask_question` / `AskQuestion`) or fall back to a concise batched numbered chat prompt (at most 1–2 rounds, 4–6 questions per round; never dump 20 questions at once).
   - For OSS libraries, CLI tools, or microservices where commercial sections (e.g., billing formulas or plan tiers) do not apply, confirm with the user and collapse those sections to a single `N/A` line.
3. **Phase 3 — Stamp Provenance & Date Tags (`[as of YYYY-MM-DD | Source: ...]`)**:
   - Every code mapping, business formula, tier threshold, red-line minefield, and system-of-record entry **must** carry the canonical freshness tag:
     `[as of YYYY-MM-DD | Source: <File/Schema/System/Owner>]`
   - Write the completed 1–2 page document (target 80–120 lines) following [domain-brain-template.md](./references/domain-brain-template.md).

## 3. Mode 2 — Living Update (Reflecting Day-to-Day Evolutions)

When a schema migration completes, a legacy minefield is retired, a business formula or tier threshold changes, or the user corrects a domain term mapping:
1. Locate the affected section in `ONBOARDING.md` (or `CONTEXT.md`).
2. Confirm the updated mapping, invariant, or red-line boundary with the user in the top-level turn.
3. Update the entry in place and refresh its `[as of YYYY-MM-DD | Source: <File/System/Owner>]` tag so readers know the entry is current.
