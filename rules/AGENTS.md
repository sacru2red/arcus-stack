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
- `arcus-mode`: Master operating mode enforcing the 24 deep-first principles, 22 task playbooks, unslopped prose, and deliberate subagent delegation.
- `arcus-plan`: Deep-first root-cause analysis, blast-radius mapping, and an actionable execution and verification checklist tailored to the task goal.
- `arcus-work-loop`: Autonomous checklist-driven execution loop that implements, diagnoses, and checks off each task item with real verification evidence.
- `arcus-review`: Strict adversarial critique and review for both architectural plans (`arcus-plan`) and code changes (`arcus-work-loop`), checking root-cause validity, boundaries, edge cases, and verification evidence.
- `arcus-in-your-own-words`: Restate the user's goal and core problem in your own words to verify alignment before acting.
- `arcus-create-verification`: Generate and prove a project-local verification skill (`verify-<app>`) and user-POV feature map.
- `arcus-maintain-verification`: Audit and update an existing project verification skill via parallel source readers and a live driving pass.
- `arcus-ketchup`: Catch the user up on what changed since their last message in plain words, visuals, and decision-ready action items.
- `arcus-why`: Answer "why does X work this way" from git commit and PR history rather than guessing from current code.
- `arcus-correct`: Find repeated agent mistakes in the repo and make them impossible via architecture, types, lints, or behavior tests.
- `arcus-automate-me`: Mine recent conversation transcripts and interview the user to draft or update a personal `<handle>-mode` skill.
- `arcus-skill-maker`: Meta-skill for absorbing, remixing, and standardizing external skills into universal 5-agent compatible `arcus-*` skills.
