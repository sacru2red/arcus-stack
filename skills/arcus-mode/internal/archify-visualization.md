---
name: archify-visualization
description: "Internal sub-skill for prioritizing tt-a1i/archify interactive HTML/SVG diagrams, one-page explainers, and codebase architecture maps when handling visualization or diagramming requests."
---

<!--
  Copyright tt-a1i and Archify contributors.
  Source: https://github.com/tt-a1i/archify (Licensed under Apache License 2.0)
  Modification Notice (Apache-2.0 Section 4(b)): Adapted for arcus-stack — encapsulated as an on-demand visualization bridge with a cross-platform 5-agent skill locator, OS temp-dir output isolation to prevent working-tree pollution, and a non-blocking 3-tier bootstrap/fallback chain.
-->

# Archify-First Visualization Routing (`archify-visualization`)

When the user asks to **visualize, diagram, map, chart, or produce a visual 1-page explainer** for a system, codebase, architecture, workflow, sequence, data flow, state machine/lifecycle, database schema (ERD), class hierarchy, tree, timeline, or latency waterfall—or when an `arcus-plan`, `arcus-explain`, or `arcus-ketchup` request asks for a rich visual diagram—**prioritize [`tt-a1i/archify`](https://github.com/tt-a1i/archify) as your primary visualization engine** before falling back to static Mermaid or plain prose.

---

## 1. Scope & Boundary with `arcus-ui-propose`

- **Use `archify-visualization` (this module) for**:
  - **10 Native Diagram Types**: `architecture`, `workflow`, `sequence`, `dataflow`, `lifecycle`, `erd`, `class`, `tree`, `timeline`, `waterfall`.
  - **One-Page Visual Explainers (`explainer`)**: When the user asks for an interactive visual explainer page, a shareable 1-page breakdown, or a visual comparison/diagnosis page.
  - **Repository Architecture Health & Coupling (`code-analysis`)**: When the user asks to visually map or diagnose module coupling, dependency cycles, or refactoring scope across a codebase.
- **Use [`arcus-ui-propose`](../../arcus-ui-propose/SKILL.md) instead for**:
  - Live application UI/component styling or layout changes where you capture **1 "Before" screenshot + 3 proposed variant screenshots (`Option A/B/C`)** from the actual running app via sequential working-branch apply ➔ capture ➔ revert.
- **On-Demand Discipline (`[archify explainer: on-demand]` posture)**:
  - Prioritize `archify` whenever visualization, diagramming, or a visual explainer page is requested or materially clarifies a complex multi-module architecture plan. Do **not** generate unrequested HTML explainer pages on routine 1-line chat answers, simple bug fixes, or text-only requests (`unslop` compliance).

---

## 2. Working-Tree Clean Output Rule (Prevent `.archify/` Pollution)

Upstream `archify` defaults to writing `.archify/<type>-<slug>-<timestamp>/` inside the current repository root. To avoid dirtying `git status` during read-only planning (`arcus-plan`), catch-ups (`arcus-ketchup`), or code reviews (`arcus-review`):

- **Default Output Location (OS Temp Directory)**: Unless the user explicitly asks to commit or save diagram files inside the repository (e.g., *"save the architecture SVG/HTML in `docs/` or `README.md`"*), write all `candidate.json`, `candidate.archify.md`, finalized `<slug>.html`, and receipt files under an OS temporary directory:
  - `<os.tmpdir()>/archify/<type>-<slug>-<YYYYMMDD-HHMMSS>/` (for example `/tmp/archify/...` on macOS/Linux or `$env:TEMP\archify\...` on Windows).
- **No Unasked Browser Popups**: Never pass `--open` in headless, background subagent ([`worker.md`](../worker.md)), or automated runs unless the user explicitly asks to open a desktop browser window.

---

## 3. 3-Tier Non-Blocking Resolution & Execution Chain

Never block an autonomous loop (`arcus-work-loop`) or subagent (`worker.md`) waiting for human confirmation to locate or bootstrap `archify`. Follow this 3-tier chain:

### Tier 1 — Locate Installed `archify` Across All 5 Agents (+ T3 Code Sandboxes)

Run this cross-platform Node.js one-liner to locate `archify/bin/archify.mjs` across workspace and global skill directories (`Antigravity`/`agy`, `T3 Code`, `Claude Code`, `Codex`, `Cursor`, `OpenCode`):

```sh
node -e "const fs=require('fs'),os=require('os'),p=require('path'),h=os.homedir(),c=[p.join(process.cwd(),'.agents/skills/archify/bin/archify.mjs'),p.join(h,'.agents/skills/archify/bin/archify.mjs'),p.join(h,'.gemini/config/skills/archify/bin/archify.mjs'),p.join(h,'.claude/skills/archify/bin/archify.mjs'),p.join(h,'.codex/skills/archify/bin/archify.mjs'),p.join(h,'.cursor/skills/archify/bin/archify.mjs'),p.join(h,'.config/opencode/skills/archify/bin/archify.mjs')];const t3=p.join(h,'.t3/userdata/providers/antigravity');if(fs.existsSync(t3)){for(const d of fs.readdirSync(t3))c.push(p.join(t3,d,'config/skills/archify/bin/archify.mjs'));}const hit=c.find(x=>fs.existsSync(x));if(hit)console.log(hit);"
```

- If a path `<ARCHIFY_MJS>` is printed:
  1. Read `<ARCHIFY_DIR>/SKILL.md` (where `<ARCHIFY_DIR>` is two levels above `bin/archify.mjs`) and the matching schema/example from its Type Router (`schemas/<type>.schema.json`, `examples/...`).
  2. Author the complete candidate JSON (or `candidate.archify.md` for `explainer`) in the isolated output directory (`<os.tmpdir()>/archify/<type>-<slug>-<ts>/` unless a repo path was requested).
  3. Run `finalize`:
     ```sh
     node "<ARCHIFY_MJS>" finalize <type> "<out-dir>/candidate.json" "<out-dir>/<slug>.html" --quality showcase --json
     ```
     *(Add `--repo-root "<repo-root>"` for repository-backed diagrams, or run `node "<ARCHIFY_MJS>" code-analysis prepare "<repo-root>" --out "<out-dir>/analysis"` for architecture health investigations.)*

### Tier 2 — Non-Blocking Auto-Bootstrap When Not Installed

If Tier 1 prints nothing (not yet installed) and network/shell access is available:
1. Run the official `npx skills` one-command bootstrap non-blockingly:
   ```sh
   npx -y skills@latest add https://archify.si --skill archify -g --copy --yes
   ```
   *(If `~/.npm` is read-only in a sandbox, prefix `NPM_CONFIG_CACHE=/tmp/npm-cache`.)*
2. Re-run the Tier 1 Node.js locator snippet. If `<ARCHIFY_MJS>` resolves, verify with `node "<ARCHIFY_MJS>" doctor` and execute the Tier 1 authoring & `finalize` workflow.

### Tier 3 — Graceful Offline / Sandbox Fallback

If Tier 2 fails (e.g., air-gapped/offline environment, restricted network sandbox, or no Node.js runtime):
1. Do **not** fail or halt the user's task.
2. Fall back cleanly to:
   - An inline **Mermaid diagram** (`flowchart`, `sequenceDiagram`, `stateDiagram-v2`, `erDiagram`, `classDiagram`, `xychart-beta`) in the Markdown response, **and/or**
   - A self-contained inline HTML visualization via `html_preview` ➔ `html_render` **only** if those host tools are explicitly declared in the current session's tool list.
3. Add a single concise note in your reply stating that `archify` was unreachable in the current environment and the fallback renderer was used.

---

## 4. Delivery & Presentation Contract

1. **Primary Artifact Link**: Lead with a clickable Markdown link to the finalized standalone HTML file (`[<Title>](/abs/path/to/<slug>.html)`, or exported `.svg` when generating for a repository `README.md`), plus 1–3 concise sentences stating the key architectural takeaway in the user's conversation language.
2. **Inline Chat Visibility**: Because standalone `.html` links require opening a file viewer or browser, always pair the `.html` link with either:
   - A compact summary / key path breakdown directly in the chat reply so the answer reads clearly even before opening the HTML, and
   - If `html_preview` and `html_render` are declared in the current environment and the generated artifact is self-contained without blocked external CDN dependencies, you may additionally render an inline preview. Never call `html_preview` or `html_render` in environments where those tools are absent.
