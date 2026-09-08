# EcoTrack Backend — Repository Analysis

> Generated 2026-09-08. Covers the code in this checkout plus insights from
> `EcoTrack_System_Design_2.md` and `EcoTrack_Database_Design_2.md`.

---

## 1. What this repository is

A **Django 5 + DRF** cloud backend for EcoTrack, a Kenyan home-energy monitoring product
(smart plugs, Zigbee hub, KPLC tariff tracking). This checkout is **Phase 1**: it implements
*authentication / session management* and *tenancy (sites / rooms / members)* only. The two
Markdown design documents describe a much larger target system; most of it is not yet built
here.

It leans heavily on **`django-corekit`**, a sibling package (`-e ../django-corekit`) providing
identity / MFA, a hash-chainable audit log, and a notifications framework. That package is
**not present in this checkout**, so corekit-owned endpoints are documented from the design
docs plus their call sites.

### Stack

| Concern | Choice |
|---|---|
| Web | Django 5.0–5.2, DRF 3.15+ |
| Auth tokens | `djangorestframework-simplejwt` 5.3+ with rotation + blacklist |
| DB | PostgreSQL 15 + TimescaleDB (`timescale/timescaledb:latest-pg15`) |
| Cache / throttle / broker | Redis (`django-redis`, Celery 5.4) |
| SMS | Africa's Talking REST (via `corekit.notifications`) |
| Config | `django-environ`, split settings (`base` → `dev`/`test`/`staging`/`production`) |
| Observability | `structlog`, `prometheus-client`, OpenTelemetry |
| Lint / test | `ruff` (line length 100), `pytest` + `pytest-django` |

---

## 2. Repository structure

```
ecotrack-backend/
├── manage.py
├── conftest.py                    # pytest: seeds corekit registry, captures SMS outbox
├── pyproject.toml                 # ruff + pytest config
├── EcoTrack_System_Design_2.md    # architecture, full target API surface (§8–9)
├── EcoTrack_Database_Design_2.md  # cloud (Postgres) + edge (SQLite) schema, v1.0
│
├── requirements/
│   ├── base.txt   dev.txt   production.txt
│
├── docker/
│   ├── Dockerfile                 # multi-stage; build context is PARENT of both repos
│   └── docker-compose.yml         # db (host :5433), redis, web, celery-worker, celery-beat
│
├── config/                        # project package
│   ├── settings/
│   │   ├── base.py                # RLS-critical: ATOMIC_REQUESTS=True; JWT; corekit knobs
│   │   ├── dev.py  test.py  staging.py  production.py
│   ├── urls.py                    # mounts both apps under  /v1/
│   ├── celery.py                  # beat: audit-verify /6h, notifications-retry /5min
│   ├── wsgi.py  asgi.py
│
└── apps/
    ├── accounts/                  # identity, OTP login, JWT sessions   (label: "accounts")
    │   ├── models.py              # User(AbstractCoreUser), AuthSession
    │   ├── serializers.py
    │   ├── views.py               # 10 auth/session/me endpoints
    │   ├── urls.py
    │   ├── authentication.py      # TenantScopingJWTAuthentication (sets RLS pre-user-lookup)
    │   ├── jwt.py                 # EcoTrackTokenObtainPairSerializer (+tenant_id, phone_e164)
    │   ├── services.py            # get_or_create_user_by_phone → new tenant + owner
    │   ├── throttle.py            # Redis OTP send throttle, keyed by phone + IP
    │   ├── sms.py                 # Africa's Talking backend + SMS MFA handler (ready())
    │   ├── registry.py            # 4 roles, 3 permissions, SMS MFA method (data only)
    │   ├── management/commands/   # seed_roles, bootstrap_admin_tenant
    │   ├── migrations/            # 0001, 0002, 0003_row_level_security
    │   └── tests/test_otp_flow.py
    │
    └── tenancy/                   # sites, rooms, per-site membership   (label: "tenancy")
        ├── models.py              # Tenant, Site, Room, SiteMembership
        ├── serializers.py
        ├── views.py               # sites/rooms/members CRUD (TenantScopedAPIView)
        ├── audit_views.py         # TenantAuditLogListView (subclasses corekit)
        ├── urls.py
        ├── scoping.py             # TenantScopedAPIView base — sets app.tenant_id in initial()
        ├── rls.py                 # set_tenant_context() — the one SET primitive
        ├── permissions.py         # effective_role(), has_site_access(), IsSiteMember
        ├── migrations/            # 0001, 0002_row_level_security
        └── tests/                 # test_permissions.py, test_rls.py
```

### Domain model (implemented tables)

| Table | Key fields | Notes |
|---|---|---|
| `tenants` | `tenant_id` (uuid pk), `display_name`, `county`, `created_at` | Auto-named `Household <last4>` on signup |
| `users` | `user_id` (uuid), `tenant_id` FK (PROTECT), `phone_e164` unique, `email` nullable-unique, `role` (corekit FK), `locale` `en-KE`, `status`, `last_login_at` | Extends corekit `AbstractCoreUser`; **no password** for end users; **RLS-protected** |
| `auth_sessions` | `session_id` (uuid), `user_id`, `refresh_token_jti` unique, `ip_address`, `device_name`, `login_at`, `last_activity`, `expires_at`, `is_revoked`/`revoked_at`/`revoked_reason` | One row per refresh token; **no RLS** (scoped by user). `last_activity` written on refresh only, not per request |
| `sites` | `site_id` (uuid), `tenant_id` FK, `label`, `timezone` (`Africa/Nairobi`), `meter_type` (prepaid/postpaid), `kplc_account_no`, `kplc_meter_no`, `supply_phase` (single/three), `occupant_count`, `status`, `static_ip`, `local_api_port` (8443), `allow_lan_commands`, `allow_cloud_commands`, `created_at` | **RLS-protected** |
| `rooms` | `room_id` (uuid), `tenant_id`, `site_id`, `name`, `room_type` | **RLS-protected** |
| `site_members` | surrogate `id`, `site_id`, `user_id`, `tenant_id` (bare uuid), `role` (owner/member/viewer/installer), `granted_by`, `granted_at`, `revoked_at`; unique `(site, user)` | **RLS-protected**. Design doc uses composite PK `(site_id, user_id)`; modelled as surrogate + unique constraint |

---

## 3. API endpoints — implemented

**Base URL:** `/v1/`  •  **Auth header:** `Authorization: Bearer <access>`  •  **Access token**
15 min, **refresh** 30 days (rotating, old jti blacklisted).
**No trailing slashes.**  **Error shape:** corekit's handler →
`{"error": {"code": "...", "message": "..."}}` (the design doc's RFC 7807 goal is not what the
code emits).
**Pagination:** DRF `CursorPagination` / `PAGE_SIZE=50` is configured, but the tenancy list
views are plain `APIView` and return **bare unpaginated arrays**. Only `/v1/audit-log` (a
corekit `ListAPIView`) is actually cursor-paginated (`?cursor=&limit=`).

### 3.1 Authentication & OTP  (`apps/accounts`)

---

#### `POST /v1/auth/otp/request` — *AllowAny*

Send a login OTP. **Doubles as sign-up:** an unseen phone number creates a new `Tenant` +
`owner` `User`. Redis-throttled: 5/hr per phone, 20/hr per IP (`MFARateLimited` otherwise).

Request:
```json
{
  "phone_e164": "+254712345678",
  "device_name": "Samsung A14"
}
```
- `phone_e164` — **required**, regex `^\+\d{9,15}$`
- `device_name` — optional, default `""`

Response `200`:
```json
{
  "pending_token": "<opaque>",
  "method": "sms",
  "masked_target": "+2547•••••678",
  "expires_in": 300
}
```

---

#### `POST /v1/auth/otp/resend` — *AllowAny*

Request:
```json
{ "pending_token": "<opaque>" }
```
Response `200`:
```json
{ "detail": "A new code has been sent." }
```

---

#### `POST /v1/auth/otp/verify` — *AllowAny*

Exchange the code for a token pair. Creates the `auth_sessions` row, stamps `last_login_at`,
writes audit `auth.login`.

Request:
```json
{
  "pending_token": "<opaque>",
  "code": "123456",
  "device_name": "Samsung A14"
}
```
Response `200`:
```json
{
  "access": "<jwt>",
  "refresh": "<jwt>"
}
```
Wrong/expired code → `401`. JWT carries custom claims: `tenant_id`, `phone_e164`,
`refresh_jti`.

---

#### `POST /v1/auth/refresh` — *AllowAny*

Rotates the pair; blacklists the old refresh token; updates the **same** `auth_sessions` row
in place (one device = one session entry across its lifetime).

Request:
```json
{ "refresh": "<jwt>" }
```
Response `200`:
```json
{ "access": "<jwt>", "refresh": "<jwt>" }
```
Invalid/expired/revoked/inactive-user → `401` `{"error":{"code":"INVALID_TOKEN", ...}}`.

---

#### `POST /v1/auth/logout` — *IsAuthenticated*

Revokes the session for the supplied refresh token, blacklists it, purges pending MFA, audits
`auth.logout`.

Request:
```json
{ "refresh": "<jwt>" }
```
Response `205` (no body).

---

#### `GET /v1/auth/sessions` — *IsAuthenticated*

Active (non-revoked) sessions, newest activity first.

Response `200`:
```json
[
  {
    "session_id": "1f0e...uuid",
    "device_name": "Samsung A14",
    "ip_address": "197.232.0.1",
    "login_at": "2026-09-01T08:12:00Z",
    "last_activity": "2026-09-08T06:40:00Z",
    "expires_at": "2026-10-01T08:12:00Z",
    "is_current": true
  }
]
```
`is_current` is computed by matching the access token's `refresh_jti` claim.

---

#### `DELETE /v1/auth/sessions/{session_id}` — *IsAuthenticated*

Revoke one session (`revoked_reason = "revoked_by_user"`) and blacklist its refresh jti.
`204`, or `404` if not found / not yours / already revoked.

---

#### `POST /v1/auth/sessions/revoke-all` — *IsAuthenticated*

Revoke every session, blacklist all jtis, purge pending MFA, audit
`auth.revoke_all_sessions`.

Response `200`:
```json
{ "revoked": 3 }
```

---

#### `POST /v1/auth/step-up/initiate` — *corekit `StepUpMFAInitiateView`, unmodified*
#### `POST /v1/auth/step-up/verify` — *corekit `StepUpMFAVerifyView`, unmodified*

OTP re-verification for high-consequence actions; on success the session is "elevated" for
`STEP_UP_ELEVATION_SECONDS` (300s) and `RequiresStepUpMFA` permission checks pass. Payloads
are owned by corekit (not in this repo) — by convention:
```jsonc
// initiate  → { }            (uses the caller's enrolled SMS method)
// response  → { "pending_token": "...", "expires_in": 300 }
// verify    → { "pending_token": "...", "code": "123456" }
```
The design doc (§8.1) specifies a single `POST /auth/step-up`; the implementation uses
corekit's two-call flow instead.

---

### 3.2 Current user  (`apps/accounts`)

#### `GET /v1/me` — *IsAuthenticated*
```json
{
  "id": "9c2f...uuid",
  "tenant": "3a11...uuid",
  "phone_e164": "+254712345678",
  "email": null,
  "display_name": "Jane W.",
  "role": "owner",
  "locale": "en-KE",
  "status": "active",
  "created_at": "2026-08-20T10:00:00Z",
  "last_login_at": "2026-09-08T06:40:00Z"
}
```

#### `PATCH /v1/me` — *IsAuthenticated*

Request (only these two are writable):
```json
{ "display_name": "Jane Wanjiku", "locale": "sw-KE" }
```
Response: the full `/me` object. (`display_name` aliases the DB column `full_name` via
`source`.)

---

### 3.3 Sites  (`apps/tenancy`, all `TenantScopedAPIView` → RLS-scoped)

#### `GET /v1/sites` — list sites in caller's tenant (ordered by `label`, unpaginated array)
#### `POST /v1/sites` — create; writes audit `site.created`

Request:
```json
{
  "label": "Nairobi Home",
  "timezone": "Africa/Nairobi",
  "meter_type": "prepaid",
  "kplc_account_no": "123456-01",
  "kplc_meter_no": "37012345678",
  "supply_phase": "single",
  "occupant_count": 4,
  "status": "active",
  "static_ip": "192.168.1.50",
  "local_api_port": 8443,
  "allow_lan_commands": true,
  "allow_cloud_commands": true
}
```
- `label`, `meter_type` (`prepaid`|`postpaid`) — **required**
- `supply_phase` `single`|`three` (default `single`); `status`
  `active`|`suspended`|`decommissioned`
- read-only: `site_id`, `created_at`

Response `201` — the full site object including `site_id` and `created_at`.

#### `GET /v1/sites/{site_id}` — detail; `404` if the caller has no effective role on the site
#### `PATCH /v1/sites/{site_id}` — partial update; requires effective role ≥ **member**; audit `site.updated`

```json
{ "label": "Nairobi Home (main)", "status": "suspended", "kplc_meter_no": "37099999999" }
```

---

### 3.4 Rooms  (`apps/tenancy`)

#### `GET /v1/sites/{site_id}/rooms` — list (needs site access), ordered by `name`
#### `POST /v1/sites/{site_id}/rooms` — needs effective role ≥ **member**

Request:
```json
{ "name": "Kitchen", "room_type": "kitchen" }
```
Response `201`:
```json
{ "room_id": "7d5a...uuid", "site": "3f2c...uuid", "name": "Kitchen", "room_type": "kitchen" }
```
(`room_id`, `site` read-only.)

#### `PATCH /v1/rooms/{room_id}` — needs ≥ **member**
```json
{ "name": "Main Kitchen", "room_type": "kitchen" }
```
#### `DELETE /v1/rooms/{room_id}` — needs ≥ **member** → `204`

---

### 3.5 Site members  (`apps/tenancy`)

#### `GET /v1/sites/{site_id}/members` — active memberships (needs site access)
```json
[
  {
    "id": 12,
    "user": "9c2f...uuid",
    "phone_e164": "+254712345678",
    "display_name": "Jane W.",
    "role": "member",
    "granted_by": "1a0b...uuid",
    "granted_at": "2026-09-02T09:00:00Z",
    "revoked_at": null
  }
]
```

#### `POST /v1/sites/{site_id}/members` — invite by phone; requires effective role **owner**; audit `site_member.granted`

Request:
```json
{ "phone_e164": "+254798765432", "role": "member" }
```
- `role` ∈ `owner` | `member` | `viewer` | `installer`
- The invitee **must already have an account** (they must have signed in via OTP at least
  once) → otherwise `400` validation error. `update_or_create`, so re-inviting a revoked
  member reactivates the row.

Response `201` — membership object.

#### `PATCH /v1/sites/{site_id}/members/{user_id}` — change role; requires **owner**; audit `site_member.role_changed`
```json
{ "role": "viewer" }
```
Unknown role → `400 {"error": {"code": "INVALID_ROLE", "message": "Unknown role."}}`.

#### `DELETE /v1/sites/{site_id}/members/{user_id}` — requires **owner** *and* **step-up MFA**; sets `revoked_at`; audit `site_member.revoked` → `204`

Client must have completed `/auth/step-up/initiate` + `/verify` immediately before, or
`RequiresStepUpMFA` raises `StepUpMFARequired`.

---

### 3.6 Audit log  (`apps/tenancy/audit_views.py`)

#### `GET /v1/audit-log` — *IsAuthenticated*; corekit `BaseAuditLogListView` subclass

Cursor-paginated (`?cursor=&limit=`). Scoped by
`actor__tenant_id == request.user.tenant_id` (a proxy — `AuditLogEntry` has no `tenant_id`
column). Response shape is corekit's; roughly:
```json
{
  "next": "<cursor>",
  "previous": null,
  "results": [
    {
      "id": 4021,
      "actor": "9c2f...uuid",
      "action_type": "site.updated",
      "category": "config",
      "entity": "Site",
      "entity_id": "3f2c...uuid",
      "before_state": { "...": "..." },
      "after_state":  { "...": "..." },
      "ip_address": "197.232.0.1",
      "created_at": "2026-09-08T06:41:12Z"
    }
  ]
}
```

---

## 4. API endpoints — specified but NOT implemented

The System Design doc (§8.1–8.10, §9) describes the full target surface. Everything below is
**design only** — no code, models, or routes exist yet:

| Area | Design ref | Notable payload from the docs |
|---|---|---|
| `/me/preferences`, `/me/consents/{purpose}`, `/me/push-tokens`, `/me/data-export`, `/me/data-erasure` | §8.1 | DPA-2019 SAR/erasure; erasure needs step-up |
| **Hubs** — claim, connection, resync, pairing-mode, diagnostics, backups, replace, certificate | §8.3 | `POST /hubs/claim {claim_code}` |
| **Devices / commissioning / appliances / bindings / commands** | §8.4 | `POST /devices/{id}/commands` with `Idempotency-Key` header: `{"action":"switch","state":"off","ttl_s":300,"override_until":"2026-08-13T22:00:00+03:00"}` — `409` if bound appliance `is_critical` |
| **Telemetry / mesh health / cost** — `/telemetry/series\|live\|summary`, `/costs/series\|summary\|breakdown`, `/insights`, `/exports/csv` | §8.5 | every cost response carries `is_estimated` + machine-readable reason |
| **Tariffs & billing** — `/tariffs/current`, `/sites/{id}/billing-period[/reset]`, `/token-purchases`, `/webhooks/mpesa/daraja` | §8.6 | duplicate token/receipt rejected |
| **Modes / rules / schedules** — CRUD + `/rules/{id}/test`, `/modes/{id}/activate` | §8.7 | trigger/condition/action JSONB grammar (DB design §1.6) |
| **Alerts / budgets / notifications** | §8.8 | `/notifications` distinguishes never-sent / failed / suppressed |
| **Subscription** — `/plans`, `/subscription[/change\|/cancel\|/payments]` | §8.9 | `/subscription/change` → M-Pesa STK, step-up required |
| **Realtime** `WSS /v1/stream?site_id=` | §8.10 | events: `telemetry.tick`, `device.state`, `alert.opened`, … |
| **Local hub API** `https://ecotrack-<serial>.local:8443/local/v1` | §9 | separate service on the SBC, not this repo |

---

## 5. Insights from the Markdown files

### 5.1 Architecture (System Design)

- **Cloud is system of record; the household hub is a cache with an outbox.** The two schemas
  are deliberately *different shapes*, not subset/superset. Sync is one-directional in
  authority: **"cloud version always wins — no merge, no conflict resolution."** A hub offline
  for a month just converges on reconnect.
- **Authority split** is the core conflict-avoidance mechanism: hub owns live device state,
  relay actuation, and rule/schedule *execution*; cloud owns accounts, tenancy, billing,
  rule/schedule *definitions*, tariffs, analytics, OTA. The two sides never write the same
  field.
- **`ecotrack-edge` daemon is Go** (single static binary, survives SD-card abuse); the cloud
  API is also Go in the target design — *this Django backend appears to be a Phase-1 stand-in
  / parallel track* (the design doc's "same language on both sides" argument is about Go).
- **Edge schema-migration contract**: the daemon halts rather than operate on an
  unknown-future schema; the cloud withholds config pushes to a hub whose
  `edge_schema_version` is behind and queues firmware first. Without this, the first OTA
  schema change bricks field hubs.
- **Schedule wrap semantics are normative and shared**: `start > end` wraps past midnight;
  `days_mask` selects the *start* day; `start == end` is rejected. Explicitly called out as
  "the most likely silent behavioural bug" and mandated into a shared test suite across cloud
  validator + edge scheduler.
- **Security model**: hubs make outbound connections only (no port-forwarding); mTLS
  hub↔cloud with per-hub certs + topic ACLs; cert pinning app↔hub; JWT app↔cloud; **step-up
  OTP replaces full MFA** ("adding TOTP on an SMS-OTP first factor gains little for a Kenyan
  household product"); rate limits are Redis + middleware, not DB state.
- **Kenya DPA 2019, not GDPR.** Household telemetry is occupancy-revealing (shows when a home
  is empty); PIR sensors make it direct. `consent_records`, `data_classification`, log
  masking, SAR/erasure endpoints are in-scope; ODPC registration + lawful-basis documentation
  are tracked as programme items.

### 5.2 Data-model philosophy (Database Design — 9 principles)

1. Cloud = record, edge = cache + outbox (different shapes).
2. **Devices and appliances are separate entities** — an appliance outlives the plug metering
   it; bindings make reassignment a new row, not a mutation, so last month's fridge spend
   doesn't silently become microwave spend.
3. **Tariffs are versioned data, never code** — historical bills must reproduce exactly after
   a gazette rate change (`cost_hourly` pins `schedule_id` per row).
4. Energy derived from **cumulative counters** (`max(cum) − min(cum)`), so outages cost
   resolution, not correctness.
5. **Money stored at scale 6, rounded only at display/invoice** — a 5 W standby load rounds
   to a 4 % error exactly on the loads the product exists to surface.
6. **Alerts are stateful intervals** (`opened_at`/`closed_at` + cooldown + hysteresis), not
   events — prevents notification storms from a fridge cycling around a threshold.
7. Schedules in **local wall-clock**, never UTC, overnight wrap legal.
8. **Every tenant-scoped table carries `tenant_id` directly** → RLS is a single predicate,
   not a join chain.
9. **Ephemeral counters (rate limits, OTP throttle, session activity) belong in Redis**,
   never on the Postgres request path.

- KPLC tariff modelling respects three structural facts: bands are **monthly-cumulative**
  (same kettle costs more on the 28th than the 3rd), levies **stack in defined order** and
  some are VAT-able (`applies_order` + `taxable` absorb EPRA changes as data edits), prepaid
  vs postpaid reset the accumulator differently.
- **Audit log**: one table (not `audit_log` + `security_events`), `category` distinguishes.
  Write-once by **privilege revocation** (`REVOKE UPDATE, DELETE`), not triggers.
  Hash-chaining is *deliberately deferred* — a `BEFORE INSERT` trigger reading the previous
  hash forks under concurrency and reports false tampering; if needed later, do periodic
  Merkle anchoring in one serialized worker.
- **Continuous-aggregate RLS leak** (open item #8): TimescaleDB continuous aggregates refresh
  under the owner's privileges and don't inherit the session RLS context. Flagged as a
  mandatory pre-launch test — tenant data can leak through `telemetry_hourly` /
  `telemetry_daily` even though the base hypertable is protected.

### 5.3 Where the implementation diverges from the docs (from code comments)

These are documented "integration decisions" — the codebase adapts the design to compose with
corekit:

| # | Design says | Code does | Why |
|---|---|---|---|
| 1 | Bespoke OTP tables (`auth_otp_requests`) | Rides corekit `identity.mfa` challenge machinery; SMS via `corekit.notifications` | One send path, one retry/observability story |
| 2 | `POST /auth/step-up` (single call) | corekit's `StepUpMFAInitiateView` + `VerifyView`, mounted unmodified | Zero EcoTrack code needed |
| 3 | `auth_failed_attempts` table | Dropped — forensic writes go to the audit log only | One forensic write path, not two. Unknown-phone attempts get only a structlog line (`record_audit_event` needs a non-null actor) |
| 7 | corekit's `create_user` | `create_user_by_phone` bypasses it | corekit's `create_user` requires a truthy email and only bootstraps an EMAIL-type MFA target |
| — | `rate_limit_config` table (§1.2) | EcoTrack Redis throttle in `throttle.py`, distinct from corekit's resend interval | corekit only rate-limits resends on an existing challenge; this also stops hammering unseen phone numbers and per-IP fan-out |
| — | Composite PK `(site_id, user_id)` on `site_members` | surrogate `id` + unique constraint | Django's composite-PK support is limited |
| — | `auth_sessions` in the RLS table list | **no** RLS policy on `auth_sessions` | No `tenant_id` column; a session is scoped to one user and every query already filters `user=request.user` |

### 5.4 RLS implementation notes (hardening beyond the doc)

- Policy uses **`current_setting('app.tenant_id', true)`** — the two-arg form returns `NULL`
  (not an error) when unset; `tenant_id = NULL` is never true, so an unauthenticated request /
  shell / management command **fails closed** (denies every row). The doc's literal example
  uses the one-arg form.
- **`ALTER TABLE ... FORCE ROW LEVEL SECURITY`** is as load-bearing as `ENABLE`: the Django
  app connects *as the table owner*, and Postgres exempts the owner from policies without
  `FORCE`.
- **`SELECT set_config('app.tenant_id', %s, true)`** rather than `SET LOCAL` — `SET` doesn't
  reliably accept a bound parameter through every driver path; `set_config(..., is_local :=
  true)` is an ordinary function call.
- **`ATOMIC_REQUESTS = True`** is required — `is_local` scopes the setting to the current
  transaction; without a request-wrapping transaction there's nothing for it to live in.
- Tenant context is set in **two** places: `TenantScopingJWTAuthentication.get_user()` sets
  it from the JWT's signed `tenant_id` claim *before* the `users` lookup (which is itself
  RLS-protected — chicken/egg), and `TenantScopedAPIView.initial()` re-sets it from
  `request.user.tenant_id` afterward (the mechanism every other table relies on). `rls.py`
  deliberately has no DRF import to avoid a circular import through DRF's auth-class loading.
- Views **never add `tenant_id=` filters** — deliberately, so a broken RLS policy surfaces in
  tests instead of being masked. `test_rls.py` reads `Site.objects.all()` with no filter to
  test the policy itself.

### 5.5 Product decisions baked into code

- **New phone number → new tenant + `owner` user, on first OTP request. No separate "create
  account" step.** Follows the M-Pesa-adjacent Kenyan consumer-app pattern (`services.py`).
- **`effective_role` = narrower of `users.role` and `site_members.role`.** A membership row
  can only *narrow*, never widen. **No membership row = the tenant-wide role applies to every
  site** (the common case — most tenants are single-site households). `installer` is ranked
  equal to `member` for narrowing; its cross-site step-up requirement is enforced separately.
- Django admin superusers still use email+password (`createsuperuser`); since `User.tenant` is
  `NOT NULL`, run `manage.py bootstrap_admin_tenant` first to get an "EcoTrack Internal"
  tenant id.
- Production settings **refuse to boot** without `AFRICASTALKING_API_KEY` (phone OTP is the
  only factor; the console SMS backend must never face real users).

### 5.6 Open questions carried in the docs

Prepaid band assignment (blocks accurate KES until M-Pesa/SMS token ingestion lands —
`is_estimated` stays `true`); free-tier remote access as a paid feature (unmade;
`plans.limits.remote_access` expresses either); `pg_jsonschema` availability on managed
Postgres; **RLS on continuous aggregates** (pre-launch test); SBC hardware selection; radio
topology (resolved to Zigbee-only, but `System_Overview` still describes a 433 MHz hybrid);
whole-home unmetered-gap reconciliation; how to present an unreachable device ("off" vs
"unknown" vs "check switch").

---

## 6. Testing

Real Postgres required (RLS + JSONB/UUID aren't meaningfully testable on SQLite) — `docker
compose up -d db redis` first. `conftest.py` seeds the corekit registry and swaps in a
capturing SMS backend.

- `apps/accounts/tests/test_otp_flow.py` — end-to-end OTP login, tenant+owner creation, token
  pair + session, wrong-code `401`, refresh rotation + old-token blacklist, revoke-all blocks
  refresh.
- `apps/tenancy/tests/test_permissions.py` — `effective_role` narrowing rules.
- `apps/tenancy/tests/test_rls.py` — unset context denies all rows; context scopes to exactly
  one tenant; HTTP request never sees another tenant's sites.

---

## 7. Endpoint quick reference

| Method | Path | Auth | Notes |
|---|---|---|---|
| POST | `/v1/auth/otp/request` | none | sign-up on first use; Redis throttled |
| POST | `/v1/auth/otp/resend` | none | |
| POST | `/v1/auth/otp/verify` | none | → `{access, refresh}`, creates session |
| POST | `/v1/auth/refresh` | none | rotates + blacklists old |
| POST | `/v1/auth/logout` | Bearer | `205`; revokes one session |
| GET | `/v1/auth/sessions` | Bearer | array; `is_current` flag |
| POST | `/v1/auth/sessions/revoke-all` | Bearer | → `{revoked: n}` |
| DELETE | `/v1/auth/sessions/{session_id}` | Bearer | `204` / `404` |
| POST | `/v1/auth/step-up/initiate` | Bearer | corekit |
| POST | `/v1/auth/step-up/verify` | Bearer | corekit; elevates 300s |
| GET | `/v1/me` | Bearer | user + tenant + role |
| PATCH | `/v1/me` | Bearer | `display_name`, `locale` only |
| GET | `/v1/sites` | Bearer | RLS-scoped array |
| POST | `/v1/sites` | Bearer | `label` + `meter_type` required |
| GET | `/v1/sites/{site_id}` | Bearer | `404` if no access |
| PATCH | `/v1/sites/{site_id}` | Bearer | role ≥ member |
| GET | `/v1/sites/{site_id}/rooms` | Bearer | |
| POST | `/v1/sites/{site_id}/rooms` | Bearer | role ≥ member |
| PATCH | `/v1/rooms/{room_id}` | Bearer | role ≥ member |
| DELETE | `/v1/rooms/{room_id}` | Bearer | role ≥ member; `204` |
| GET | `/v1/sites/{site_id}/members` | Bearer | active memberships |
| POST | `/v1/sites/{site_id}/members` | Bearer | role owner; invitee must exist |
| PATCH | `/v1/sites/{site_id}/members/{user_id}` | Bearer | role owner |
| DELETE | `/v1/sites/{site_id}/members/{user_id}` | Bearer + step-up | role owner; `204` |
| GET | `/v1/audit-log` | Bearer | cursor-paginated; tenant-scoped |
