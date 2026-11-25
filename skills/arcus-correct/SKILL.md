---
name: arcus-correct
description: >-
  Find repeated agent mistakes in this repo and make each one impossible via
  architecture, types, lints, or tests, while auditing and pruning dead,
  redundant, or brittle fact-claim rules. Use when the user invokes
  "arcus-correct", "/arcus-correct", "/correct", or corrects a repeated agent
  mistake.
---

# Correct & Rule Hygiene (`arcus-correct`)

The operator keeps correcting agents in this repo for the same mistakes—or the repo's agent rule files (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`) have accumulated dead, redundant, or rotting prose. Fix the repo so mistakes become structurally impossible, and prune rules that don't earn their tokens.

Assume every contributor is an agent that sees only the files it opened, copies the nearest example, and takes the shortest path that compiles. Design the repo so a change that looks right from one file is right for the whole repo.

## 1. Find the Mistake Classes

Read recent commits, reverts, review ledgers, agent instruction files (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`), and workaround comments. Group mistakes into classes. A class counts once it has happened twice (or immediately when the operator explicitly invokes `arcus-correct` on a mistake).

## 2. Fix Each Class at the Highest Level That Works

1. **Eliminate it with architecture.** Give each piece of state one owner and each task one supported way. Hide internals so the wrong import fails. Replace hand-synced lists with one source of truth. Delete old ways and dead code an agent would copy.
2. **Enforce it with types so the bad state can't be written.** If bad code still compiles, add a lint or CI check whose error message names the exact file, type, or function to use instead. If the legacy pattern is already common, fail only when a change adds more.
3. **Test the behavior.** Fix or delete any test that still passes when the behavior it checks breaks, or that fails when only internals change.
4. **Write docs or agent rules last, only for judgment calls.** Nothing fails when an agent skips prose.

Then fix the most frequent classes now, one commit each. Prove each new check fails on a real past mistake. Run the same command locally and in CI.

## 3. Audit & Prune Existing Rules (Rule Hygiene)

Every line in `AGENTS.md` spends context tokens on every turn. Audit existing rules and on-demand reference files against four signals:

| Signal | Diagnosis | Required Action |
| :--- | :--- | :--- |
| **1. Repeatedly Violated Rule** (`>= 2` violations in git history, review ledgers, or operator corrections) | Prose failed. Either the rule is unclear or the architecture invites the mistake. | **Escalate to Levels 1–3** (architecture, types, or a lint/script check that blocks the violation), then delete the prose rule once structurally enforced. |
| **2. Never-Read / Orphaned Rule** (an on-demand doc with zero inbound links/reads, or a rule pointing to deleted files/workflows) | Dead weight that no longer matches active workflows. | **Question its existence and delete it.** |
| **3. Never-Violated Rule (`0` violations / 100% obeyed)** | Either (a) already enforced by a compiler/linter/test, (b) standard knowledge already baked into base model weights, or (c) a non-obvious repo judgment call. | **Prune (a) and (b) immediately** as token-wasting redundancy. Keep *only* (c) genuine repo-specific judgment calls that no tool can check. |
| **4. Brittle Fact Claims** (statements like *"API X behaves like Y"* or *"Library Z returns null on error"*) | Library upgrades and code changes silently turn static fact claims into lies. | **Delete the fact claim from rules.** Replace with a pointer to the source-of-truth type definition, executable contract test, or official docs lookup. |

## 4. Keep the Rule Enforcement Table & `DECISIONS.md`

- In `AGENTS.md`, maintain a concise rule table that pairs each active rule with **what enforces it** (lint script, type, test, or judgment). Drop a prose rule once its mistake cannot happen.
- Record *why* an architectural boundary or rule graduation was chosen in [`DECISIONS.md`](../../DECISIONS.md) (if present in the repo) with a pinned commit SHA, keeping historical narrative out of always-on `AGENTS.md` files.

**Reply:** each mistake class or audited rule with its evidence, the enforcement level or pruning action you picked, and why a higher level didn't work.
