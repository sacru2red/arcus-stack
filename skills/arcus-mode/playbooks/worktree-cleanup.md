### Worktree and simulator cleanup

1. Snapshot and audit. Record free disk space (`df -h /` or `Get-PSDrive`), then inspect all worktrees from `git worktree list --porcelain` (never hand-typed paths, per **principle-encode-lessons-in-structure**). Classify each worktree by size, age, merge state (`git branch --merged origin/HEAD` or target base branch), uncommitted work (`git status -s`), PR state (`gh pr list`), and active session usage, then suggest a bucket.
2. The bucket is advice, not permission. The pinned and active sessions are the real artifact (**principle-prove-it-works**). Get that set from the user or active session list and cross-check every candidate. The pinned/active set always wins.
3. Verify usage before deleting. For every recently touched worktree, or anything you doubt, inspect whether an ongoing session or background subagent still references that worktree (**principle-guard-the-context-window**). Pick each subagent's reasoning level for the job, per the Subagents section.
4. Pause on irreversible loss. `wip:N` is N tracked uncommitted edits. Show the diff and get a decision first, since removing a clean worktree is recoverable from its branch but uncommitted work is gone. `scratch:N` is untracked throwaway, safe to drop, but name the files. Per Autonomy, clean and merged and not-in-use proceeds. `wip` and in-use pause.
5. Prune the confirmed set. Per path, `git worktree remove --force <path>`. If the dir survives on ignored build artifacts, remove it and run `git worktree prune`. Branch refs survive, so no commits are lost. Confirm free disk space and re-list.
6. Simulators and other reclaimers. Simulators are usually the next-biggest win on macOS: `xcrun simctl --set testing delete all` (XCTestDevices clones), `xcrun simctl delete unavailable`, and `xcrun simctl runtime list` then `runtime delete <id>` for old runtimes. More when needed: Xcode `DerivedData` and `iOS DeviceSupport`, editor/IDE backup caches, and package caches (pnpm, uv, brew, yarn, npm). Clear only caches the user has not said to keep.

This is the one playbook that deletes user state with no code review to catch a slip, so the gates above are the review.

**Reply:** `df -h /` before and after with space reclaimed, the worktrees pruned, and a one-line reason for each held back (in-use by which chat, or uncommitted work).
