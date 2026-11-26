### Opening a PR

Invoked at the end of every other playbook.

Work from a git worktree off trunk, and keep unrelated work out of it. Rebase into small, landable commits. Run [unslop](../internal/unslop.md) and [no-comments](../internal/no-comments.md) over the diff before commit.

Title: `type(scope): subject`, naming a real symbol when one carries the change. Body: a one-minute briefing under 40 lines with these `##` headings in order, dropping empty ones: `## Why`, `## What changed`, `## Scope`, `## Tradeoffs` (only rejected alternatives a reviewer would otherwise ask about), `## Blast Radius`, `## Visual Changes` (UI diffs only; drop if non-UI), `## Verification`. Keep a single-view Before/After table compact within the 40-line body cap. Offload multi-screen or multi-viewport grids to a PR or MR comment linked from `## Visual Changes`.

Stack follow-ups by base branch. Open PRs and MRs ready for review, never as drafts. Use the run's PR tool with `draft: false` when available. Without one, resolve the forge from `git remote get-url origin` host (or Origin CLI resolution) before choosing the CLI:

- GitHub: `gh pr create` without `--draft`.
- GitLab: non-interactive `glab mr create --target-branch <base> --title "<title>" --description "<desc>" --yes` without `--draft`.
- Origin: `origin pr create --status open` when Origin's CLI resolves the repository.

Opening a PR does not start a babysit.

#### UI visual evidence (UI diffs only)

Run these steps whenever the diff touches UI files (components, CSS or styles, templates, layouts).

**Pre-commit binary PNG guard.** Before committing or pushing, run `git diff --cached --name-only` and confirm that zero `.audit/ui-propose/` or scratch PNG files are staged. Never commit raw binary PNGs to the feature branch unless the repository explicitly tracks them.

**Before/After capture order.** Follow this sequence directly (self-contained for `arcus-mode`-only installs per `D-002`):

1. Reuse `.audit/ui-propose/<task-slug>/00-before.png` if it exists. After tests and build pass, capture a fresh post-polish `.audit/ui-propose/<task-slug>/99-after-final.png` at the identical route, viewport, scroll position, and light or dark theme. Never reuse stale draft option screenshots (`01-option-a.png` through `03-option-c.png`).
2. If `arcus-ui-propose` did not run, capture `after.png` on `HEAD`. Next, capture `before.png` at the identical route, viewport, scroll position, and theme from a temporary detached worktree at `merge-base`, and remove that temporary worktree unconditionally:
   ```bash
   git worktree add --detach "<tmp-dir>" $(git merge-base <base> HEAD)
   # capture before.png from "<tmp-dir>" at the locked route, viewport, scroll, and theme
   git worktree remove --force "<tmp-dir>"
   ```
3. If `merge-base` cannot boot (schema or lockfile drift) or capture cannot run in a headless environment, degrade without blocking: put `Before: N/A (<reason>)` alongside `After`, or note in `## Visual Changes` why capture could not run.

**Forge image attachment fallback chain.** Choose the first tier that applies:

1. GitLab (`glab`). Upload each PNG using cross-shell double quotes and the long `--form` flag (never `-F` or `--field`):
   ```bash
   glab api "projects/:fullpath/uploads" --form "file=@<path>"
   ```
   Extract `.markdown` from the JSON response and embed those URLs in the 2-column `## Visual Changes` table. If `glab` lacks `--form` or the upload fails, fall back without blocking to tier 3 below.
2. Repo or custom uploader. If the repository configures an explicit media upload script or endpoint, run it and embed the returned URLs.
3. GitHub (`gh`) and Safe Handoff Default. Because `gh` CLI has no official `user-attachments` upload API, never paste local filesystem paths (`C:\...`, `/Users/...`, `.audit/...`) into the remote PR body, and never commit binary PNGs to the feature branch. Put a compact 2-column `## Visual Changes` table with drag-and-drop placeholder slots plus route, viewport, and theme metadata in the PR body, and print the exact absolute local paths with inline Markdown previews in your chat handoff reply:
   ```markdown
   ## Visual Changes

   Route: `<route>` | Viewport: `<width>x<height>` | Theme: `<light|dark>`

   | Before | After |
   | :--- | :--- |
   | <!-- drop 00-before.png --> | <!-- drop 99-after-final.png --> |
   ```
