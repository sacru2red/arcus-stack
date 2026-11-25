---
name: arcus-why
description: >-
  Use for "why does X work this way", "why we picked Y", design rationale,
  regressions, postmortems, or data-backed thresholds. Returns a cited read on
  decisions and tradeoffs from commit and PR history. Use when the user invokes
  "arcus-why", "/arcus-why", or "/why".
---

# Why (`arcus-why`)

Answer from the record, not the code: read the commits (`git log -S` / `git log -L` / `git blame`) and PR discussions that introduced the target and each later change, and other sources if the trail is thin. Cite what the authors wrote, mark your own inferences as inferences, and say what the record does not answer. (For runtime behavior rather than historical rationale, see [../arcus-mode/internal/how.md](../arcus-mode/internal/how.md).)
