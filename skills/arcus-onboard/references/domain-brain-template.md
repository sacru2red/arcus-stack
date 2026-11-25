# Engineering & Domain Brain Template (`ONBOARDING.md`)

Keep the generated document to **1–2 pages (roughly 80–120 lines)** covering the seven domain and codebase questions a new engineer (or AI coding agent) must know in week one to avoid architectural mistakes.
- Every code mapping, formula, threshold, or minefield **must** include `[as of YYYY-MM-DD | Source: <File/Schema/System/Owner>]`.
- For OSS / CLI / internal libraries where specific sections do not apply, collapse confirmed non-applicable sections to `N/A`.

---

```markdown
# 🧠 Engineering & Domain Brain (`ONBOARDING.md`)

> Single source of truth for non-guessable domain-to-code mappings, business invariants, authz boundaries, legacy minefields, and systems of record.
> Last reviewed: `[as of YYYY-MM-DD | Source: <Team/Owner>]`

## 1. System Role & Service Boundaries (시스템 역할 & 서비스 경계)
- **Core Responsibility**: <What this repository owns and solves inside the broader product/system>
- **Upstream / Downstream Boundaries**: <Which external or sibling services call this repo, what this repo calls, and responsibilities this repo must NEVER absorb> `[as of YYYY-MM-DD | Source: <Arch Doc/Owner>]`
- **Runtime & Deployment**: <Primary runtime, hosting target, critical constraints>

## 2. Ubiquitous Language ↔ Code Mapping (도메인 용어 ↔ 코드 매핑 사전)
| Product / Business Term | Code / DB Identifier (`Table / Model / Column`) | Notes & Disambiguation (Never Guess) |
| :--- | :--- | :--- |
| `<e.g., Workspace>` | `tenants` table / `org_id` column | <e.g., Called "Organization" in legacy v1 routes> `[as of YYYY-MM-DD \| Source: prisma/schema.prisma]` |
| `<e.g., Member>` | `workspace_users` / `AccountRole` | <Exact distinction from billing contact> `[as of YYYY-MM-DD \| Source: src/auth/types.ts]` |

## 3. Core Business Logic & Invariants (핵심 비즈니스 공식 & 도메인 불변식)
| Domain Rule / Calculation | Exact Formula & Invariant | Source / Enforcing Module |
| :--- | :--- | :--- |
| **Money / Settlement / Units** | `<e.g., Stored in integer minor units (cents/KRW); round half-even before tax>` | `<src/billing/calc.ts>` `[as of YYYY-MM-DD \| Source: <Owner/File>]` |
| **Timezones & Date Boundaries** | `<e.g., All DB timestamps UTC; daily cutoffs evaluated in workspace timezone>` | `<src/lib/time.ts>` `[as of YYYY-MM-DD \| Source: <Owner/File>]` |
| **State Transitions** | `<e.g., Order cannot move from SETTLED back to PENDING without a refund ledger entry>` | `<src/orders/state.ts>` `[as of YYYY-MM-DD \| Source: <Owner/File>]` |

## 4. Authz Roles & Plan/Tier Gating (유저 권한 & 플랜/티어 게이팅)
- **Role Hierarchy & Enforcement**: `<e.g., Owner > Admin > Member > Viewer; enforced via requireRole() middleware>` `[as of YYYY-MM-DD | Source: <src/middleware/authz.ts>]`
- **Plan / Tier Feature Gates & Quotas**: `<e.g., Free vs. Pro vs. Enterprise limits; where feature flags/entitlements are checked>` `[as of YYYY-MM-DD | Source: <src/entitlements/index.ts>]`
- **Tenant Isolation Rule**: `<e.g., Every query on tenant-scoped tables MUST filter by org_id or use withTenantScope()>`

## 5. Legacy Minefields, Red Lines & Data Rules (레거시 지뢰밭 & 보안/데이터 금기 사항)
- **Do-Not-Touch Legacy Paths / Tables**: `<e.g., src/legacy-v1/ and billing_v1_invoices table are frozen for backwards compatibility — modify v2 equivalents instead>` `[as of YYYY-MM-DD | Source: <Owner/File>]`
- **Active Migrations & Dual-Writes**: `<e.g., Migrating from Redis session store to JWT; both paths active until Q3>` `[as of YYYY-MM-DD | Source: <Owner/ADR>]`
- **PII, Secrets & Logging Red Lines**: `<e.g., Never log request.body on /auth or /webhooks; encrypt tax_id at rest; never expose internal numeric IDs in public URLs>`

## 6. Systems of Record & External Integrations (데이터 원천 & 외부 연동)
| Domain State | Authoritative System of Record (기준 원천) | Sync Mechanism & Failure Recovery |
| :--- | :--- | :--- |
| **User Identity & Auth State** | `<e.g., Auth0 / Clerk / Local users table>` | `<Webhook sync / JWT claims>` `[as of YYYY-MM-DD \| Source: <File/Owner>]` |
| **Subscription & Payment Status** | `<e.g., Stripe Webhook Events (stripe_events table)>` | `<Idempotent webhook processor; never trust client redirect>` |
| **Issue Tracking & Release Sign-off** | `<e.g., Linear / GitHub Issues>` | `<Required checks and deploy approval owner>` |

## 7. Error Contracts, UX Copy, i18n & PR Conventions (에러 응답 규격·UX 문구·다국어·PR 컨벤션)
- **API Error Contract**: `<e.g., { error: { code, message, requestId } }; never leak raw stack traces or SQL errors>` `[as of YYYY-MM-DD | Source: <src/errors/handler.ts>]`
- **User-Facing Copy & i18n**: `<e.g., All UI strings must go through i18n keys in locales/; default locale and tone rules>`
- **Observability & PR Conventions**: `<Structured logger helper to use instead of console.log; commit/PR title format>`
```
