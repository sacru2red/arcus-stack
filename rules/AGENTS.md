# ARCUS-STACK Core Engineering Principles

**ARCUS** (**A**gent **R**ules, **C**ommands & **U**niversal **S**kills) integrates the core engineering philosophies of `pstack` ("Go deep first to go fast") and `oh-my-*` ("Autonomous multi-agent orchestration with real verification evidence").

## 1. Deep First, Less Code (`pstack` Philosophy)
- **Root Cause Over Symptom Patching**: Never slap a defensive null-check or retry loop over a bug you do not fully understand. Trace the data flow and invariants to the root cause first.
- **Minimal Blast Radius**: Write the smallest, cleanest, and most verifiable change that solves the problem completely. Avoid unrelated formatting or speculative abstractions.
- **Explicit Boundaries**: Respect module boundaries, type safety, and domain invariants.

## 2. Guarded Execution & Real Evidence (`oh-my-*` Philosophy)
- **Separate Strategy from Execution**: For non-trivial tasks, establish a concrete plan (`arcus-plan`) before modifying production files.
- **Evidence-Driven Completion**: A task is never complete until verified by real execution evidence (typecheck, linter, unit/integration tests, or reproducible CLI check). Never claim success based solely on reading your own diff.
- **Parallelism with Isolation**: Delegate independent read-only research or isolated verification tasks to subagents when available, keeping the primary context clean and focused.

## 3. Available Core Skills (`arcus-*`)
- `arcus-plan`: Deep-first root-cause analysis, blast-radius mapping, and step-by-step execution planning.
- `arcus-work`: Autonomous end-to-end execution loop (`ultrawork` / `autopilot`) from research to verified implementation.
- `arcus-review`: Strict adversarial code review checking root-cause validity, architectural boundaries, edge cases, and test evidence.
- `arcus-skill-maker`: Meta-skill for absorbing, remixing, and standardizing external skills into universal 5-agent compatible `arcus-*` skills.
