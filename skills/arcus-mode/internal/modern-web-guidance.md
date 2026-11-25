---
name: modern-web-guidance
description: "Internal sub-skill for retrieving modern HTML, CSS, and client-side JS/DOM best practices via the GoogleChrome modern-web-guidance CLI before writing or reviewing web UI code."
---

<!--
  Copyright Google LLC.
  Source: https://github.com/GoogleChrome/modern-web-guidance (Licensed under Apache License 2.0)
  Modification Notice (Apache-2.0 Section 4(b)): Adapted for arcus-stack — removed pinned --skill-version hash, replaced blocking pre-execution permission prompts with a non-blocking offline fallback chain, and aligned citation rules with arcus-mode.
-->

# Modern Web Guidance (`modern-web-guidance`)

Search and retrieve standardized modern web best practices at the **start** of implementing, updating, or reviewing any web UI, CSS layout/animation, or client-side JS/DOM logic before writing ad-hoc solutions or adding third-party dependencies.

- **Trigger immediately for**: modals/dialogs/popovers, tables, dark mode, anchor positioning, container queries, view transitions, scroll-driven animations, parallax/reveals, forms, validation, autofill, accessibility, custom selects, scrollbars, Core Web Vitals (`LCP`, `INP`, `CLS`), `content-visibility`, fetch priority, image optimization, security, passkeys, HTML sanitization, web components, dates/timezones, built-in AI, WebAssembly, and standard HTML/CSS/DOM inside frameworks (React, Vue, Svelte, etc.).
- **Do NOT trigger for**: pure backend (SQL, ORMs, server-only API routes), infra/scripts (CI/CD, Docker, GitHub Actions, Python/Go, Git), or trivial build/config edits (`tsconfig`, ESLint, file renames).

---

## Primary Workflow

### Step 1. Search Use Cases

Run `modern-web-guidance` with `npx -y` (`npx.cmd -y` on Windows, or `pnpx` when `pnpm` is preferred) using a **2–5 word action-oriented English query** for a **single web platform capability or UI pattern**:
- **Keep queries focused and generic**: Describe the user-visible capability (`<verb> + <UI/platform object>`, optionally paired with the HTML/CSS/JS feature name). Omit framework names (`React`, `Vue`, `Tailwind`) and app-specific component names. Split multi-feature tasks into separate `search` calls.
- **Name implied UI primitives**: Translate domain intent into the underlying platform mechanism (e.g., search `"confirmation modal dialog"` rather than `"confirm destructive action"`, or `"date picker input"` rather than `"pick a date"`).

```sh
npx -y modern-web-guidance@latest search "<2-5 word query>"
```

- **Match found**: Call `retrieve` directly—do not also run `list`.
- **Weak or empty results**: If `search` returns `[]` or unrelated descriptions, rephrase `search` once using the concrete HTML/CSS/UI noun (`dialog`, `popover`, `table`, `form`) before falling back to `list`.
- **Topic not covered**: If no description matches after rephrasing, proceed without retrieving unrelated guides.

### Step 2. Retrieve Best Practices

Pass relevant `id`(s) from the search results (comma-separated when multiple apply, including broader discipline guides such as `html`, `css`, `js`, `forms`, `accessibility`, `color`, `performance`, `security`):

```sh
npx -y modern-web-guidance@latest retrieve "<id>"
```

If `retrieve` saves large output (`> 9.5 KB`) to a temporary file to prevent truncation, read that file path using your file-reading tool.

### Step 3. Apply & Verify Guidance Compliance

- **Applicable Guidance & Baseline Fallbacks**: All guides assume **Baseline Widely Available** features are safe without fallbacks. For features not yet Baseline Widely Available, apply the guide's recommended fallback unless the repository defines an explicit custom browser support policy.
- **Framework Adaptation**: Adapt vanilla HTML/CSS/JS patterns cleanly to the project's framework (e.g., spread/type-cast newly shipped attributes like `popover`, `interestfor`, `commandfor` rather than dropping them; guard `window`/`HTMLElement` in SSR; call `showModal()`/`moveBefore()` via refs; use per-instance IDs via `useId()`).
- **Concise Evidence Citation**: In your verification summary, briefly cite the applied guide `<id>` and the specific platform rule or fallback used. Do not add mandatory multi-line boilerplate headings.
- Do **not** run `legacy-scan` during feature, bug-fix, or targeted component work.

---

## Non-Blocking Execution & Offline Fallback Chain

Never pause an autonomous loop (`arcus-work-loop`) or subagent (`worker.md`) to ask the user for pre-execution approval, and never modify `AGENTS.md` or `CLAUDE.md` unprompted (`D-006`). Follow this non-blocking chain:

1. **Direct Run**: Execute `npx -y modern-web-guidance@latest ...` (or `npx.cmd -y` on Windows / `pnpx`). If `~/.npm` is read-only in a sandbox, set `NPM_CONFIG_CACHE=/tmp/npm-cache`.
2. **Offline Retry**: If the command fails or times out due to restricted network access, retry once with `npx --offline -y modern-web-guidance@latest ...`.
3. **Graceful Degradation**: If the package is not cached and the environment is offline, proceed with the task without blocking and note the offline skip in one line in your verification report.

---

## Alternative Flow: Broad Codebase Modernization (`legacy-scan`)

**Only** when the user explicitly requests a broad, open-ended codebase modernization or legacy-pattern scan (never during regular feature or bug tasks):

```sh
npx -y modern-web-guidance@latest legacy-scan <path> --json
```

1. **Scan**: Run `legacy-scan <path> --json` to detect legacy web platform patterns (~20% of the catalog with deterministic static rules).
2. **Verify**: Check each finding against its `keepWhen` / `dropWhen` rubric and drop false positives.
3. **Report or Modernize**: Report verified findings, and if asked to modernize, retrieve each finding's guide via `retrieve "<guide-id>"`, apply the replacement with required fallbacks, and re-run `legacy-scan <path>` on modified files.
