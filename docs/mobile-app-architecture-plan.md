# EcoTrack — Mobile App & Web Dashboard: Architecture & Implementation Plan

**Status:** DRAFT FOR REVIEW — no application code written yet.
**Date:** 2026-09-08
**Sources:** `backend_design.md`, `EcoTrack_System_Design_2.md`, `EcoTrack_Database_Design_2.md`,
`uxpilot-export-09-08-26.pdf` (wireframes — could not be rendered on this machine; worked from the
screen list in the build brief), plus the existing DevOps shell in this repo.

Read section 1 first. It changes what is buildable now versus later, and it lists the
assumptions I need you to confirm before Phase 1.

---

## 0. Blockers before any code

| # | Blocker | Owner | Detail |
|---|---------|-------|--------|
| B1 | ~~Flutter/Dart toolchain~~ | — | **RESOLVED 2026-09-08.** Good SDK is `C:\Users\LINET\develop\flutter` (3.47.2). Kaspersky was quarantining `dart.exe` + throttling `pub get`; restored + worked around. `pub get` / `analyze` / `test` / `build web` all pass. Remaining hygiene (remove old `C:\Program Files\flutter`, KES exclusions, Android SDK) tracked in `docs/toolchain-setup.md`. |
| B2 | ~~Native runners not scaffolded~~ | — | **RESOLVED.** `flutter create . --platforms=android,ios,web` run; customizations reconciled (KTS flavor/signing, manifest label, pubspec, .gitignore). |
| B3 | **Backend is Phase-1 only** | you to confirm | See §1. ~80% of the screens depend on endpoints that are *designed but not implemented*. Decision needed on how to proceed (mock server vs wait vs build-ahead). |
| B4 | **Role model mismatch** | you to confirm | Backend roles are `owner/member/viewer/installer` (per-tenant + per-site). The wireframes assume `tenant / building_manager / super_admin`. These do not map. See §1.3. |

---

## 1. Reconciling the four documents

The build brief is written against the *design docs* (`System_Design`, `Database_Design`), which
describe the **target** system. `backend_design.md` describes what the Django backend **actually
serves today**. They diverge significantly.

### 1.1 What the backend implements today

**Tier A — real endpoints, buildable end to end now:**

| Area | Endpoints |
|------|-----------|
| Auth / OTP | `POST /v1/auth/otp/request`, `/otp/resend`, `/otp/verify`, `/auth/refresh`, `/auth/logout` |
| Sessions | `GET /v1/auth/sessions`, `DELETE /v1/auth/sessions/{id}`, `POST /v1/auth/sessions/revoke-all` |
| Step-up | `POST /v1/auth/step-up/initiate`, `/step-up/verify` (two-call, corekit) |
| Current user | `GET /v1/me`, `PATCH /v1/me` (only `display_name`, `locale` writable) |
| Sites | `GET/POST /v1/sites`, `GET/PATCH /v1/sites/{id}` |
| Rooms | `GET/POST /v1/sites/{id}/rooms`, `PATCH/DELETE /v1/rooms/{id}` |
| Members | `GET/POST /v1/sites/{id}/members`, `PATCH/DELETE /v1/sites/{id}/members/{user}` |
| Audit log | `GET /v1/audit-log` (cursor-paginated) |

**Tier B — designed, spec'd in `System_Design §8–9`, but NO code/routes/models exist:**
devices, commissioning, appliances, bindings, commands, telemetry, `/telemetry/live`, costs,
insights, CSV export, tariffs, billing periods, token purchases, M-Pesa webhooks, modes, rules,
schedules, overrides, alert-definitions, alert-events, budgets, notifications, hubs (claim /
connection / resync / pairing / diagnostics / backups / replace / certificate), subscriptions /
plans / payments, `/me/preferences`, `/me/consents`, `/me/push-tokens`, `/me/data-export`,
`/me/data-erasure`, `WSS /v1/stream`, and the **entire local hub API** (`https://ecotrack-<serial>.local:8443/local/v1`).

**Almost every screen in the wireframes is Tier B.** Home dashboard, Devices, Insights,
Automation, Alerts, all Building-Manager screens, all Super-Admin screens.

### 1.2 API conventions — the code differs from the design docs

| Design doc says | Backend actually does | Impact on the app |
|-----------------|----------------------|-------------------|
| Base `https://api.ecotrack.co.ke/v1` | same host, path `/v1`, **no trailing slashes** | Dio `baseUrl` + a no-trailing-slash lint on endpoint constants |
| RFC 7807 `problem+json` errors | `{"error": {"code": "...", "message": "..."}}` | Error model parses `error.code` / `error.message`; keep a 7807 fallback for Tier B |
| Cursor pagination everywhere | Tier A **list endpoints return bare unpaginated arrays**; only `/audit-log` is `{next, previous, results}` | Two response envelopes to support; don't assume pagination on sites/rooms/members |
| `POST /auth/step-up` (single call) | corekit two-call: `/initiate` then `/verify` | Step-up service is a 2-step state machine |
| — | `POST /auth/otp/request` **doubles as sign-up** (unknown phone → new tenant + `owner`) | No separate registration screen; "Contact Building Manager" link in the wireframe is misleading for self-signup — confirm desired behaviour (B4) |
| access 15 min / refresh 30 d | same; refresh **rotates**, old `jti` blacklisted, one `auth_sessions` row per device across its life | Refresh interceptor must handle rotation + single-flight |
| `phone_e164` regex `^\+\d{9,15}$` | same | validator |

### 1.3 Role model mismatch (B4)

- **Backend:** `users.role ∈ {owner, member, viewer, installer}` (tenant-wide) narrowed by
  `site_members.role` (same set). No membership row ⇒ tenant role applies to every site.
- **Wireframes:** three personas — Tenant, Building Manager, Super Admin — with entirely
  different navigation trees and screens.
- **`System_Design §13.3`** mentions a separate `installer`/admin console.

**These are not the same axis.** "Building Manager" ≈ a tenant `owner` who owns multiple sites,
*or* a future org-level role. "Super Admin" ≈ EcoTrack internal staff on the "EcoTrack Internal"
tenant (the backend has `bootstrap_admin_tenant` + Django superusers with email/password — a
*different auth path* the mobile OTP flow doesn't cover).

**RESOLVED (Q1, 2026-09-08): adjust the design to match the backend.** No three-persona
split. One app; features gated by **effective role** = narrower of `users.role` (from `/me`)
and the per-site `site_members.role`:

| Role | Capability |
|------|-----------|
| `owner` | everything on their sites — device control, automation, members, subscription, meter/billing setup, site CRUD |
| `member` | device control, modes, view insights/alerts; **no** member management, subscription, or site deletion |
| `viewer` | read-only — dashboards, insights, alerts, device state; controls disabled with a reason |
| `installer` | commissioning, calibration, hub diagnostics; other actions need step-up on sites they don't own |

- `RoleGuard` / `context.can(Permission.x)` helper resolves capability from effective role;
  every actuating control checks it and renders disabled + reason otherwise.
- Multi-site owners get the `SiteSelector`; there is no distinct "Building Manager" UI — the
  Manager wireframe screens (building rollup, units, billing) become an **owner-with-many-sites**
  view reached from the site selector, built later (Phase 8) only if the endpoints exist.
- **Super-Admin / ops screens are dropped from the mobile app.** They're internal tooling on a
  separate auth path (Django superuser, email+password) — web dashboard or Django admin, not here.
- `installer`/admin console (`System_Design §13.3`) is also out of mobile scope for v1.

### 1.4 Decisions

| A | Decision |
|---|-----------|
| A1 | **v1 mobile scope = all end-user screens, role-gated** (§1.3). No Building-Manager / Super-Admin apps. Manager-style multi-site views deferred to Phase 8. |
| A2 | **API-first (Q2, 2026-09-08).** Every repository calls the real endpoint at `api.ecotrack.co.ke/v1` per the `System_Design §8` / `backend_design.md` contracts first. A **mock layer is fallback only** — used when `EnvConfig.mockMode` is on (dev), or when a call returns 404/501 (endpoint not deployed yet). Mock responses live in `data/remote/mock/fixtures/` and match the documented JSON shapes exactly. The local drift cache is always the offline fallback beneath both. |
| A3 | Base URLs: cloud `https://api.ecotrack.co.ke/v1`, staging/dev per flavor `.env`. LAN base derived from mDNS at runtime. |
| A4 | Local DB = **drift** (SQLite; has a working web target). Not sqflite (no real web support). |
| A5 | DI = **get_it + injectable**. Routing = **go_router**. Models = **freezed + json_serializable**. |
| A6 | No analytics SDK, no crash SDK, no ad SDK in v1 (see §9). Crash hooks are stubbed in `bootstrap.dart` for later opt-in. |
| A7 | Web dashboard is the **same Flutter project**, cloud-transport only, responsive shell — not a second codebase. |
| A8 | Offline write model = **outbox** table mirroring the edge `outbox`/`cmd_queue` design; "cloud always wins" on downlink. |

---

## 2. Target architecture

### 2.1 Layering

```
presentation  (features/*/presentation: bloc, pages, widgets)   depends on ↓ domain
    │                                                            never imports data/ or dio/drift
domain        (domain/entities, domain/usecases, domain/repositories = interfaces)
    │                                                            pure Dart, no Flutter, no IO
data          (data/local, data/remote, data/repositories = impls)  implements domain interfaces
```

**Dependency rule:** arrows point inward. `presentation → domain ← data`. A widget never touches
Dio or drift; a use case never imports a Bloc. `injection/` is the only place the three meet.

For simple features an explicit use-case class per call is overkill; the rule is **use-case class
when there's real orchestration** (auth verify = OTP + session persist + DI re-scope), **direct
repository call from Bloc** when it's a pass-through (list rooms). Documented so it's consistent.

### 2.2 Offline-first repository pattern

Every read-repository method returns a **stream** backed by the local DB, and triggers a network
refresh as a side effect:

```dart
Stream<Result<List<Device>>> watchDevices(String siteId) async* {
  yield* _dao.watchDevices(siteId).map(Result.ok);      // 1. emit cache immediately
  if (_staleness.isStale('devices:$siteId')) {          // 2. >5 min old?
    final r = await _api.getDevices(siteId);            // 3. fetch (if online)
    r.when(
      ok: (dtos) => _dao.upsertDevices(dtos),           // 4. write-through → stream re-emits
      err: (f) => _emitBanner(f),                       // 5. keep cache, surface a soft error
    );
  }
}
```

- **Reads:** cache-first, background revalidate, staleness tracked per key in a `sync_meta` table.
- **Writes:** optimistic local mutation → append to `outbox` → return. Sync engine drains outbox.
  UI shows a per-item `queued / syncing / failed` chip.
- **Conflict:** downlink replaces local rows wholesale (`cloud wins`, `System_Design §6.2`). The
  outbox is the only local-authored state; on a conflict the outbox item is dropped + surfaced.
- **`clock_conf`:** telemetry rows carry it; aggregates/cost exclude `< 2` until reconciled,
  mirroring the backend.

### 2.3 Transport abstraction (`System_Design §13.1`)

```
                 ┌── EcoTrackClient (abstract) ──┐
   repositories →│  identity/state/devices/live/ │→  one of:
                 │  command/modes/today/rollups  │
                 └──────────────────────────────┘
                     ▲                        ▲
            CloudTransport (Dio)      LanTransport (Dio + pinned TLS)
            HTTPS api.ecotrack.co.ke  https://ecotrack-<serial>.local:8443/local/v1
```

`ConnectionManager` (feeds `ConnectivityBloc`) runs the state machine:

```
start → mDNS query _ecotrack._tcp.local (timeout 2s, device-pref configurable)
  ├─ hub found + /identity OK + pinned fp matches → LAN     (green)
  ├─ else → probe GET api/health
  │     ├─ 2xx + last hub heartbeat < 90s          → CLOUD           (blue)
  │     └─ 2xx + hub stale                          → CLOUD_HUB_OFFLINE (blue, controls disabled)
  └─ no network                                     → OFFLINE          (red, read-only cache)
```

Re-evaluated on: `connectivity_plus` change, app resume, LAN request failure, manual pull.
Both transports send the **same `Idempotency-Key`** so a command sent over both routes applies
once (edge `cmd_dedup`).

### 2.4 Sync engine

| Trigger | Mechanism |
|---------|-----------|
| Periodic (15 min) | `workmanager` one-off rescheduled; iOS = BGTaskScheduler best-effort |
| Network regained | `connectivity_plus` stream → `SyncBloc.add(SyncRequested())` |
| Foreground poll (5 min) | timer while app is foregrounded + online |
| Realtime | `WSS /v1/stream?site_id=` (cloud) or `/events` (LAN) via `web_socket_channel`, auto-reconnect w/ backoff |

**Outbox drain order** (priority, matches edge design): alerts ack > mode/state changes >
config edits > telemetry-derived. Exponential backoff per item, `expires_at` respected
(a queued "switch off" from 6 h ago does **not** fire).

---

## 3. Directory structure (file-by-file)

Builds on the existing shell (`lib/bootstrap.dart`, `lib/main_*.dart`,
`lib/core/config/env_config.dart` stay; `lib/app.dart` moves to `lib/app/app.dart`).

```
lib/
├── main.dart                     # fallback entry → bootstrap(dev)   [exists]
├── main_dev.dart                 # flavor entry                       [exists]
├── main_staging.dart             #                                    [exists]
├── main_prod.dart                #                                    [exists]
├── bootstrap.dart                # bindings→dotenv→EnvConfig→configureDependencies()→runApp  [exists, extend]
│
├── app/
│   ├── app.dart                  # EcoTrackApp: MaterialApp.router, theme, localization, BlocProviders (global blocs)
│   ├── router.dart               # GoRouter config, redirect guards, ShellRoutes for bottom-nav / web-sidebar
│   ├── router_refresh.dart       # ChangeNotifier bridging AuthBloc/ConnectivityBloc → router refresh
│   └── themes/
│       ├── colors.dart           # EcoColors — the wireframe palette (§7.3), light + dark tokens
│       ├── typography.dart       # EcoTypography — text styles
│       ├── spacing.dart          # EcoSpacing / radii / elevation tokens
│       └── theme.dart            # AppTheme.light / .dark → ThemeData
│
├── core/
│   ├── config/
│   │   └── env_config.dart       # [exists] add: wssUrl, mdnsServiceType, lanTimeout, mockMode
│   ├── constants/
│   │   ├── api_endpoints.dart    # path builders, no trailing slash; grouped by resource
│   │   ├── app_constants.dart    # timeouts, staleness windows, page sizes, keys
│   │   └── error_messages.dart   # user-facing copy keyed by Failure code (localized via ARB)
│   ├── error/
│   │   ├── failure.dart          # sealed Failure: Network, Timeout, Unauthorized, Forbidden,
│   │   │                         #   NotFound, Conflict, RateLimited, Server, Validation, Offline, StepUpRequired
│   │   ├── result.dart           # sealed Result<T> { Ok(value) | Err(failure) } + map/when/fold
│   │   └── exceptions.dart       # ApiException, CertificatePinException, CacheMissException
│   ├── network/
│   │   ├── dio_factory.dart      # builds cloud Dio + LAN Dio (separate instances)
│   │   ├── interceptors/
│   │   │   ├── auth_interceptor.dart          # inject Bearer; on 401 → single-flight refresh → retry
│   │   │   ├── idempotency_interceptor.dart   # add Idempotency-Key (uuid v4) to actuating POSTs
│   │   │   ├── error_interceptor.dart         # HTTP/DioException → Failure
│   │   │   ├── connectivity_interceptor.dart  # short-circuit to Failure.offline when no network
│   │   │   └── logging_interceptor.dart       # dev only; masks phone/tokens (§9)
│   │   ├── cert_pinning.dart     # SHA-256 DER fingerprint check for LanTransport
│   │   └── retry.dart            # exponential backoff policy (idempotent GET / 429 / 5xx)
│   ├── connectivity/
│   │   ├── connection_manager.dart   # the §2.3 state machine
│   │   ├── mdns_discovery.dart       # _ecotrack._tcp.local resolver (nsd/multicast_dns)
│   │   └── connection_state.dart     # enum + value object (mode, hubId, since, capability flags)
│   ├── sync/
│   │   ├── sync_engine.dart          # outbox drain, downlink pull, priority queue
│   │   ├── outbox_processor.dart     # per-kind handlers, backoff, expiry
│   │   ├── realtime_client.dart      # WSS multiplexer → event stream
│   │   └── background_worker.dart    # workmanager callback dispatcher
│   ├── auth/
│   │   ├── token_store.dart          # access in-memory; refresh in flutter_secure_storage
│   │   ├── session_manager.dart      # refresh scheduling, rotation, revoke-all handling
│   │   └── step_up_controller.dart   # 2-call initiate/verify; 300s elevation window
│   ├── utils/
│   │   ├── validators.dart           # phoneE164, otp6, email, kplcMeter, etc.
│   │   ├── formatters.dart           # KES (scale-6→2dp), kWh/W, dates (Africa/Nairobi), relative time
│   │   ├── schedule_window.dart      # SHARED wrap semantics: contains(DateTime), next transition
│   │   ├── energy.dart               # max(cum)-min(cum) with GREATEST(_,0) guard
│   │   └── debouncer.dart
│   └── extensions/
│       ├── context_extensions.dart   # theme/mediaQuery/l10n shortcuts, responsive breakpoints
│       ├── date_extensions.dart
│       └── result_extensions.dart
│
├── data/
│   ├── local/
│   │   ├── database/
│   │   │   ├── app_database.dart      # drift DB, schemaVersion, migrations
│   │   │   ├── tables/                # one file per table group (§5.1)
│   │   │   │   ├── identity_tables.dart      # users, sites, rooms, site_members
│   │   │   │   ├── device_tables.dart        # devices, device_current_state, appliances, bindings, health
│   │   │   │   ├── telemetry_tables.dart     # telemetry_samples (ring), rollup_hourly, cost_hourly
│   │   │   │   ├── automation_tables.dart    # modes, rules, schedules, overrides, budgets
│   │   │   │   ├── alert_tables.dart         # alert_definitions, alert_events
│   │   │   │   ├── tariff_tables.dart        # tariff_schedule_cache, band/levy json, billing_period
│   │   │   │   ├── sync_tables.dart          # outbox, cmd_queue, cmd_dedup, sync_meta
│   │   │   │   └── account_tables.dart       # preferences, consents, subscription_cache, hub_cache
│   │   │   └── daos/                  # DeviceDao, SiteDao, TelemetryDao, AutomationDao, AlertDao,
│   │   │       └── ...                #   TariffDao, SyncDao, AccountDao — watch* + upsert* methods
│   │   └── preferences/
│   │       ├── secure_storage.dart    # refresh token, hub cert fingerprints, biometric flag
│   │       └── app_preferences.dart   # device-side connection prefs (§13.1), theme, locale, onboarding
│   ├── remote/
│   │   ├── mock/
│   │   │   ├── mock_server.dart       # in-proc mock for Tier B (toggled by EnvConfig.mockMode)
│   │   │   └── fixtures/              # canned JSON matching System_Design §8 shapes
│   │   ├── api/
│   │   │   ├── auth_api.dart          # Tier A
│   │   │   ├── me_api.dart            # Tier A
│   │   │   ├── sites_api.dart         # Tier A
│   │   │   ├── rooms_api.dart         # Tier A
│   │   │   ├── members_api.dart       # Tier A
│   │   │   ├── audit_api.dart         # Tier A
│   │   │   ├── devices_api.dart       # Tier B (contract-first)
│   │   │   ├── telemetry_api.dart     # Tier B
│   │   │   ├── cost_api.dart          # Tier B
│   │   │   ├── automation_api.dart    # Tier B
│   │   │   ├── alerts_api.dart        # Tier B
│   │   │   ├── tariff_api.dart        # Tier B
│   │   │   ├── hubs_api.dart          # Tier B
│   │   │   ├── subscription_api.dart  # Tier B
│   │   │   └── account_api.dart       # Tier B (preferences, consents, push-tokens, data-export/erasure)
│   │   ├── lan/
│   │   │   ├── lan_api.dart           # /local/v1 endpoints
│   │   │   └── lan_pairing.dart       # POST /pair, local bearer token
│   │   └── dto/                       # freezed + json_serializable; *_dto.dart per resource
│   └── repositories/                  # impls: AuthRepositoryImpl, SiteRepositoryImpl, DeviceRepositoryImpl, ...
│       └── ...                        #   compose (dao + api + connectionManager + syncDao)
│
├── domain/
│   ├── entities/                      # plain immutable: User, Site, Room, Member, Device, Appliance,
│   │   └── ...                        #   Telemetry, CostBreakdown, Mode, Rule, Schedule, Budget,
│   │                                  #   AlertEvent, Tariff, Subscription, Hub, Preferences, Consent
│   ├── value_objects/                 # PhoneNumber, Money (KES, scale-6), Energy, Percentage, ScheduleWindow
│   ├── repositories/                  # abstract interfaces, one per aggregate
│   └── usecases/                      # only where orchestration is real (§2.1): RequestOtp, VerifyOtp,
│       └── ...                        #   RefreshSession, SendDeviceCommand, ActivateMode, AcknowledgeAlert,
│                                      #   ResolveConnection, DrainOutbox, GrantConsent, RequestDataExport
│
├── features/
│   ├── auth/            presentation/{bloc,pages,widgets}   # Login, OtpVerify
│   ├── connectivity/    presentation/{bloc,widgets}         # ConnectionStatusIndicator + banner
│   ├── shell/           presentation/{bloc,pages,widgets}   # RootShell: bottom-nav (mobile) / sidebar (web)
│   ├── home/            presentation/{bloc,pages,widgets}   # Tenant dashboard
│   ├── devices/         presentation/{bloc,pages,widgets}   # list, detail, pairing
│   ├── insights/        presentation/{bloc,pages,widgets}
│   ├── automation/      presentation/{bloc,pages,widgets}   # modes, schedules, rules, budgets
│   ├── alerts/          presentation/{bloc,pages,widgets}
│   ├── account/         presentation/{bloc,pages,widgets}   # profile, sites, members, sessions,
│   │                                                        #   preferences, privacy/consents, subscription, hub
│   ├── building_manager/ presentation/{bloc,pages,widgets}  # building dashboard, units, unit detail, billing, maintenance
│   └── super_admin/    presentation/{bloc,pages,widgets}    # web-only in v1
│
├── shared/
│   └── widgets/                       # the 15 reusable components (§7.4)
│
└── injection/
    ├── injection.dart                 # configureDependencies() — get_it + injectable
    └── injection.config.dart          # generated
```

```
test/
├── unit/         core utils (schedule_window vectors, formatters, energy), blocs, repositories (mocked)
├── widget/       critical screens: Login, OtpVerify, Home, DeviceDetail, ConnectionStatusIndicator
├── integration/  auth flow, offline queue→drain, LAN↔cloud failover
└── helpers/      pump helpers, fake DI container, fixture loaders
```

---

## 4. Dependencies (`pubspec.yaml`)

Keep the existing `flutter_dotenv`. Add:

| Package | Purpose | Notes / alternatives considered |
|---------|---------|--------------------------------|
| `flutter_bloc`, `bloc` | state management | mandated |
| `bloc_concurrency` | event transformers (droppable OTP, restartable search) | |
| `get_it`, `injectable` + `injectable_generator` | DI | vs manual — codegen wins at this size |
| `go_router` | routing | mandated in the brief's structure |
| `dio` | HTTP | mandated |
| `drift`, `drift_flutter` + `drift_dev` | local DB, **web-capable** | vs `sqflite` (no real web), `isar` (maintenance risk) |
| `sqlite3_flutter_libs` / `sqlite3` wasm asset | drift native + web backends | |
| `flutter_secure_storage` | refresh token, cert fingerprints | |
| `shared_preferences` | device connection prefs, theme, locale | |
| `freezed` + `freezed_annotation`, `json_serializable`, `json_annotation` | models/DTOs | |
| `connectivity_plus` | network transitions | detects transition only, not reachability — we still probe |
| `nsd` | mDNS `_ecotrack._tcp` discovery | vs `multicast_dns` (dart-native but flakier on Android); confirm platform matrix |
| `web_socket_channel` | realtime | |
| `workmanager` | periodic background sync | iOS constraints documented in code |
| `flutter_local_notifications` | sync status / local alert surfacing | |
| `fl_chart` | usage/cost/trend charts | mandated |
| `intl`, `flutter_localizations` | KES/date formatting, en + sw | |
| `uuid` | Idempotency-Key | |
| `local_auth` | optional biometric unlock | |
| `shimmer` | `LoadingShimmer` | or hand-rolled |
| `equatable` | value equality where not using freezed | |
| dev: `bloc_test`, `mocktail`, `build_runner`, `custom_lint`, `drift_dev` | tests + codegen | |

**Deliberately NOT included:** `firebase_*`, `google_analytics`, `sentry`, `mixpanel`, any ad SDK,
any social-login SDK. See §9. FCM for push is Tier B and gated on a consent decision — when added
it'll be `firebase_messaging` only, no Analytics.

---

## 5. Data layer detail

### 5.1 Local database (drift)

The app cache is **not** a copy of the cloud schema. It's shaped like the **edge SQLite store**
(`Database_Design` Part 2) plus the cloud entities the UI lists. Integer/text keys, bounded.

| App table | Mirrors | Notes |
|-----------|---------|-------|
| `users`, `sites`, `rooms`, `site_members` | cloud 1.1 | Tier A; full CRUD cache |
| `devices`, `device_current_state` | cloud 1.3 / edge `device_cache`, `local_state` | `reachable` distinct from `off` |
| `appliances`, `appliance_bindings` | cloud 1.3 | binding = interval rows, never mutate |
| `telemetry_samples` | edge `samples` — **ring buffer**, capped by row count + age | eviction: oldest first |
| `rollup_hourly` | edge `rollup_hourly` — never evicted | drives 24h/7d/30d charts offline |
| `cost_hourly_cache` | cloud `cost_hourly` | carries `is_estimated` + reason → UI badge |
| `modes`, `rules`, `schedules`, `overrides`, `budgets` | cloud 1.6 / edge caches | `schedules` stores `start_min`/`end_min` (minutes since midnight), wrap when `start > end` |
| `alert_definitions`, `alert_events` | cloud 1.7 | events are intervals (`opened_at`/`closed_at`), dedup by `dedup_key` |
| `tariff_cache` | edge `tariff_cache` | bands/levies JSON — enough to show KES offline (advisory) |
| `billing_period` | edge `period_state` | one `is_current` |
| `preferences`, `consents`, `subscription_cache`, `hub_cache` | cloud 1.7 / 1.8 / 1.3 | |
| `outbox` | edge `outbox` | `seq, kind, payload, priority, attempts, next_try_at, last_error` |
| `cmd_queue`, `cmd_dedup` | edge 2.4 | idempotency + expiry |
| `sync_meta` | — | `key → last_synced_at, etag/cursor` for staleness |

Migrations: drift `MigrationStrategy`, `schemaVersion` bumped per change, a generated schema-dump
test guards accidental breaking changes.

### 5.2 What goes where

| Store | Contents | Why |
|-------|----------|-----|
| memory (`TokenStore`) | access JWT | never persisted; 15-min TTL |
| `flutter_secure_storage` | refresh JWT, per-hub cert SHA-256 fingerprints, `biometricEnabled` | Keychain / Keystore-backed |
| `shared_preferences` | preferred transport, LAN timeout, discovery mode, theme mode, locale, last site id, onboarding-seen | device-scoped, non-secret, `System_Design §13.1`: connection prefs are per-install, **not** server-side |
| drift | everything else (domain cache + sync queues) | queryable, streamable, survives restart |

### 5.3 Dio interceptor stack (order matters)

**Request:** `connectivity` → `auth` (add Bearer) → `idempotency` (actuating POSTs) → `logging`.
**Response/Error:** `logging` → `error` (→ `Failure`) → `auth` (401 → single-flight refresh via a
`Completer` lock, replay queued requests, or bubble `Unauthorized` → force logout) → `retry`
(idempotent + 429/5xx, capped exponential backoff with jitter).

Two Dio instances: **cloud** (baseUrl from `EnvConfig`, full stack) and **LAN** (baseUrl set at
runtime from mDNS, adds `cert_pinning`, local bearer token instead of JWT, no refresh interceptor).

### 5.4 Certificate pinning (LAN)

On pairing, `GET /v1/hubs/{id}/connection` (Tier B) returns `cert_fingerprint` → store in secure
storage keyed by `hubId`. `LanTransport`'s `HttpClient.badCertificateCallback` computes
`sha256(DER)` of the presented leaf and compares constant-time. Mismatch ⇒ `CertificatePinException`
⇒ ConnectionManager drops to CLOUD and raises a `security` alert. Web: LAN disabled entirely
(`System_Design §13.2`).

### 5.5 Mapping & errors

- DTO (`data/remote/dto`) ⇄ entity (`domain/entities`) via explicit `toDomain()` / mappers — no
  freezed model shared across layers.
- HTTP status → `Failure`: 400→`Validation(fieldErrors)`, 401→`Unauthorized`, 403→`Forbidden`,
  404→`NotFound`, 409→`Conflict(reason)` (e.g. critical-appliance shed), 429→`RateLimited(retryAfter)`,
  5xx→`Server`, `DioException.connectionError/timeout`→`Network`/`Timeout`,
  no-connectivity→`Offline`, corekit `STEP_UP_REQUIRED`→`StepUpRequired`.

---

## 6. Domain layer conventions

- Entities are immutable (`freezed`), Flutter-free, no JSON.
- `Money` value object stores minor-unit-free `Decimal` at scale 6; `.display()` rounds to 2dp;
  carries `isEstimated`. All KES rendering goes through it.
- `ScheduleWindow` value object encapsulates wrap semantics; **one implementation**, reused by
  schedules, `time_between` rule conditions, and quiet hours (`System_Design §7`).
- Repository interfaces return `Stream<Result<T>>` for reads, `Future<Result<Unit>>` for writes.
- Use cases are `class X { Future<Result<T>> call(Params p) }`; registered in DI; called by Blocs.

---

## 7. Presentation layer

### 7.1 BLoC inventory

| Bloc | Scope | Key events | Key states | Depends on |
|------|-------|-----------|-----------|-----------|
| `ConnectivityBloc` | app (global) | `_ConnChanged`, `LanProbeRequested`, `TransportPreferenceChanged` | `Lan / Cloud / CloudHubOffline / Offline` (+ hubId, since) | `ConnectionManager` |
| `AuthBloc` | app (global) | `OtpRequested`, `OtpResent`, `OtpSubmitted`, `SessionRefreshed`, `LoggedOut`, `RevokeAllRequested` | `Unauthenticated / OtpPending(maskedTarget,resendIn) / Authenticating / Authenticated(user,persona) / AuthFailure` | `RequestOtp`, `VerifyOtp`, `SessionManager`, `SiteRepository` |
| `SessionsBloc` | account | `LoadSessions`, `RevokeSession` | `loading/loaded(list,currentId)/error` | `AuthRepository` |
| `StepUpCubit` | ephemeral (per sensitive action) | `initiate`, `submitCode` | `idle/pending/elevated/failed` | `StepUpController` |
| `SiteBloc` | app | `LoadSites`, `SelectSite`, `CreateSite`, `UpdateSite` | `loading/loaded(sites,selectedId)/error` | `SiteRepository` |
| `RoomsBloc` | per site | CRUD events | list state | `RoomRepository` |
| `MembersBloc` | per site | `Load`, `Invite`, `ChangeRole`, `Remove(stepUpToken)` | list + per-row status | `MemberRepository`, `StepUpCubit` |
| `HomeDashboardBloc` | home tab | `Subscribe(siteId)`, `ModeSelected`, `QuickToggle(deviceId)` | `loaded(liveUsage, dailyKwh, dailyKes(estimated), activeMode, quickControls, unreadAlerts)` | Telemetry/Cost/Automation/Device/Alert repos |
| `DeviceListBloc` | devices tab | `Subscribe`, `FilterChanged`, `SearchChanged` | grouped-by-room list | `DeviceRepository` |
| `DeviceDetailBloc` | device screen | `Subscribe(id)`, `TogglePower`, `SetOverride(ttl)`, `RangeChanged` | detail + chart series | `DeviceRepository`, `TelemetryRepository` |
| `PairingBloc` | add-device flow | `StartPairing`, `_CommissioningEvent` | `discovering/interviewing/joined/configured/failed` | `DeviceRepository` (LAN + realtime) |
| `InsightBloc` | insights tab | `Subscribe`, `PeriodChanged` | top-consumers, cost breakdown, trend, recommendations | `CostRepository`, `InsightRepository` |
| `AutomationBloc` | automation tab | mode/schedule/rule/budget CRUD, `TestRule` | sectioned state | `AutomationRepository` |
| `AlertBloc` | alerts tab + banner | `Subscribe`, `TabChanged`, `Acknowledge` | open/ack/closed lists | `AlertRepository` |
| `AccountBloc` | account tab | `Load`, `UpdateProfile`, `TogglePref`, ... | composite | `AccountRepository` |
| `ConsentBloc` | privacy screen | `Load`, `SetConsent(purpose,granted)`, `RequestExport`, `RequestErasure(stepUp)` | per-purpose toggles + request status | `AccountRepository`, `StepUpCubit` |
| `SubscriptionBloc` | account | `Load`, `ChangePlan(stepUp)`, `Cancel` | plan + resolved entitlement | `SubscriptionRepository` |
| `TariffBloc` | insights/account | `Load(siteId)` | schedule, bands, levies, band position | `TariffRepository` |
| `SyncBloc` | app | `SyncRequested`, `_OutboxChanged` | `idle/syncing(pending)/error`, per-item statuses | `SyncEngine` |
| **Manager:** `BuildingDashboardBloc`, `UnitsBloc`, `UnitDetailBloc`, `BillingBloc`, `MaintenanceBloc` | manager area | | | manager repos (Tier B) |
| **Admin (web):** `PlatformDashboardBloc`, `TenantAdminBloc`, `TariffAdminBloc`, `SystemConfigBloc`, `FirmwareBloc`, `ComplianceBloc` | web only | | | admin repos (Tier B) |

Global blocs provided above `MaterialApp` in `app.dart`; feature blocs via `BlocProvider` at route
level in `router.dart`; ephemeral cubits at widget level.

### 7.2 Routing (`go_router`)

```
/                         → redirect: unauth→/login ; auth→/home (or /manager, /admin by persona)
/login                    LoginPage
/login/otp                OtpVerifyPage         (extra: maskedTarget, pendingToken)
/onboarding/site          FirstSitePage         (if authed & zero sites)

ShellRoute (RootShell: bottom nav mobile / sidebar web)
  /home                   HomeDashboardPage
  /devices                DeviceListPage
  /devices/:id            DeviceDetailPage
  /devices/add            PairingPage
  /insights               InsightsPage
  /automation             AutomationPage
  /automation/schedule/:id  ScheduleEditorPage
  /automation/rule/:id      RuleEditorPage
  /alerts                 AlertsPage
  /account                AccountPage
  /account/sites          SitesPage
  /account/sites/:id/members  MembersPage
  /account/sessions       SessionsPage
  /account/preferences    PreferencesPage
  /account/privacy        PrivacyConsentsPage
  /account/subscription   SubscriptionPage
  /account/hub            HubStatusPage

ShellRoute (ManagerShell)      /manager, /manager/units, /manager/units/:id, /manager/billing, /manager/maintenance
ShellRoute (AdminShell, web)   /admin, /admin/tenants, /admin/tenants/:id, /admin/tariffs, /admin/system, /admin/firmware, /admin/compliance
```

Guards via `redirect` + a `Listenable` refreshing on `AuthBloc`/`ConnectivityBloc`. Deep-link
capable routes are string-addressable. `StepUpRequired` failures push a modal route, not a page.

### 7.3 Theme system

`EcoColors` — from the brief's palette, expressed as light + dark tokens:

| Token | Light | Role |
|-------|-------|------|
| `primary` | `#1A8A4F` | brand green |
| `secondary` | `#3498DB` | info blue |
| `success` | `#2ECC71` | + `lanMode` |
| `warning` | `#F39C12` | warning alerts |
| `error` | `#E74C3C` | + `offlineMode` |
| `info` / `cloudMode` | `#3498DB` | |
| `background` | `#F8F9FA` | scaffold |
| `surface` | `#FFFFFF` | cards |
| `textPrimary` | `#1A1A2E` | |
| `textSecondary` | `#6B7280` | |
| `cardShadow` | `rgba(0,0,0,0.08)` | elevation |

Dark palette: derived, not guessed — `background #12121A`, `surface #1E1E2E`, text inverted,
brand/semantic hues nudged for contrast. **Every pairing must meet WCAG AA (4.5:1 text, 3:1 large)** —
enforced by a unit test over the token table (§9). `EcoTypography` = a type scale on the system
font with an explicit fallback stack. `AppTheme` maps tokens → `ThemeData` (Material 3),
`ColorScheme`, component themes. Theme mode from `AppPreferences`, default `system`.

### 7.4 Reusable widgets (`shared/widgets/`)

`ConnectionStatusIndicator`, `ModeButton`, `DeviceCard`, `AlertCard`, `UsageChart` (fl_chart
wrapper), `EcoProgressIndicator` (linear/circular + %), `CostBreakdownCard`, `LoadingShimmer`,
`EmptyState`, `ErrorState` (message + retry), `EcoSearchBar` (debounced), `FilterTabs`,
`EcoBottomNav` / `EcoNavRail` (responsive), `SiteSelector`, `PullToRefresh`. Each: documented
constructor contract, `Semantics` labels, golden test.

---

## 8. Cross-cutting concerns

### 8.1 Auth & session lifecycle

```
Login: enter +254 phone → POST /auth/otp/request → {pending_token, masked_target, expires_in:300}
       → /login/otp, start 45s resend timer
Verify: 6-digit → POST /auth/otp/verify {pending_token, code, device_name}
       → {access, refresh}
       → TokenStore.setAccess(access) ; SecureStorage.write(refresh)
       → decode refresh_jti ; SessionManager.scheduleRefresh(access.exp - 60s)
       → GET /me → derive UserPersona (§1.3) → AuthBloc: Authenticated
       → SiteBloc.LoadSites → if zero → /onboarding/site
Refresh: on timer OR on 401 → POST /auth/refresh {refresh} (single-flight Completer lock)
       → rotate both tokens ; persist new refresh ; replay queued 401'd requests
       → on invalid/revoked → wipe → AuthBloc: Unauthenticated → /login
Logout: POST /auth/logout {refresh} → wipe stores → clear drift PII tables → reset DI scopes
Revoke-all: POST /auth/sessions/revoke-all → same local wipe
```

`device_name` = `<brand> <model>` via `device_info_plus` (add) or a stable fallback.

### 8.2 Step-up (2-call, corekit)

Sensitive actions (member removal, subscription change, hub unclaim, data erasure): `StepUpCubit`
→ `POST /auth/step-up/initiate` → OTP modal → `POST /auth/step-up/verify {pending_token, code}` →
session elevated 300s server-side → retry the original call. If it still 403s with
`STEP_UP_REQUIRED`, surface "please retry — verification expired".

### 8.3 Idempotency

`idempotency_interceptor` adds `Idempotency-Key: <uuidv4>` to any `POST` matching an allowlist of
actuating paths (`/devices/*/commands`, `/modes/*/activate`, `/local/v1/devices/*/command`). The
**same key** is persisted with the `outbox`/`cmd_queue` row so a retry — or the same command over
LAN and cloud — reuses it. Backend `cmd_dedup` / `commands UNIQUE(hub_id, idempotency_key)` makes
it a no-op.

### 8.4 Money & units

Store scale-6, round at display only (`Database_Design §0/§1.5`). `Money.display()` → `KES 1,234.56`.
Never sum rounded values. Show an "≈ estimated" badge whenever `is_estimated` (prepaid band
assignment is unresolved backend-side — `Open Questions §3.1`). Units per `user_preferences.units_display`
(`kwh` / `kes` / `kwh_and_kes`).

### 8.5 Schedule wrap semantics (shared, test-locked)

`ScheduleWindow(startMin, endMin, daysMask)`:
- `start < end` → same-day `[start, end)`
- `start > end` → `[start, 1440) ∪ [0, end)`, `daysMask` = **start** day
- `start == end` → rejected at construction (`ArgumentError`)

Test vectors checked into `test/unit/schedule_window_test.dart` (Mon 22:00→06:00 active Tue 05:59,
inactive Tue 06:00, etc.) — mirrors the backend's shared suite intent (`System_Design §7`).

### 8.6 Energy

`energy(samples) = max(0, max(cum) - min(cum))` over the window. Dropped samples cost resolution,
not totals. Exclude `clock_conf < 2` rows.

### 8.7 Connection indicator

Always mounted in the shell app bar. `ConnectivityBloc` state → colour + label + tap target:
green "On home network", blue "Remote", blue-muted "Hub offline — controls unavailable", red
"Offline — showing saved data (updated 12m ago)".

### 8.8 Error-handling matrix

| Failure | UI |
|---------|----|
| `Validation` | inline field errors; focus first invalid |
| `Unauthorized` | silent refresh; if that fails → toast + /login |
| `Forbidden` (no step-up) | "You don't have permission" |
| `StepUpRequired` | step-up modal, then retry |
| `NotFound` | friendly empty/removed message |
| `Conflict` | show reason (e.g. "Fridge is marked critical and can't be switched off automatically") |
| `RateLimited` | "Too many attempts. Try again in {retryAfter}s" + disable action |
| `Server` | "Something went wrong" + retry |
| `Network` / `Timeout` | retry w/ backoff; then cached data + banner |
| `Offline` | switch to cache, queue writes, "Queued" chips |

---

## 9. In-app compliance (Kenya DPA 2019) & accessibility

Scope per your answer: **in-app only**, no marketing-site work.

**Privacy & consent**
- `/account/privacy` (`PrivacyConsentsPage`): per-purpose toggles bound to `consent_records`
  purposes — `service_delivery` (required, non-toggle), `occupancy_analytics`,
  `nilm_disaggregation`, `marketing`, `research_aggregate`, `third_party_sharing`. Each write →
  `PUT /me/consents/{purpose}` (Tier B) with evidence `{method:'app_toggle', app_version, ts}`.
- **Consent-gated forms:** any screen that collects data beyond what a feature strictly needs
  carries an explicit, unticked consent checkbox with a link to the policy; submit disabled until
  ticked. Data-minimisation: forms collect only fields the endpoint requires (e.g. login = phone
  only; profile = display name + locale, matching `PATCH /me`).
- **Data rights:** `/account/privacy` exposes "Download my data" (`GET /me/data-export`) and
  "Delete my account" (`POST /me/data-erasure`, **step-up required**). Both Tier B — until the
  endpoints exist the buttons show a "we'll email you within 30 days" flow + audit note.
- **Policy docs:** ship `Privacy Policy` and `Terms` as in-app scrollable screens
  (`assets/legal/*.md` rendered), versioned; `policy_version` recorded with each consent.
  No cookie banner (native app, no cookies); the web dashboard, being cloud-only Flutter with
  no third-party embeds and no analytics, also sets no non-essential cookies — a short
  "essential cookies only" notice on first web load is included.

**Tracking / third parties**
- **No analytics, crash, ads, or social SDKs in v1.** If product later wants product analytics it
  must be opt-in, tied to the `occupancy_analytics`/`marketing` consents, and self-hosted or
  DPA-compliant. `bootstrap.dart` has empty `FlutterError.onError` / zone handlers as the only
  hook.
- **No third-party embeds / web views.** All UI is native Flutter (brief constraint #3).
- **Log masking:** `logging_interceptor` redacts `phone_e164`, OTP codes, tokens, `Authorization`;
  release builds disable request/response logging entirely. Mirrors `data_classification.mask_in_logs`.

**Accessibility (mobile + web)**
- Every icon-only control and image has a `Semantics(label:)` / `tooltip`; decorative images
  `ExcludeSemantics`. Chart widgets expose a text summary alternative.
- Colour-contrast unit test over `EcoColors` token pairs (WCAG AA); status is never conveyed by
  colour alone (icon + text on the connection indicator, alert cards, device state).
- Web forms: logical `FocusTraversalOrder`, visible focus rings, Enter-to-submit, all actions
  reachable without a pointer.
- Buttons use clear verb labels ("Send code", "Verify", "Acknowledge alert", "Download my data") —
  no bare "OK"/"Submit" where a specific label fits.
- Minimum 48dp touch targets; text scales with system font size; `MediaQuery.textScaler` respected.

**Content honesty** (from your note): no testimonials/review UI ships without a real data source;
no efficiency/savings claim is shown as fact — savings figures are always labelled estimates with
methodology, consistent with the `is_estimated` rule.

---

## 10. Web dashboard

- **Same project**, `flutter run -d chrome --flavor …` (web has no flavors natively — handled via
  `--dart-define=FLAVOR=` read in `bootstrap`).
- **Cloud transport only.** `ConnectionManager` on web skips mDNS/LAN entirely (`System_Design §13.2`)
  — states collapse to `Cloud / CloudHubOffline / Offline`.
- Responsive: `context.breakpoint` (`compact <600`, `medium <1024`, `expanded ≥1024`). `RootShell`
  swaps `EcoBottomNav` → `EcoNavRail` → persistent sidebar. Data-dense screens (unit performance
  table, tenant list, audit log, tariff bands) get real `DataTable2` layouts on `expanded`.
- Web-only surface: full Super-Admin area (§7.2 AdminShell), richer rule editor, CSV export
  triggers (`GET /exports/csv` → signed URL → browser download).
- drift on web = `sqlite3.wasm` + a shared web worker; offline cache still works, background sync
  does not (no `workmanager` on web — falls back to foreground poll + focus/visibility events).

---

## 11. Integration with the existing DevOps shell

Already in the repo (keep): `bootstrap.dart`, `main_*.dart`, `core/config/env_config.dart`,
`android/app/build.gradle` flavors, `ios/Flutter/*.xcconfig`, Fastlane, CI, `analysis_options.yaml`,
`Makefile`.

Changes:
- `bootstrap.dart`: after `EnvConfig.initFromDotenv`, call
  `await configureDependencies(env)` (get_it), then `runApp`. Register `AppDatabase`,
  Dio instances, `ConnectionManager`, repos as singletons; open the DB; kick a first sync.
- `EnvConfig`: add `wssUrl`, `mdnsServiceType` (`_ecotrack._tcp`), `lanProbeTimeout`,
  `mockMode` (bool), `policyVersion`. Update the baked-in defaults from `api.ecotrack.app` →
  `api.ecotrack.co.ke` (dev/staging get their own hosts).
- `.env.example`: add the new keys.
- `lib/app.dart` → `lib/app/app.dart` (update the 4 entrypoints' import).
- New `--dart-define=FLAVOR=` path for web builds; `Makefile` targets `run-web-dev` etc.
- CI `ci.yml`: add `build_runner` step before analyze/test; add a `flutter build web` smoke job.

---

## 12. Testing strategy

| Layer | What | Tooling |
|-------|------|---------|
| Unit | `ScheduleWindow` vectors, `Money`/formatters, `energy()`, `Failure` mapping, interceptor logic, `ConnectionManager` transitions, every Bloc | `bloc_test`, `mocktail` |
| Repository | cache-first behaviour, staleness, outbox enqueue/drain, conflict drop | in-memory drift, fake API |
| Widget | Login, OtpVerify (keypad, resend timer), Home, DeviceDetail toggle, ConnectionStatusIndicator states, EmptyState/ErrorState | `flutter_test` |
| Golden | the 15 shared widgets, light + dark | `flutter_test` goldens |
| Integration | OTP login end-to-end (mock), offline queue → reconnect → drain, LAN→cloud failover, step-up flow | `integration_test` |
| A11y | contrast token test; `meets guideline` semantics tests on key screens | `flutter_test` a11y matchers |

Target: 100% on `core/utils` + `core/error` + Blocs; critical-path widget coverage; CI gate on
`flutter analyze` clean + tests green + `dart format` check (already in `ci.yml`).

---

## 13. Phased delivery plan

Mapped from the brief's 67 steps, regrouped by dependency and PR-sized. **"Now"** = Tier A or
pure-client. **"Mock"** = build against `System_Design §8` contract + mock server. **"Backend"** =
blocked until that endpoint ships.

| Phase | PRs | Contents | Gate |
|-------|-----|----------|------|
| **0. Unblock** ✅ | P0 | ~~Fix toolchain. `flutter create .`. Wire DevOps shell.~~ Done — `pub get` / `analyze` / `test` / `build web` green. `build_runner` in CI still to add in P1. | ✅ app builds |
| **1. Foundation** ✅ | P1–P3 | Done (commit 1531ab1): pubspec; `app/themes/*`; `core/error` (sealed Failure+Result), `core/constants` (full §8 ApiPaths), `core/utils` (+ 69 tests); `injection/` (get_it+injectable); `app/router.dart` route-constants + factory skeleton; `AppDatabase` (sync + identity tables) + `SyncDao` + DB test; `SecureStorage` / `AppPreferences`. **Deferred:** remaining drift table groups, migration-version harness, router↔AuthBloc wiring (needs Phase 3). | ✅ analyze clean, DB tests green |
| **3. Auth** ✅ · **4. Tenancy** ✅ · **5. Tenant screens** ✅ · **6. Offline** ✅ (partial) | — | Auth (Login/OTP, SessionManager, step-up). Tenancy (Sites/Members/Sessions/Account, cache-first). Tenant screens: Home dashboard, Devices+detail+pairing, Insights (fl_chart), Automation, Alerts — all Tier-B via `MockInterceptor`. Offline: `DeviceRepository` cache-first + outbox-backed commands + sync banner. **Deferred:** LAN transport wiring + cert-pin storage + telemetry caching (need a hub); Insights charts are basic. 103 tests, analyze clean, web+native. |
| ~~**2. Core infra**~~ ✅ | P4–P6 | Done (commit fdcd91a): `dio_factory` + interceptor stack (auth/idempotency/connectivity/logging/retry) + `error_mapper` (+ tests); `TokenStore` (+ tests); `ConnectionManager` + `mdns_discovery` + 4-mode state machine; `SyncEngine` + `OutboxProcessor` + `RealtimeClient` + `workmanager` stub; `ApiClient` + `CacheFirstRepository` base; drift connection split native/web. **Deferred:** `ConnectivityBloc` widget (Phase 3, needs a UI host), web-conditional guards for the LAN layer (Phase 9). | ✅ analyze clean, 84 tests, web+native build |
| **3. Auth (Tier A)** | P7–P9 | `auth_api`, `me_api`; `TokenStore`, `SessionManager`, `StepUpController`; `AuthBloc`, `SessionsBloc`, `StepUpCubit`; Login + OtpVerify screens + keypad + resend timer; persona derivation; DI/drift wipe on logout. | integration: login→/me→home |
| **4. Tenancy (Tier A)** | P10–P12 | `sites/rooms/members/audit` APIs + repos + DAOs; `SiteBloc`, `RoomsBloc`, `MembersBloc`; Sites, Members (w/ step-up remove), first-site onboarding; Account screen scaffold + profile edit + Sessions + Audit viewer. | full offline CRUD on sites/rooms |
| **5. Tenant core (Mock)** | P13–P18 | mock server + fixtures; Home dashboard, Devices list + detail + pairing, Insights, Automation (modes/schedules/rules/budgets), Alerts; `TariffBloc`; all Tier-B repos with real drift cache. | screens work against mock, offline-capable |
| **6. Offline hardening** | P19–P20 | LAN transport + cert pinning + `/local/v1`; failover tests; outbox retry/expiry; background sync polish; "queued/failed" UX; conflict handling. | airplane-mode test suite green |
| **7. Compliance & a11y** | P21 | Privacy/Consents screen, consent-gated forms, data export/erasure flow, legal doc screens, log masking, contrast test, semantics pass, keyboard/focus for web. | a11y + contrast tests green |
| **8. Manager (Mock)** | P22–P25 | Building dashboard, Units, Unit detail, Billing, Maintenance; manager persona routing. | |
| **9. Web dashboard** | P26–P29 | responsive shell, `--dart-define` flavor, drift-web, Super-Admin area (platform dashboard, tenants, tariffs, system config, firmware, compliance), CSV export, data tables. | `flutter build web` smoke in CI |
| **10. Polish** | P30+ | localization en/sw, shimmer/empty/error everywhere, perf pass, edge cases, golden coverage, integration suite. | |

Backend-dependency register (raise as tickets): staff/persona claim on `/me`; org/RBAC model;
every Tier-B endpoint; `WSS /v1/stream`; local hub API; push-token + FCM; consent + data-rights
endpoints; pagination on list endpoints (or confirm arrays stay).

---

## 14. Open questions — need your answers before/early in Phase 1

| # | Question | Default if no answer |
|---|----------|---------------------|
| Q1 | Persona model (§1.3) — confirm: Tenant + Manager on mobile, Super-Admin web-only? Add `persona`/`is_staff` to `/me`? | proceed with the §1.3 proposal |
| Q2 | Tier-B approach (A2) — in-repo mock server + build-ahead, or freeze those screens until backend ships? | in-repo mock, build-ahead |
| Q3 | Self-signup: `otp/request` creates a tenant on unknown phone. Keep that, or require an invite/claim code first (wireframe says "Contact Building Manager")? | keep backend behaviour; soften the copy |
| Q4 | drift vs sqflite; `nsd` vs `multicast_dns` — any org preference / prior art? | drift + nsd |
| Q5 | Web dashboard priority — parallel with mobile, or strictly after Tenant v1? | after Tenant v1 (Phase 9) |
| Q6 | Languages: en + sw at launch, or en-only v1 with sw scaffolding? | en + sw scaffolding, sw strings incremental |
| Q7 | Push notifications: acceptable to add `firebase_messaging` (no Analytics) when Tier B lands, or must push be non-Firebase? | firebase_messaging, messaging-only |
| Q8 | Min platform versions — Android `minSdk` (shell has 23), iOS deployment target? | Android 23 / iOS 13 |
| Q9 | Design source of truth — is the UXPilot PDF final, or is a real design system / Figma coming? (affects whether we invest in goldens now) | treat PDF as directional, tokens from the brief |

---

## 15. Toolchain fix (B1) — do this first

```powershell
# 1. Decide which Flutter install to keep. Check both:
& "C:\Program Files\flutter\bin\flutter.bat" --version   # if this hangs, Ctrl-C
& "C:\Users\LINET\develop\flutter\bin\flutter.bat" --version

# 2. Remove the other from PATH (System Environment Variables → Path) and from any shell profile.
#    Keep ONE. Recommended: the one under your user dir (no admin needed for upgrades).

# 3. Clear a possibly-corrupt cache on the keeper:
Remove-Item -Recurse -Force "C:\Users\LINET\develop\flutter\bin\cache"

# 4. Re-bootstrap:
flutter --version
flutter precache
flutter doctor -v

# 5. If it still hangs: run Process Monitor / check for an antivirus lock on bin\cache\,
#    check `git` is on PATH and not prompting for credentials (Flutter shells out to git),
#    and confirm no proxy is silently swallowing the Dart SDK download.
```

Once `flutter doctor` returns, I run `flutter create .`, wire the DevOps shell, and start Phase 1.

---

## Appendix A — endpoint → screen coverage (abridged)

| Screen | Endpoints | Tier |
|--------|-----------|------|
| Login / OTP | `/auth/otp/request|resend|verify` | A |
| Home dashboard | `/telemetry/live`, `/costs/summary`, `/sites/{id}/modes`, `/devices`, `/alerts` | B |
| Devices / detail | `/devices`, `/devices/{id}`, `/devices/{id}/commands`, `/telemetry/series`, `/commands/{id}` | B |
| Pairing | `/hubs/{id}/pairing-mode`, `/devices/commissioning`, `WSS device.commissioning` | B |
| Insights | `/costs/breakdown`, `/costs/series`, `/tariffs/current`, `/insights` | B |
| Automation | `/sites/{id}/modes|rules|schedules|budgets`, `/rules/{id}/test` | B |
| Alerts | `/alerts`, `/alerts/{id}/acknowledge`, `/sites/{id}/alert-definitions` | B |
| Account · profile | `/me`, `PATCH /me` | A |
| Account · sites/members | `/sites`, `/sites/{id}/rooms`, `/sites/{id}/members` (+ step-up) | A |
| Account · sessions | `/auth/sessions`, `DELETE`/`revoke-all` | A |
| Account · preferences | `/me/preferences` | B |
| Account · privacy | `/me/consents`, `/me/data-export`, `/me/data-erasure` | B |
| Account · subscription | `/plans`, `/subscription`, `/subscription/change` (step-up) | B |
| Account · hub | `/hubs/{id}`, `/hubs/{id}/diagnostics`, `/hubs/{id}/connection` | B |
| Manager · all | building/units/billing/maintenance — no backend | B |
| Super-Admin · all | platform/tenants/tariffs/system/firmware/compliance + `/audit-log` (A) | mostly B |
| LAN mode (any) | `/local/v1/*` | B (separate service) |
```
