---
name: arcus-ui-propose
description: >-
  Visual UI proposal and option comparison skill. Captures 1 baseline ("Before")
  screenshot and 3 distinct proposed variant screenshots (Option A, B, C) by
  sequentially applying, capturing, and reverting on the working branch before
  waiting for user selection. Use when the user invokes "arcus-ui-propose",
  "/arcus-ui-propose", "ui-propose", or asks for visual UI work, layout changes,
  styling updates, or component redesigns.
---

# ARCUS Visual UI Proposal & 4-Screenshot Comparison (`arcus-ui-propose`)

> *"Never ship a visual UI decision blind—capture the baseline, show 3 real rendered options, revert cleanly, and apply only what the user picks."*

When performing visual UI work (creating or modifying layouts, components, styling, themes, density, or interaction states), do not lock in a single unreviewed implementation. Capture **1 Baseline ("Before") screenshot** and **3 Proposed Variant ("Option A / B / C") screenshots** directly on the working branch, restore the working tree to its exact pre-proposal state, and present all 4 screenshots side-by-side for the user's decision.

## 1. Scope Gate (When to Trigger vs. Skip)

- **Trigger for**: Any visual UI addition, redesign, layout adjustment, styling/theme update, typography/spacing tweak, or new interactive component state where visual hierarchy, density, or look-and-feel matters.
- **Skip for**: Purely non-visual frontend edits (e.g., invisible `aria-*` bug fixes, analytics event wiring, state/type refactoring with zero visual diff) or when the user explicitly provides a pixel-locked spec and says *"skip options, implement this exact spec"*.
- **Subagent Guard**: Never block inside a background [`worker.md`](../arcus-mode/worker.md) subagent to ask a question; if delegated as a subagent, generate the 4 screenshots + saved patch diffs and return them to the top-level interactive turn for user selection.

## 2. Step-by-Step Sequential Capture & Revert Workflow

Follow the full protocol and presentation layout in [ui-proposal-protocol.md](./references/ui-proposal-protocol.md).

### Step 1 — Pre-Flight Working Tree Guard & Web Standards Lookup
1. **Protect Existing Uncommitted Edits**: Run `git status --porcelain`. If the user already has uncommitted changes in the working tree, record a non-destructive baseline snapshot (`$BASE_PATCH = ".audit/ui-propose/<task-slug>/00-base-dirty.patch"` via `git diff HEAD > $BASE_PATCH`, plus copying any pre-existing untracked files in target directories) so restoring after Option C never wipes the user's pre-existing dirty edits.
2. **Modern Web Standards First**: For HTML, CSS, or client-side JS/DOM UI, query live web platform guidance via `npx -y modern-web-guidance@latest search "<2-5 word query>"` and `retrieve "<id>"` (falling back to `npx --offline -y` or skipping non-blockingly if offline) so all 3 variants use modern Baseline features and clean `@supports` fallbacks.
3. **Prepare Artifact Directory**: Create `.audit/ui-propose/<task-slug>/` (keep out of git commits) to store the 4 screenshots (`00-before.png`, `01-option-a.png`, `02-option-b.png`, `03-option-c.png`), the 3 reusable patch files (`option-a.patch`, `option-b.patch`, `option-c.patch`), and any untracked variant file folders (`files-a/`, `files-b/`, `files-c/`).

### Step 2 — Capture 1 Baseline ("Before") Screenshot (`00-before.png`)
1. Ensure the target UI surface is running (reuse an active dev server / preview tab, or start the project's dev command / verification harness from `.agents/skills/verify-<app>/` if present).
2. Navigate to the exact route, viewport size, and UI state being modified. Lock the viewport dimensions and theme (`light`/`dark`) so all 4 screenshots share an identical frame.
3. Capture the current state to `.audit/ui-propose/<task-slug>/00-before.png` using the available capture surface (see [ui-proposal-protocol.md](./references/ui-proposal-protocol.md#capture-surface-fallback-chain): T3 Code `preview_snapshot(save=true)` / `device_screenshot`, project Playwright/browser harness, or standalone component preview).
   - *Brand-New Screen / Component*: If the route or component does not exist yet, capture the parent container or mount point before insertion as `00-before.png`.

### Step 3 — Sequentially Apply, Capture, and Revert 3 Distinct Variants (`A` ➔ `B` ➔ `C`)
Design 3 genuinely distinct visual/UX directions—never 3 trivial color tweaks:
- **Option A (Minimal / Conservative)**: Smallest blast radius, closest to existing patterns and layout density.
- **Option B (Balanced / Recommended Modern)**: Best UX ergonomics, visual hierarchy, and modern web platform idioms (e.g., native `<dialog>`/`popover`, container queries, clean spacing rhythm).
- **Option C (Bold / Alternative Layout or Density)**: Distinct spatial arrangement, compact vs. spacious density shift, or alternative interaction framing.

For each variant `X` in `a`, `b`, `c`:
1. **Apply Variant `X`** directly in the working branch source files.
2. **Wait for Hot-Reload / Render & Capture**: Verify the render has settled (no build error overlay or loading skeleton) at the locked viewport and save `.audit/ui-propose/<task-slug>/0N-option-X.png`.
3. **Save Exact Patch & Untracked Files for Instant Re-Application**: Export the tracked diff relative to `HEAD` (`git diff HEAD -- <touched-files> > .audit/ui-propose/<task-slug>/option-X.patch`) and copy any newly created untracked variant files (preserving relative paths) into `.audit/ui-propose/<task-slug>/files-X/`.
4. **Revert Working Tree to Pre-Proposal Baseline**: Restore modified tracked files against `HEAD` (`git checkout HEAD -- <touched-files>` and re-apply `$BASE_PATCH` via `git apply .audit/ui-propose/<task-slug>/00-base-dirty.patch` if the tree was initially dirty) and remove any untracked files created by Variant `X` before starting the next variant.

### Step 4 — Verify Clean Working Tree & Present the 4-Screenshot Proposal
1. After Option C is captured and reverted, verify `git status --porcelain` matches the exact pre-proposal state from Step 1.
2. Present the **4-Screenshot Visual Proposal Matrix** (embedding `00-before.png`, `01-option-a.png`, `02-option-b.png`, `03-option-c.png` with absolute paths or markdown image links, trade-offs, and your recommended option) per [ui-proposal-protocol.md](./references/ui-proposal-protocol.md#proposal-presentation-template).
3. Ask the user which option to apply (`Option A`, `Option B`, `Option C`, or a hybrid graft such as *"Option B layout with Option A density"*).

### Step 5 — Apply Chosen Variant & Verify
1. Once the user selects an option (or hybrid), restore the clean `HEAD` baseline on `<touched-files>` (`git checkout HEAD -- <touched-files>`), apply the saved patch (`git apply .audit/ui-propose/<task-slug>/option-<chosen>.patch`), and copy back any untracked variant files from `.audit/ui-propose/<task-slug>/files-<chosen>/` into the workspace (or graft the selected parts cleanly).
2. Run full verification (typecheck, linter, tests, and final screenshot proof) or hand off to [`arcus-work-loop`](../arcus-work-loop/SKILL.md) for the remaining implementation checklist.
