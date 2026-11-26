---
name: arcus-security
description: >-
  PoC-backed security, authorization, secret hygiene, and supply-chain audit
  skill with context isolation, strict secret redaction, and local-only PoC
  boundaries. Use when the user invokes "arcus-security", "/arcus-security", or
  asks for a security audit, threat model, authz/IDOR check, secrets/CVE or
  supply-chain audit, or pre-launch and PR security checks on auth, billing,
  PII, untrusted input sinks, CI workflows, or dependency manifests.
---

# ARCUS Security, Authz & Supply-Chain Audit (`arcus-security`)

Prove real security flaws with concrete code-path traces and local negative tests. Drop unverified generic OWASP filler that has no reachable path in the repository. Follow the full checklists, scanner commands, and ledger template in [security-audit-protocol.md](./references/security-audit-protocol.md).

## Mandatory Safety Guardrails

1. **Local/Isolated PoCs Only**: Never send exploit payloads to staging, production, live URLs from `.env`, or external hosts. Prove exploitability with clean unit or integration negative tests against mocked, in-memory, or ephemeral local (`127.0.0.1`) targets. Leave zero untracked throwaway exploit scripts in the workspace.
2. **Strict Secret Redaction**: Report only `file:line`, secret class, and a masked preview (for example, `sk_live_***` or `ghp_***`). Never print raw secret values, tokens, credentials, or real PII into ledger `S-01`, chat output, commit messages, or PR comments.

## Audit Workflow

1. **Enforce Context Isolation (`D-004`)**:
   - If this session authored the code under review and a subagent tool (`invoke_subagent`, `delegate_task`, `Agent`, or `spawn_agent`) is available, delegate the audit to a fresh read-only subagent.
   - Pass only the pinned snapshot (`base..head` SHA or `HEAD` plus diff hash), target file paths or diff command, the existing Section A Security Ledger (Round 2+), and this `SKILL.md` path. Never pass author rationale.
   - If you are already in an isolated subagent or have no subagent tool, perform a Cold-Reader Reset and evaluate strictly from the on-disk snapshot.
   - On Round 2+, verify open `S-xx` findings against the new snapshot and negative tests before reading author replies.
2. **Build the Trust-Boundary & Asset Map**:
   - Read `ONBOARDING.md` or `CONTEXT.md` if present, then cross-check cited routes, schemas, and authz tiers against live code.
   - Enumerate entry points (HTTP/RPC routes, webhooks, CLI inputs, background jobs, CI triggers), privilege levels, tenant boundaries, and sensitive assets (secrets, PII, billing/money, shell, DB, filesystem, and outbound network sinks).
3. **Run the Authn/Authz Matrix & Taint-Sink Trace**:
   - Check every read and mutation for horizontal tenant or object isolation (IDOR/BOLA), vertical role or tier gating, state-transition bypass, and mass assignment.
   - Trace untrusted input to dangerous sinks: SQL/NoSQL queries, shell or command execution, filesystem paths and archive extraction, outbound URLs (SSRF), deserializers, templates, and CI `${{ github.event.* }}` expressions.
4. **Audit Secrets, PII & Supply Chain (Non-Blocking)**:
   - Scan diffs, source files, configs, and log sinks for hardcoded credentials, weak cryptographic defaults, and PII leakage.
   - Run the ecosystem's native dependency audit (`npm`/`pnpm`/`yarn audit`, `pip-audit`, `cargo audit`, `govulncheck`) and optional `PATH`-only scanners (`gitleaks`, `semgrep`, `osv-scanner`) per [security-audit-protocol.md](./references/security-audit-protocol.md).
   - Check binary availability first. Never install missing tools or hang on network timeouts. Mark missing or offline scanners `SKIPPED` and proceed.
5. **Prove Findings Locally & Maintain the Security Ledger (`S-01`, `S-02`, ...)**:
   - Prove every `CRITICAL` and `HIGH` finding with a real `file:line` source-to-sink trace and, wherever testable, a clean local, mocked, or ephemeral (`127.0.0.1`) negative regression test.
   - Drop speculative findings that cannot be traced to reachable code in the pinned snapshot.
   - Output the Security Findings Ledger (`S-01`, `S-02`, ...) with statuses (`OPEN`, `FIXED_VERIFIED`, `MITIGATED`, `ACCEPTED_RISK`, `FALSE_POSITIVE`), a redacted Scanner Execution Summary, and minimal remediation steps per [security-audit-protocol.md](./references/security-audit-protocol.md).

## Completion Gate

- Every `CRITICAL` and `HIGH` finding cites exact `file:line` paths and local negative test proof (or names the exact runtime boundary that blocks automated local execution).
- Every secret or PII finding uses masked previews only, with zero raw credentials or real PII anywhere in the report.
- All applicable native and `PATH` scanners report `RAN` or `SKIPPED`, and `git status` shows zero leftover throwaway PoC scripts.
