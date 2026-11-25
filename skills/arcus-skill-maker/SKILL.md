---
name: arcus-skill-maker
description: >-
  Meta-skill for creating, remixing, or adapting external skills into the
  universal arcus-stack format. Use when the user invokes "arcus-skill-maker"
  or asks to create a new skill, convert an external skill/prompt/plugin from
  GitHub, or standardize a skill across Antigravity (agy), Claude Code, Codex,
  Cursor, and OpenCode.
---

# ARCUS Universal Skill Maker (`arcus-skill-maker`)

Transform any idea, workflow, or external skill (from Claude Code, Cursor `.mdc`, OpenCode, Codex, or Antigravity) into a clean, token-efficient `arcus-*` skill that works seamlessly across all 5 agents.

## Skill Creation & Remix Workflow

1. **Analyze the Source / Intent**:
   - If remixing an external skill or repo, extract its core procedural value, checklists, and scripts while stripping tool-locked syntax.
   - Consult [universal-skill-spec.md](./references/universal-skill-spec.md) for cross-agent compatibility rules.
2. **Design for Progressive Disclosure**:
   - Keep `skills/arcus-<name>/SKILL.md` concise (under 100 lines): focus on **when to trigger** and the **step-by-step execution procedure**.
   - Move detailed templates, long checklists, domain docs, or examples into `skills/arcus-<name>/references/`.
   - Move executable automation into `skills/arcus-<name>/scripts/`.
3. **Enforce Universal Frontmatter**:
   - Use strictly `name: arcus-<name>` and a comprehensive `description` in the YAML frontmatter so all 5 agents parse it without warnings.
4. **Verify & Register**:
   - Create the skill files under `skills/arcus-<name>/`.
   - Document the new skill in all language `README*.md` tables and `rules/AGENTS.md` (when working inside `arcus-stack`).
