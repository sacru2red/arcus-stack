---
name: checklist
description: "Internal sub-skill for building and maintaining a goal-aligned execution and verification checklist during planning or multi-step work."
---

# Goal-Aligned Execution & Verification Checklist

Use this internal protocol whenever planning ([`arcus-plan`](../../arcus-plan/SKILL.md) *(when co-installed)*) or driving multi-step work (`arcus-mode` / [`arcus-work-loop`](../../arcus-work-loop/SKILL.md) and [`work-loop-checklist.md`](../../arcus-work-loop/references/work-loop-checklist.md) *(when co-installed)*) so no requirement, edge case, or verification step slips through the cracks.

## 1. Shape of a Valid Checklist Item

Never write vague todo items (`- [ ] fix auth bug`, `- [ ] add tests`). Every item must name the **target seam**, the **behavior change**, and the **observable proof** (either as a two-line indented sub-bullet or a single-line inline `➔ Verify:` clause):

```markdown
- [ ] **[File / Module]**: <What changes and why>
  - ➔ **Verify**: <Exact command, test, or observable output that proves it works>
```

## 2. Live Maintenance Loop

1. **Seed from the Goal**: Break the user's goal into small, sequentially verifiable units (typically 3–7 items). Include edge-case and regression checks explicitly.
2. **Update on Discovery**: If reading or editing code exposes a new dependency, caller, or failure mode, insert a new `- [ ]` item into the checklist before proceeding.
3. **Check Off with Evidence**: Flip `- [ ]` to `- [x]` only after executing the `Verify` step and confirming the result. Annotate the checked item with the brief outcome (e.g., `➔ Verified: 12 tests pass`).
