---
name: arcus-automate-me
description: >-
  Use for "arcus-automate-me", "/arcus-automate-me", "automate me",
  "create/update/refresh my -mode skill", or "capture my preferences or working
  style into a skill". Drafts or revises a personal -mode skill by mining
  recent transcripts and interviewing the user.
---

# Automate Me (`arcus-automate-me`)

A guided flow for turning the user's working conventions into a skill agents will follow. The output is one `-mode` skill tailored to them (e.g. `sacru-mode`, `arcus-mode`).

This skill orchestrates three pieces: an inline mining pass (step 1), [`arcus-skill-maker`](../arcus-skill-maker/SKILL.md) (when co-installed, for universal skill authoring), and [../arcus-mode/internal/unslop.md](../arcus-mode/internal/unslop.md) (when co-installed, for prose discipline). It sequences them; it doesn't replace them.

## Flow

### 0. Check for an existing skill

Look recursively in `.agents/skills/**/*-mode/SKILL.md`, `~/.agents/skills/*-mode/SKILL.md`, `.cursor/skills/**/*-mode/SKILL.md`, and `~/.cursor/skills/*-mode/SKILL.md` matching the user's handle. If one exists, confirm intent with your structured question tool (`ask_question` / `AskQuestion`, unless they already said "update my skill" or similar):

- Update the existing skill (default for repeat runs)
- Start fresh (rare, ask why before doing it)

Update mode changes the rest of the flow:
- Step 1 mines only history since the skill was last edited (`git log -1 --format=%cI <path>`).
- Step 2 asks what's changed or missing, not what to capture from zero.
- Step 4 edits the existing file in place. Preserve sections the user hasn't contradicted. Revise ones with new evidence. Add new sections only for genuinely new rules.

### 1. Mine their history

Locate the active workspace's conversation transcripts (or recent git commit/PR history if transcripts are unavailable) before fanning out. Stay strictly within the current workspace scope; do not read private chats from unrelated projects.

Survey recent agent conversations within that scope for recurring patterns. Run multiple parallel subagents across slices of history (e.g. last 2-4 weeks, split into 3 slices so each has enough material). Each slice mining subagent reads transcripts from the workspace-scoped path the parent provides, looks for the signals below, and returns a short structured list of patterns it saw with evidence pointers. Default signals worth hunting:

- Response preferences (length, tone, format, "dumb it down" corrections)
- Delegation habits (subagents, models, specialized workflows, parallelism)
- Verification posture (what "done" means, unit tests vs live repro, reviewers)
- Code and prose discipline (style, principles cited, lint/format tools)
- Process conventions (worktrees, commits, PRs, review/merge tooling)
- Meta preferences (fixing skills mid-task, proposing new ones)

Cross-check across slices before elevating a signal. Patterns seen in 2+ slices are high-confidence. Lone signals are weak and usually get dropped.

### 2. Ask the user directly

Mining misses intent that hasn't come up yet. Use your structured multiple-choice question tool (`ask_question` / `AskQuestion`) rather than asking the user to type from scratch.

Shape: one or two questions with 4-6 options each, multi-select enabled for category questions. Start broad ("Which areas matter most?"), then follow up on selected areas with specific options. After the structured rounds, one free-form chat question catches anything the options missed.

Don't dump 20 questions.

### 3. Cluster findings

Group the combined signals into sections. Common ones (use only what applies):

- **Response style**: length, tone, format.
- **Autonomy**: how much to do without asking, tool use.
- **Understand first**: which skills to reach for when scoping or investigating a change.
- **Subagents**: default, parallelism, model-to-task, specialized workflows.
- **Prose / code discipline**: principles, lint tools, style guides.
- **Review and verify**: repro posture, verification skills, live-testing tools.
- **Process**: git worktrees, commits, PRs, review/merge tooling.
- **Skills**: skill-authoring habits, fix-the-skill-first, proposing new skills.

The [`arcus-mode`](../arcus-mode/SKILL.md) skill (when co-installed) shows the shape. Read it for granularity. Don't copy its content blindly; the user's rules are tailored to them.

### 4. Draft the skill

Follow [`arcus-skill-maker`](../arcus-skill-maker/SKILL.md) and its [universal-skill-spec.md](../arcus-skill-maker/references/universal-skill-spec.md) (when co-installed) to author the skill:

- Path: default to `.agents/skills/<handle>-mode/SKILL.md` in the project (or `~/.agents/skills/<handle>-mode/SKILL.md` / `arcus-stack/skills/<handle>-mode/SKILL.md` if the user prefers a global skill).
- Handle: the user's chosen identifier.
- Frontmatter: use strictly `name` and `description` (universal 5-agent compatibility). Trigger on their name + `/<handle>-mode` + "work in their style", not on generic keywords like "write code" or "review PR".

### 5. Iterate on prose

Apply [../arcus-mode/internal/unslop.md](../arcus-mode/internal/unslop.md) (when co-installed; otherwise strip filler, em-dashes, connector colons, and abstract metaphors, and keep sentences short and declarative) to every line.

Show the draft to the user and take feedback. Expect multiple iterations. Cut ruthlessly. A mode skill is not a manual.

### 6. Land it

Work in a worktree or branch off main when applicable. Commit and push or open a PR.

## Guardrails

- **Don't overfit to one conversation.** A preference stated once and contradicted another time is noise. Require multiple instances before codifying it.
- **Don't codify legacy repo notation as user preference.** Historical naming conventions in old files are repository artifacts, not an immutable personal style.
- **Don't be clever.** Restating other skills' contents, inventing metaphors, or writing "poetic" prose for an agent reader is cost without benefit. Keep it operational.
- **Reference, don't inline.** Other skills the user relies on should appear as relative path references, not pasted excerpts.
- **Keep sections minimal.** Only add a section if the user has a specific, non-default rule there.
- **Name conventions generic.** Use "the user" or "the human" in imperatives, not the author's first name.
- **Don't force symmetry.** If a user has no process rules worth writing down, skip the Process section entirely.
