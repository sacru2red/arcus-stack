# ARCUS Security Audit Protocol (`arcus-security`)

This reference defines the hard safety boundaries, trust-boundary and authz checklists, taint-to-sink catalog, non-blocking scanner table, local PoC rules, and persistent Security Findings Ledger (`S-01`, `S-02`, ...) for `arcus-security`.

## 1. Mandatory Safety Guardrails (Hard Stop Rules)

### Local/Isolated PoCs Only
- **Forbidden targets**: Never send exploit payloads, fuzzing probes, or authentication bypass requests to staging, production, live URLs read from `.env` or config files, third-party APIs, or any external host.
- **Allowed targets**: Prove exploitability only through clean unit tests, integration tests, mocked services, in-memory stores, or an ephemeral local (`127.0.0.1`) server started inside the test process.
- **Workspace hygiene**: Never leave untracked throwaway exploit scripts in the repository. Convert each verified PoC into a clean negative regression test or remove temporary scripts before handoff.

### Strict Secret Redaction
- **Allowed output format**: Report only `file:line`, secret class (for example, `Stripe live key`, `GitHub PAT`, `PostgreSQL URI password`, `Private RSA key`), and a short masked preview (for example, `sk_live_***`, `ghp_***`, `postgres://user:***@host`).
- **Forbidden output**: Never print raw secret values, API keys, bearer tokens, session cookies, private keys, or real user PII into ledger `S-xx`, terminal logs, chat responses, commit messages, or PR comments.
- **Committed secret guidance**: When a secret appears in git history (not just an uncommitted diff), note that removing the line alone is insufficient and recommend immediate key rotation plus history scrubbing.

## 2. Context Isolation & Snapshot Pinning (`D-004`)

1. **Pin the Snapshot**:
   - Committed or PR audit: pin `base_sha..head_sha` (`git rev-parse HEAD`).
   - Uncommitted diff audit: pin `HEAD` SHA plus the diff hash (`git diff HEAD | git hash-object --stdin`) and freeze edits during the audit.
2. **Delegate Cleanly**:
   - When the current session authored the diff and a subagent tool is available, spawn a fresh read-only subagent with only the snapshot ID, target files or diff command, Section A of any prior Security Ledger, and `skills/arcus-security/SKILL.md`.
   - Do not include author explanations, design rationale, or assurances that a check happens elsewhere.
3. **Round 2+ Blind Re-Evaluation**:
   - Evaluate every open ledger item (`OPEN`, `MITIGATED`) against the new code snapshot and negative tests before reading Section B author replies.

## 3. Trust-Boundary & Authz Matrix Checklist

Build a compact matrix for every route, RPC handler, webhook, background job, or CLI entry point touched by the audit scope:

| Entry Point | Caller & Tenant Scope | Authn Gate | Horizontal Isolation (IDOR/BOLA) | Vertical Role / Tier Gate | Sensitive Assets & Sinks |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `POST /api/invoices/:id/refund` | Authenticated tenant user | Verified session middleware | Query scoped by `WHERE id = $1 AND tenant_id = session.tenantId` | Requires `billing:refund` role and paid plan | Stripe API, `invoices` table |

Check every touched entry point against these failure patterns:
- **Horizontal isolation (IDOR / BOLA)**: Object IDs looked up by primary key alone without scoping to the authenticated user or tenant ID from the verified session.
- **Untrusted tenant or actor override**: Reading `tenantId`, `orgId`, `userId`, or `role` from request body, query params, or headers instead of the verified session token.
- **Vertical privilege and plan-tier bypass**: Enforcing admin roles or paid-tier limits only in frontend UI while backend handlers accept direct API calls.
- **Mass assignment**: Passing raw `req.body` or form payloads directly into ORM `create`/`update` calls without an explicit field allowlist (allowing overwrites of `isAdmin`, `planTier`, `ownerId`, or `status`).
- **State-transition and replay gaps**: Skipping required workflow states (for example, marking an order fulfilled without verified payment) or accepting webhooks without HMAC signature verification and timestamp replay bounds.
- **Auth token and cookie hygiene**: Missing JWT algorithm pinning (`alg: none` or HMAC/RSA confusion), weak or hardcoded signing secrets, missing `HttpOnly`/`Secure`/`SameSite` on session cookies, or permissive wildcard CORS with credentials enabled.

## 4. Taint-to-Sink Catalog

Trace every untrusted input (HTTP params, headers, cookies, request bodies, uploaded files, webhook payloads, database fields populated by external users, and GitHub event payloads) to dangerous sinks:

| Flaw Class | High-Risk Sinks to Inspect | Local Proof & Minimal Fix |
| :--- | :--- | :--- |
| **SQL / NoSQL Injection** | String concatenation or template interpolation in raw SQL, `ORDER BY` dynamic columns, MongoDB `$where` or unvalidated operator objects (`$ne`, `$gt`) | Negative test passing metacharacters or operator JSON; fix with bound parameters, strict column allowlists, and schema validation. |
| **RCE / Command Injection** | `child_process.exec`, `spawn(..., { shell: true })`, Python `subprocess(..., shell=True)`, `os.system`, PowerShell `Invoke-Expression` | Negative test with shell metacharacters (`;`, `$(...)`, `\|`) asserting no shell execution; fix with `execFile` or argv arrays (`shell: false`) and allowlisted arguments. |
| **Path Traversal & Zip-Slip** | `path.join(baseDir, userPath)` without prefix containment, archive extraction writing entries containing `..` or symlinks | Negative test with `../../etc/passwd` or traversal archive entry; fix with `path.resolve` plus `realpath` prefix check against the canonical root directory. |
| **SSRF (Outbound URL Sink)** | `fetch`, `axios`, `requests`, `http.Get`, headless browser navigation, or webhook callbacks using user-supplied URLs or following redirects | Negative test against mocked resolver or ephemeral `127.0.0.1` target verifying link-local (`169.254.169.254`), loopback, and RFC1918 blocks; enforce scheme/host allowlist and re-validate redirects. |
| **Mass Assignment & Prototype Pollution** | Spreading raw JSON into models, recursive merge helpers accepting `__proto__`, `constructor`, or `prototype` | Negative test sending privileged or `__proto__` keys and asserting fields remain unchanged; parse through strict DTO allowlists. |
| **Deserialization & Template Injection (SSTI / XSS)** | `pickle.loads`, `yaml.load` without `SafeLoader`, `eval`, `new Function`, `dangerouslySetInnerHTML`, unescaped server templates | Negative test with crafted payload asserting safe rejection or escaped output; replace with safe parsers (`JSON.parse`, `yaml.safe_load`) and contextual auto-escaping. |
| **CI Workflow Injection & Supply-Chain** | Untrusted `${{ github.event.issue.title }}`, `pull_request.title`, `comment.body`, or `head.ref` inside `run:` blocks; `pull_request_target` checking out PR head; unpinned third-party actions; `permissions: write-all` | Trace expression to shell block; pass values via `env:` variables instead of inline `${{ ... }}`, pin external actions to full commit SHAs, and scope `permissions` to least privilege. |

## 5. Cross-Ecosystem Non-Blocking Scanner Command Table

Check tool availability on `PATH` before running (`command -v <bin>` on POSIX or `Get-Command <bin> -ErrorAction SilentlyContinue` on PowerShell). Never install missing tools, never download binaries during an audit, and never block indefinitely on offline registries. If a tool is absent or offline, record `SKIPPED (unavailable)` or `SKIPPED (offline)` and continue.

| Scope / Ecosystem | Trigger Files | Non-Blocking Command (`PATH`-Only) | Notes |
| :--- | :--- | :--- | :--- |
| **Node.js (npm)** | `package-lock.json` | `npm audit --omit=dev` | Run in manifest dir; mark `SKIPPED (offline)` if registry is unreachable. |
| **Node.js (pnpm)** | `pnpm-lock.yaml` | `pnpm audit --prod` | Run in manifest dir; non-blocking on network errors. |
| **Node.js (Yarn)** | `yarn.lock` | `yarn audit` (or `yarn npm audit` on Berry) | Match local Yarn major version. |
| **Python** | `requirements*.txt`, `pyproject.toml`, `poetry.lock` | `pip-audit` | Optional `PATH`-only; `SKIPPED (unavailable)` if absent. |
| **Rust** | `Cargo.lock` | `cargo audit` | Optional `PATH`-only; `SKIPPED (unavailable)` if absent. |
| **Go** | `go.mod`, `go.sum` | `govulncheck ./...` | Optional `PATH`-only; `SKIPPED (unavailable)` if absent. |
| **Secrets (`PATH`-only)** | Any repository or diff | `gitleaks git --redact --no-banner` (or `gitleaks dir --redact --no-banner`) | Always pass `--redact`; still verify no raw secret is printed. |
| **SAST (`PATH`-only)** | Any source tree | `semgrep scan --config auto --quiet` | Skip if offline or missing; verify hits against live code before filing. |
| **Multi-Ecosystem CVEs (`PATH`-only)** | Any lockfile | `osv-scanner scan -r .` | Skip if offline or missing; confirm reachability before rating `CRITICAL`/`HIGH`. |

## 6. Local PoC Proof & Triage Rules

1. **Evidence Bar by Severity**:
   - `CRITICAL` / `HIGH`: Must include an exact `file:line` source-to-sink trace, concrete exploit preconditions, and (where testable) a clean local, mocked, or ephemeral (`127.0.0.1`) negative regression test that fails before the fix and passes after.
   - `MEDIUM` / `LOW`: Must cite exact `file:line` and concrete failure mode in the repository.
2. **Drop Generic Filler**: If a concern is generic OWASP boilerplate with no reachable entry point or real sink in the codebase, omit it.
3. **Clean Exit**: Verify `git status` has no stray PoC scripts or unredacted scratch dumps before finishing.

## 7. Persistent Security Findings Ledger (`S-01`, `S-02`, ...)

Keep the findings table physically separated from remediation notes so Round 2+ audits verify fixes from code first.

### Section A: Security Findings Ledger (Read FIRST on Round 2+)

| ID | Round | Pinned Snapshot | Severity | Category | Target (`File:Line`) | Redacted Trace, Local PoC Proof & Required Fix | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `S-01` | R1 | `a1b2c3d` | `CRITICAL` | `Authz/IDOR` | `src/routes/invoices.ts:48` | `GET /invoices/:id` loads row by `id` without `tenantId` filter. Local test with Tenant B token returns Tenant A row (`200`). Scope query by `session.tenantId` and assert `404`. | `OPEN` |
| `S-02` | R1 | `a1b2c3d` | `HIGH` | `Secret` | `src/billing/client.ts:12` | Hardcoded Stripe live key (`sk_live_***`). Move to env var, rotate exposed credential, and add redaction test. | `FIXED_VERIFIED` |

Allowed `Status` values:
- `OPEN`: Confirmed vulnerability not yet fixed and verified.
- `FIXED_VERIFIED`: Fix confirmed directly in the latest code snapshot and covered by passing local negative test or check.
- `MITIGATED`: Compensating control reduces exploitability, though the underlying code path remains; document the residual risk.
- `ACCEPTED_RISK`: Operator explicitly accepted the risk with documented rationale and expiry or scope.
- `FALSE_POSITIVE`: Independent verification of the live snapshot proved the finding is unreachable or already guarded upstream.

### Section B: Remediation & Risk Acceptance Log (Read ONLY After Code Check on Round 2+)

Authors record fix commit SHAs, test commands, or risk-acceptance notes by ID here, never inside Section A:
- `S-01`: Scoped query in `src/routes/invoices.ts:48` to `session.tenantId` and added cross-tenant `404` test in `tests/invoices.authz.test.ts` (commit `<sha>`).

### Section C: Scanner Execution Summary

| Scanner | Command | Result |
| :--- | :--- | :--- |
| `npm audit` | `npm audit --omit=dev` | `RAN (0 high/critical)` |
| `gitleaks` | `gitleaks git --redact --no-banner` | `SKIPPED (unavailable)` |
