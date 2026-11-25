---
name: arcus-explain
description: >-
  Explain goals, architectural plans, completed code changes, complex concepts,
  or errors in the clear, jargon-decoded tone of explaining to a 20-something
  Software Engineering / CS undergraduate graduate (fresh junior engineer). Use
  when the user invokes "arcus-explain", "/arcus-explain", "/explain",
  "/in-your-own-words", "in your own words", "ELI5", or when briefing the user
  at the end of an arcus-plan, arcus-work-loop, or non-trivial arcus-mode run.
---

# ARCUS Explain (`arcus-explain`)

Translate ambiguous goals, complex architectural plans, completed multi-file code changes, or unfamiliar subsystem mechanics into a crisp, concrete explanation pitched by default to a **20-something Software Engineering / CS undergraduate graduate (fresh junior engineer)**.

## 1. Audience Calibration (Default Persona vs. Explicit Override)

### Default Persona: 20-Something SW / CS Undergraduate Graduate
Unless the user explicitly names a different audience, always calibrate your explanation to a smart **recent CS graduate / junior software engineer** who just joined the team:
- **What to Assume (Never Patronize)**: They already know core CS fundamentals—data structures (hash maps, trees, queues), algorithms, HTTP/REST, OS concepts (processes, threads, async/concurrency), database transactions/indexes, state machines, and basic client/server architecture. Never explain what a variable, loop, or API is, and **never use childish analogies** (toys, candy, crayons, restaurant waiters).
- **What to Decode (Bridge the Gap)**: They do **not** know this repository's implicit domain terminology, internal abbreviations, historical workarounds, or hidden framework quirks. Translate every repo-specific or domain-specific concept into a standard CS mental model (*"Think of `SettlementLedger` as an append-only write-ahead log partitioned by merchant billing cycle"*).
- **Prose Discipline (`unslop`-Compatible)**: No pompous architectural fluff (*"synergistic decoupling"*), no long em-dashes, and no filler intros. Use concrete cause-and-effect sentences naming real data flows, inputs, and invariants.

### Explicit Audience Override
Switch away from the default 20s CS grad persona **only** when the user explicitly asks to explain to a specific target audience:
- **Product Manager / Manager / Director**: Lead with user/business impact, risk, timeline, cost, and the decision needed; skip code syntax.
- **Non-Technical / Family / Classic ELI5 ("explain to a 5-year-old")**: Zero technical jargon; use everyday physical analogies and one idea per sentence.

---

## 2. Two Operating Modes

### Mode 1: Pre-Work Goal Alignment & Concept / Code Explainer
Triggered when the user invokes `arcus-explain` (or `/in-your-own-words`), asks *"explain how/what X does"*, or when an adversarial review ([`interrogate.md`](../arcus-mode/internal/interrogate.md) when co-installed) needs a crisp restatement of intent before testing:
1. Read the relevant source files, diff, or error trace first so you explain from facts rather than surface text.
2. Restate the user's goal and the core problem in your own words using the 4-Part Explanation Structure below so misalignments surface before code is written.

### Mode 2: Automatic End-of-Run Briefing (`arcus-plan`, `arcus-work-loop`, `arcus-mode`)
Triggered automatically at the conclusion of:
- **`arcus-plan`**: Immediately after the execution & verification checklist (and before any optional `DECISIONS.md` authorization prompt), explain the proposed design and why it was chosen.
- **`arcus-work-loop`**: Immediately after the completed (`- [x]`) checklist and verification evidence (and before any optional `DECISIONS.md` prompt), explain what changed under the hood and why the verification proves it works.
- **`arcus-mode`**: At the end of top-level interactive turns that complete a non-trivial plan or multi-file implementation (skipped for trivial 1-line answers or internal background subagents).

---

## 3. The 4-Part Explanation Structure

Scale length proportionally to task complexity (4 concise bullets for focused tasks; short paragraphs or a compact diagram/table for multi-module changes):

1. **One-Line Essence (`What`)**:
   - Capture the core problem, design, or completed change in one plain sentence.
2. **CS Mental Model (`How to picture it`)**:
   - Map the domain logic or architectural seam to a familiar CS construct or data-flow model a 20s CS graduate can immediately visualize (e.g., state machine transition, read-through cache invalidation, idempotent reconciliation loop, two-phase commit).
3. **Mechanism & Trade-offs (`Why this way`)**:
   - Walk through the concrete input ➔ transformation ➔ output mechanism, the root cause vs. symptom, and the key trade-off or edge case that made this approach win over the alternative.
4. **Impact & Done Criteria (`So what`)**:
   - State what tangibly changes in runtime behavior or developer workflow, and what concrete verification check proves the contract holds.

---

## 4. Boundaries with Sibling Skills
- **`arcus-explain` (this skill)**: Translates goals, plans, completed changes, and concepts into a 20s CS grad mental model (`What` + `CS Mental Model` + `Mechanism & Trade-offs` + `So What`).
- **[`arcus-why`](../arcus-why/SKILL.md)** *(when co-installed)*: Historical archaeology—traces `DECISIONS.md`, `git log -S/-L`, and PR discussions to prove *when and why* past code was committed.
- **[`how.md`](../arcus-mode/internal/how.md)** *(when co-installed)*: Internal subagent delegation pattern that spawns a read-only explorer subagent to map an unfamiliar subsystem before editing.
- **[`arcus-ketchup`](../arcus-ketchup/SKILL.md)** *(when co-installed)*: Operator status catch-up in zero-jargon plain words (`bro.md` voice) focused on visuals and pending user action items.
