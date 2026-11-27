# ARCUS UI Proposal Protocol & 4-Screenshot Comparison Template

This reference defines the exact capture surface fallback chain, safe working-branch revert mechanics, and presentation template for `arcus-ui-propose`.

---

## 1. Capture Surface Fallback Chain (5-Agent Universal)

Select the highest-fidelity screenshot surface available in the current environment, keeping viewport dimensions, scroll position, and color scheme (`light` or `dark`) identical across all 4 captures (`00-before`, `01-option-a`, `02-option-b`, `03-option-c`):

1. **Host Browser / Device Preview Tools (When Available)**:
   - Web UI in T3 Code / IDE preview: `preview_status` ➔ `preview_open` / `preview_navigate` ➔ `preview_resize` (lock viewport) ➔ `preview_wait_for` ➔ `preview_snapshot(save=true)` (copy the returned `screenshotPath` into `.audit/ui-propose/<task-slug>/0N-*.png`).
   - Mobile Simulator / Emulator: `device_list` ➔ `device_open` ➔ `device_screenshot`.
2. **Project Verification Harness or Headless Browser CLI**:
   - If `.agents/skills/verify-<app>/SKILL.md` exists, use its documented Launch & Screenshot recipe.
   - Or capture via Playwright / Puppeteer / Chromium CLI against the local dev server URL (e.g., `npx playwright screenshot --viewport-size="1280,800" http://localhost:<port>/<route> .audit/ui-propose/<task-slug>/0N-*.png`).
3. **Isolated Component Harness / Self-Contained HTML Preview Fallback**:
   - If the full application server cannot be booted locally (missing external backend/secrets) or the environment only offers static HTML preview (`html_preview` or headless static screenshot), render the component's exact markup and styles against realistic fixture data at a locked viewport size and capture all 4 states (`Before`, `Option A`, `Option B`, `Option C`). State clearly in the proposal note that fixture data was used.

---

## 2. Non-Destructive Working-Branch Apply ➔ Capture ➔ Revert Protocol

Because variants A, B, and C are applied sequentially on the active working branch, you must guarantee that:
1. Pre-existing uncommitted user changes are never lost.
2. Each variant starts from the exact same baseline state (no leftover CSS or DOM from Variant A leaking into Variant B).
3. Selecting Option A, B, or C later does not require rewriting the code from scratch.

### Safe Cycle Recipe

```text
# 0. Setup scratch folder (never committed to git, never shown in git status)
mkdir -p .audit/ui-propose/<task-slug>
git check-ignore -q .audit/ || echo ".audit/" >> .git/info/exclude

# 1. Pin the baseline without touching the working tree (needs Git 2.23+ for git restore)
git status --porcelain > .audit/ui-propose/<task-slug>/00-status.txt
BASE=$(git stash create) || { echo "STOP: intent-to-add, unmerged, or no commit yet" >&2; exit 1; }
if [ -n "$BASE" ]; then IDX="$BASE^2"
elif [ -z "$(git status --porcelain -uno)" ]; then BASE=HEAD; IDX=HEAD
else echo "STOP: tracked changes but no stash commit" >&2; exit 1; fi
#    $BASE holds the user's working-tree files, $IDX the user's staged index.
#    On STOP, change nothing and tell the user which files block the pin.
#    copy pre-existing untracked files a variant will edit -> .audit/ui-propose/<task-slug>/untracked-base/

# 2. Capture Baseline ("Before")
<capture screenshot -> .audit/ui-propose/<task-slug>/00-before.png>

# 3. Variant Loop (for X in a, b, c; N in 1, 2, 3):
#    a) Edit <target-files> (and create any new variant files) to implement Option X
#    b) Wait for compile/HMR & verify no error overlay
#    c) Capture screenshot -> .audit/ui-propose/<task-slug>/0N-option-X.png
#    d) Save the tracked patch from the pinned baseline -> .audit/ui-propose/<task-slug>/option-X.patch
#       (git diff $BASE -- <target-files> > .audit/ui-propose/<task-slug>/option-X.patch)
#       and copy any new untracked files created by Option X (preserving relative paths) into:
#       .audit/ui-propose/<task-slug>/files-X/
#    e) Revert <target-files> back to the pinned baseline (user's edits and staging included).
#       <tracked> = the target files that exist in $BASE or $IDX; every other target file
#       was created by Option X. git restore fails as a whole on a path in neither tree.
#       for f in <target-files>; do
#         { git cat-file -e "$BASE:$f" || git cat-file -e "$IDX:$f"; } 2>/dev/null && echo "$f"
#       done
#       git restore --source="$BASE" --worktree -- <tracked> &&
#         git restore --source="$IDX" --staged -- <tracked> || { echo "STOP: revert failed" >&2; exit 1; }
#       restore edited pre-existing untracked files from untracked-base/
#       remove the other target files and any untracked files created by Option X

# 4. After Option C revert, confirm working tree matches Step 1 baseline.
#    Any output means the revert missed something: stop and show the user the differing lines.
git status --porcelain | diff - .audit/ui-propose/<task-slug>/00-status.txt

# 5. Once user picks Option <chosen> (a, b, or c):
#    git restore --source="$BASE" --worktree -- <tracked>
#    git restore --source="$IDX" --staged -- <tracked>
#    git apply .audit/ui-propose/<task-slug>/option-<chosen>.patch
#    copy .audit/ui-propose/<task-slug>/files-<chosen>/* back to their relative workspace paths (if any)
```

---

## 3. Proposal Presentation Template

Present the 4 screenshots and comparison table directly in your reply so the user can visually compare the baseline against all 3 proposals at a glance:

```markdown
## 🎨 UI Proposal & 4-Screenshot Visual Comparison (`<Target Screen / Component>`)

- **Captured Route / Viewport / Theme**: `<URL or Component>` · `<Width x Height>` · `<Light/Dark>`
- **Working Tree Status**: Reverted cleanly to pre-proposal baseline (`0` leftover edits). Patches saved under `.audit/ui-propose/<task-slug>/`.

### 0. Baseline — Before (`00-before.png`)
![Before — Current UI](/absolute/path/to/.audit/ui-propose/<task-slug>/00-before.png)
- **Current Friction / Root Cause**: <1-2 lines on what is visually cramped, ambiguous, or missing in the current state>

---

### 1. Option A — `<Short Title, e.g., Minimal Refinement>` (`01-option-a.png`)
![Option A](/absolute/path/to/.audit/ui-propose/<task-slug>/01-option-a.png)
- **Visual & UX Change**: <Concrete layout, spacing, typography, or component changes>
- **Trade-offs**: **Pros:** <...> / **Cons:** <...>

---

### 2. Option B (⭐ Recommended) — `<Short Title, e.g., Balanced Modern Hierarchy>` (`02-option-b.png`)
![Option B](/absolute/path/to/.audit/ui-propose/<task-slug>/02-option-b.png)
- **Visual & UX Change**: <Concrete layout, spacing, modern web primitive, or state feedback changes>
- **Trade-offs**: **Pros:** <...> / **Cons:** <...>

---

### 3. Option C — `<Short Title, e.g., High-Density / Alternative Layout>` (`03-option-c.png`)
![Option C](/absolute/path/to/.audit/ui-propose/<task-slug>/03-option-c.png)
- **Visual & UX Change**: <Concrete spatial reorganization or alternative interaction model>
- **Trade-offs**: **Pros:** <...> / **Cons:** <...>

---

### 📊 Quick Decision Matrix

| Variant | Layout / Density | Touch / Interaction Ergonomics | Blast Radius (Files) | Patch Ready |
| :--- | :--- | :--- | :--- | :--- |
| **Before (Baseline)** | <Current> | <Current> | `0` | `00-before.png` |
| **Option A** | <...> | <...> | `<N files>` | `option-a.patch` |
| **Option B (⭐ Rec)** | <...> | <...> | `<N files>` | `option-b.patch` |
| **Option C** | <...> | <...> | `<N files>` | `option-c.patch` |

**Which option should I apply?** (`Option A`, `Option B`, `Option C`, or a combination such as *"Option B with Option A's header"*)
```

---

## 4. PR / MR Before-After Handoff Template

After final polish and passing checks, capture `.audit/ui-propose/<task-slug>/99-after-final.png` at the identical route, viewport, scroll position, and light or dark theme used for `00-before.png`. Run `git diff --cached --name-only` before committing and verify zero `.audit/ui-propose/` PNG files are staged.

Keep single-view Before/After tables compact inside the 40-line PR body cap. Offload multi-screen or multi-viewport grids to a PR or MR comment linked from `## Visual Changes`.

For GitHub (`gh`) and any forge without CLI attachment upload (Safe Handoff Default), never paste local filesystem paths into the remote PR body and never commit binary PNGs to the feature branch. Put this 2-column table with drag-and-drop slots in the PR body:

```markdown
## Visual Changes

Route: `<route>` | Viewport: `<width>x<height>` | Theme: `<light|dark>`

| Before | After |
| :--- | :--- |
| <!-- drop 00-before.png --> | <!-- drop 99-after-final.png --> |
```

For GitLab MRs (`glab api "projects/:fullpath/uploads" --form "file=@<path>"`) or a configured repository media uploader, embed the returned hosted URLs in the same 2-column table:

```markdown
## Visual Changes

Route: `<route>` | Viewport: `<width>x<height>` | Theme: `<light|dark>`

| Before | After |
| :--- | :--- |
| ![Before](/uploads/<hash>/00-before.png) | ![After](/uploads/<hash>/99-after-final.png) |
```

When using the GitHub Safe Handoff Default, include the exact absolute local paths and inline Markdown previews in your chat handoff reply so the user can inspect and drag-and-drop both PNGs into the PR body:

```markdown
### Local Visual Evidence
- Before: `/absolute/path/to/.audit/ui-propose/<task-slug>/00-before.png`
- After: `/absolute/path/to/.audit/ui-propose/<task-slug>/99-after-final.png`

![Before](/absolute/path/to/.audit/ui-propose/<task-slug>/00-before.png)
![After](/absolute/path/to/.audit/ui-propose/<task-slug>/99-after-final.png)
```
