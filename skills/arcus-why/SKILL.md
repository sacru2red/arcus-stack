---
name: arcus-why
description: >-
  Use for "why does X work this way", "why we picked Y", design rationale,
  regressions, postmortems, or data-backed thresholds. Returns a cited read on
  decisions and tradeoffs from DECISIONS.md, commit history, and PR discussions.
  Use when the user invokes "arcus-why", "/arcus-why", or "/why".
---

# Why (`arcus-why`)

Answer from the record, not by guessing from current code:

1. **Check `DECISIONS.md` (if present in the repo)**: Look for a recorded architectural decision (`D-xxx`) covering the target, and note its pinned commit SHA and status (`ACTIVE` vs. `SUPERSEDED`).
2. **Trace Git & PR History**: Read the commits (`git log -S` / `git log -L` / `git blame`) and PR discussions that introduced the target and every change *after* the pinned commit SHA to verify whether the original decision still holds in code.
3. **Cite & Separate Fact from Inference**: Cite what the authors wrote (commit SHAs, PR comments, `DECISIONS.md` IDs), explicitly mark your own inferences as inferences, and state what the record does not answer. (For runtime behavior rather than historical rationale, see [../arcus-mode/internal/how.md](../arcus-mode/internal/how.md).)
