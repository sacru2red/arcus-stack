# Universal 5-Agent Skill Specification (`arcus-stack`)

To guarantee 100% compatibility across **Antigravity (`agy`), Claude Code, Codex, Cursor, and OpenCode**, every skill in `arcus-stack` must follow these rules:

## 1. Directory Layout
```text
skills/arcus-<skill-name>/
├── SKILL.md          # Required: Universal frontmatter + core workflow
├── references/       # Optional: Loaded on-demand via relative markdown links
├── scripts/          # Optional: Helper scripts executed by the agent
└── assets/           # Optional: Static templates or boilerplate files
```

## 2. Universal YAML Frontmatter
Only use `name` and `description` in `SKILL.md` frontmatter. Avoid agent-specific frontmatter keys (`allowed-tools`, `globs`, `alwaysApply`, `model`), as they are ignored or rejected by other agents. Express tool or file constraints in plain Markdown inside the body instead.

```markdown
---
name: arcus-<skill-name>
description: >-
  Clear third-person description of WHAT the skill does and WHEN to activate it
  (include trigger keywords like "arcus-<skill-name>" and natural user intents).
---
```

## 3. Progressive Disclosure & Relative Links
- Link to supporting files using relative paths: `[checklist.md](./references/checklist.md)`.
- Never inline massive reference tables directly in `SKILL.md`; let the agent read files in `references/` only when needed.
