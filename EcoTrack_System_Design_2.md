# EcoTrack — System Design

**Version:** 1.0
**Supersedes:** v0.9
**Scope:** Architecture, technology stack, environments, sync protocol, API surface,
interface structure, operations
**Companion documents:** `EcoTrack_Database_Design.md`, `EcoTrack_Gap_Analysis_Validation.md`

---

## 0. Changes in v1.0

| Area | Change |
|---|---|
| Connectivity config | Split: per-site facts server-side, client preferences on device |
| API surface | Sessions, commissioning, firmware, mesh health, consent, notifications added |
| Rate limiting | Specified as Redis + middleware, not database state |
| Schedules | Overnight wrap semantics made normative and shared across cloud/edge |
| OTA | Edge schema version now gates config push and firmware rollout |
| Operations | Hub replacement / RMA flow added; backup policy specified |
| Compliance | Kenya DPA 2019 obligations section added |
| Security | Step-up verification replaces full MFA; CSRF scoped correctly |
| Open items | Free-tier remote access flagged as an unmade product decision |

---

## 1. Architecture overview

```
┌─────────────────────────────────────────────────────────────┐
│  APPLICATION LAYER                                          │
│  Mobile app (Android-first) · Web dashboard · Admin console │
└───────────────┬──────────────────────────┬──────────────────┘
                │ LAN (mDNS + pinned TLS)  │ HTTPS
                │                          │
                │              ┌───────────▼──────────────────┐
                │              │  CLOUD LAYER                 │
                │              │  API · MQTT broker · workers │
                │              │  PostgreSQL/TimescaleDB      │
                │              └───────────▲──────────────────┘
                │                          │ outbound mTLS
┌───────────────▼──────────────────────────┴──────────────────┐
│  EDGE LAYER — household hub (Linux SBC)                     │
│  Zigbee2MQTT · Mosquitto · ecotrack-edge daemon · SQLite    │
└───────────────┬─────────────────────────────────────────────┘
                │ Zigbee 3.0 mesh (802.15.4, 2.4 GHz)
┌───────────────▼─────────────────────────────────────────────┐
│  FIELD LAYER — smart plugs · lighting nodes · CT clamps     │
└─────────────────────────────────────────────────────────────┘
```

### Authority split

| Concern | Owner |
|---|---|
| Live device state, relay actuation | Hub |
| Rule and schedule **execution** | Hub |
| Local alert detection, offline buffering | Hub |
| Accounts, tenancy, billing | Cloud |
| Rule and schedule **definitions** | Cloud |
| Tariff schedules, cost of record | Cloud |
| Long-horizon analytics, NILM, OTA | Cloud |

This split removes most sync conflicts: the two sides never write the same field.

---

## 2. Field layer

**Radio: Zigbee 3.0 only.** The earlier hybrid proposal (433 MHz lighting + Zigbee plugs) is
superseded — 433 MHz lighting nodes as specified were transmit-only, which makes remote
control of lighting impossible and breaks the automation model. `System_Overview` still
describes the hybrid and should be updated before component procurement.

| Node type | Silicon | Function |
|---|---|---|
| Smart plug (custom) | ESP32-C6 / ESP32-H2 | Per-appliance metering + relay |
| Smart plug (COTS) | Tuya TS011F class | Same, sourced for volume |
| Lighting node | ESP32-C6 / ESP32-H2 | PIR occupancy, relay, manual override |
| Ceiling-rose relay | COTS Zigbee module | Retrofit lighting control |
| CT main | Zigbee energy meter + CT clamp | Whole-home consumption |

**Strategy:** exploit the Tuya hardware supply chain, reject the Tuya cloud. Devices pair
directly to the local Zigbee coordinator; no vendor cloud is in the path.

**Constraint:** Tuya OTA reflashing via `tuya-convert` is effectively non-functional on
current Beken BK7231 production hardware. COTS devices are used as-shipped over Zigbee;
custom firmware paths apply only to EcoTrack-built ESP32-C6/H2 nodes.

**Every relay-bearing node carries a physical manual override** wired so the user can always
take control. Override actuation is reported upstream and written to `overrides` — without
this the rules engine fights the occupant.

---

## 3. Edge layer

### Hardware

Linux SBC, not an ESP32. Determining factors: Zigbee2MQTT is Node.js and cannot run on
ESP32; queryable offline storage; concurrent TLS contexts; cellular fallback handling; and
field debuggability over SSH.

Candidates: Orange Pi Zero 2W, Raspberry Pi Zero 2 W, Luckfox Pico Max, Milk-V Duo 256M.
Selection pending measured footprint and Kenyan landed cost.

Supporting hardware: Zigbee coordinator dongle (CC2652/EFR32), battery backup so the hub
outlives grid outages, RTC, and a cellular modem for sites without fixed broadband.

### Software stack — Docker Compose

| Container | Role |
|---|---|
| `zigbee2mqtt` | Coordinator control, device converters, pairing |
| `mosquitto` | Local message bus |
| `ecotrack-edge` | Rules engine, aggregation, local API, sync outbox |

**`ecotrack-edge` is written in Go:** single static binary, small resident footprint, no
runtime to patch, and it survives SD-card and power-cut abuse better than a Python venv.

### Responsibilities

- Subscribe to `zigbee2mqtt/#`, resolve `ieee_addr → local_id`, apply calibration
- Write `samples`; close hourly buckets into `rollup_hourly`
- Sample mesh health every 15 minutes into `health_samples`
- Evaluate rules and schedules against local wall-clock time, honouring wrap semantics (§7)
- Detect edge-scope alerts (spike, offline, standby waste) with hysteresis
- Serve the local HTTP/WebSocket API over mDNS
- Maintain `cmd_queue`, `outbox`, and the mTLS uplink
- Run schema migrations at startup and refuse to operate on an unknown future schema (§9.3)

---

## 4. Cloud layer

| Component | Technology | Role |
|---|---|---|
| API service | Go, stateless behind load balancer | REST for apps |
| Device broker | EMQX or VerneMQ | mTLS MQTT for hubs |
| Primary DB | PostgreSQL 15 + TimescaleDB | System of record |
| Cache | Redis | Sessions, rate limits, OTP throttle, command dedup window |
| Object storage | S3-compatible | Signed OTA images, hub backups, CSV exports |
| Workers | Go, queue-driven | Cost, alerts, NILM, notifications, OTA |

### Worker jobs

- `cost-compute` — walks `billing_periods.kwh_accumulated` through `tariff_bands`, writes `cost_hourly`
- `tariff-refresh` — ingests gazetted KPLC changes as new `tariff_schedules` versions
- `alert-evaluate` — cloud-scope alerts (budget, CUSUM anomaly, cross-device patterns)
- `notify-dispatch` — push/SMS honouring quiet hours; writes `notification_deliveries`
- `mpesa-reconcile` — Daraja callbacks, token receipt parsing
- `nilm-infer` — disaggregation on `ct_main` series (paid tiers)
- `ota-orchestrate` — staged rollout by `fw_channel`, gated on `edge_schema_version`
- `cert-expiry-watch` — daily scan of `certificates.not_after`, alerts at 30 days
- `state-ingest` — updates `device_current_state` from the telemetry stream

Same language on both sides of the wire means DTOs, the rule grammar, and validation are a
shared package rather than two implementations that drift.

---

## 5. Environments

| Environment | Purpose |
|---|---|
| Local dev | Full stack in docker-compose on a laptop |
| **Device simulator** | Synthetic hub publishing realistic telemetry over MQTT |
| Staging | Real hardware, real certificates, disposable data |
| Production | Separate CA, separate broker cluster, separate DB |

The simulator is not optional. Without it, all backend and app work is blocked on soldering
— it decouples the software timeline from the hardware timeline, which matters directly to
the grant schedule.

Firmware and hub images move through `dev → beta → stable` channels so nothing untested
reaches a live household.

---

## 6. Sync protocol

### 6.1 Uplink (hub → cloud)

1. Hourly bucket closes; `rollup_hourly` row written with `synced = 0`
2. Row enqueued to `outbox` with a priority
3. Published QoS 1 to `ecotrack/v1/<hub_id>/telemetry`
4. Deleted from outbox only on broker ack
5. Cloud upserts `telemetry_hourly` on `(device_id, bucket)` — replay-safe
6. `cost-compute` runs for the affected site and window

Buffer pressure drops raw samples first; hourly rollups are never dropped. Outbox priority
ensures alerts and state changes drain ahead of bulk rollups after a long outage — otherwise
a critical notification arrives hours late behind a week of telemetry.

### 6.2 Downlink (cloud → hub)

1. A rule/schedule/tariff edit increments `hubs.config_version`
2. Full snapshot written to `hub_config_versions` with a SHA-256 hash and
   `min_edge_schema_version`
3. Cloud checks `hubs.edge_schema_version >= min_edge_schema_version`; if not, the push is
   withheld and the hub is queued for firmware update first
4. Published to `ecotrack/v1/<hub_id>/config`
5. Hub verifies hash, replaces `rules_cache` + `schedule_cache` in one transaction
6. Hub acks with `applied_version`

**Cloud version always wins.** No merge, no conflict resolution. A hub offline for a month
converges on reconnect.

### 6.3 Clock handling

RTC holds time across outages; NTP corrects on connectivity. Every record carries
`clock_conf` (0 = RTC only, 1 = drifted, 2 = NTP-synced). Data below confidence 2 is stored
but excluded from aggregates and cost, then reconciled once time is trusted. Skipping this
produces silent tariff-period misattribution that is painful to fix retroactively.

### 6.4 MQTT topic taxonomy

**Device bus (local, Mosquitto):**

```
zigbee2mqtt/<friendly_name>              # state
zigbee2mqtt/<friendly_name>/set          # command
zigbee2mqtt/bridge/event                 # join/leave/interview
zigbee2mqtt/bridge/devices               # inventory
```

**Cloud bus (mTLS, EMQX). ACLs scope each hub to its own namespace:**

```
# hub → cloud
ecotrack/v1/<hub_id>/telemetry
ecotrack/v1/<hub_id>/health
ecotrack/v1/<hub_id>/state
ecotrack/v1/<hub_id>/alerts
ecotrack/v1/<hub_id>/events
ecotrack/v1/<hub_id>/ack
ecotrack/v1/<hub_id>/heartbeat          # LWT set on this topic

# cloud → hub
ecotrack/v1/<hub_id>/cmd
ecotrack/v1/<hub_id>/config
ecotrack/v1/<hub_id>/ota
```

---

## 7. Schedule wrap semantics — normative

Shared by the cloud validator, the cloud rule tester, and the edge scheduler.

- A window where `start < end` is a same-day interval.
- A window where `start > end` **wraps past midnight**: `[start, 24:00) ∪ [00:00, end)`.
- `days_mask` selects the day the window **starts**. Monday 22:00 → 06:00 runs from Monday
  22:00 to Tuesday 06:00.
- `start == end` is rejected at write time as a degenerate zero-length window.

This applies identically to `schedules`, to `{"type":"time_between"}` conditions, and to
`user_preferences.quiet_hours_*`.

> A constraint of `start < end` would reject every overnight window, including Night mode.
> Divergence between the cloud and edge implementations of this rule is the most likely
> silent behavioural bug in the system; it belongs in the shared test suite, not in two
> separately written functions.

---

## 8. Cloud REST API

**Base:** `https://api.ecotrack.co.ke/v1`
**Auth:** phone OTP → JWT access (15 min) + refresh (30 d). `Authorization: Bearer <jwt>`
**Conventions:** cursor pagination (`?cursor=&limit=`), RFC 7807 problem+json errors,
`Idempotency-Key` required on all POSTs that actuate hardware.
**Monetary fields** are returned rounded to 2 decimals; storage is scale 6.

### 8.1 Auth, sessions, account

| Method | Path | Purpose |
|---|---|---|
| POST | `/auth/otp/request` | Send OTP to `phone_e164` (Redis-throttled per phone and IP) |
| POST | `/auth/otp/verify` | Exchange OTP for token pair; creates `auth_sessions` row |
| POST | `/auth/refresh` | Rotate access token; revokes prior `jti` |
| POST | `/auth/logout` | Revoke current session |
| GET | `/auth/sessions` | List active sessions (device, IP, last activity) |
| DELETE | `/auth/sessions/{session_id}` | Revoke one session |
| POST | `/auth/sessions/revoke-all` | Log out everywhere |
| POST | `/auth/step-up` | Re-verify by OTP for a high-consequence action |
| GET | `/me` | Current user + tenant + role |
| PATCH | `/me` | Update display name, locale |
| GET | `/me/preferences` | Read `user_preferences` |
| PUT | `/me/preferences` | Update preferences |
| GET | `/me/consents` | Consent state per purpose |
| PUT | `/me/consents/{purpose}` | Grant or withdraw; writes `consent_records` |
| POST | `/me/push-tokens` | Register FCM token |
| DELETE | `/me/push-tokens/{id}` | Deregister |
| GET | `/me/data-export` | DPA 2019 subject access request |
| POST | `/me/data-erasure` | Erasure request; step-up required |

**Step-up required for:** subscription change, member removal, ownership transfer, hub
unclaim, and installer actions on a site the installer does not own.

### 8.2 Sites, rooms, members

| Method | Path | Purpose |
|---|---|---|
| GET | `/sites` | List sites in tenant |
| POST | `/sites` | Create site |
| GET | `/sites/{site_id}` | Detail incl. meter and connectivity config |
| PATCH | `/sites/{site_id}` | Update label, tariff code, meter no., status |
| GET | `/sites/{site_id}/rooms` | List rooms |
| POST | `/sites/{site_id}/rooms` | Create room |
| PATCH | `/rooms/{room_id}` | Rename / retype |
| DELETE | `/rooms/{room_id}` | Remove room |
| GET | `/sites/{site_id}/members` | Users with access and per-site role |
| POST | `/sites/{site_id}/members` | Invite by phone; writes `site_members` |
| PATCH | `/sites/{site_id}/members/{user_id}` | Change per-site role |
| DELETE | `/sites/{site_id}/members/{user_id}` | Revoke — **step-up required** |

Effective permission is the narrower of tenant `users.role` and `site_members.role`.

### 8.3 Hubs

| Method | Path | Purpose |
|---|---|---|
| GET | `/hubs` | List hubs |
| POST | `/hubs/claim` | Claim by `claim_code`; binds hub to tenant/site |
| GET | `/hubs/{hub_id}` | Status, fw, uplink, `config_version` vs `applied_version` |
| PATCH | `/hubs/{hub_id}` | Rename, change `fw_channel` |
| DELETE | `/hubs/{hub_id}/claim` | Unclaim — **step-up required** |
| GET | `/hubs/{hub_id}/connection` | LAN hostname, port, `cert_fingerprint` for pinning |
| POST | `/hubs/{hub_id}/resync` | Force full config push |
| POST | `/hubs/{hub_id}/pairing-mode` | Open Zigbee join window (TTL-bounded) |
| GET | `/hubs/{hub_id}/diagnostics` | Uptime, queue depth, mesh health, `edge_schema_version` |
| GET | `/hubs/{hub_id}/backups` | Backup history |
| POST | `/hubs/{hub_id}/backups` | Trigger backup now |
| POST | `/hubs/{hub_id}/replace` | Begin RMA flow — see §11 |
| GET | `/hubs/{hub_id}/certificate` | Certificate status and expiry |

### 8.4 Devices, commissioning, appliances

| Method | Path | Purpose |
|---|---|---|
| GET | `/devices?site_id=&room_id=` | List devices with current state |
| GET | `/devices/{device_id}` | Detail incl. capabilities, calibration, commissioning |
| PATCH | `/devices/{device_id}` | Rename, assign room, set calibration |
| DELETE | `/devices/{device_id}` | Retire (soft) |
| GET | `/devices/commissioning?hub_id=` | In-flight pairings with status and error |
| POST | `/devices/{device_id}/retry-commissioning` | Re-run interview |
| POST | `/devices/{device_id}/commands` | Issue command — **`Idempotency-Key` required** |
| GET | `/devices/{device_id}/health` | LQI/RSSI/battery history |
| GET | `/commands/{command_id}` | Status incl. `route_attempted` / `route_succeeded` |
| GET | `/appliances?site_id=` | List appliances |
| POST | `/appliances` | Create appliance |
| PATCH | `/appliances/{appliance_id}` | Update type, rated watts, `is_critical` |
| POST | `/appliances/{appliance_id}/bindings` | Bind to device; closes prior binding atomically |
| DELETE | `/bindings/{binding_id}` | Unbind (sets `bound_until`) |

**Command payload:**

```jsonc
POST /devices/{device_id}/commands
Idempotency-Key: 6f1c…
{
  "action": "switch",
  "state": "off",
  "ttl_s": 300,
  "override_until": "2026-08-13T22:00:00+03:00"
}
```

Rejected `409` if the bound appliance is `is_critical` and the action is a shed.
Rejected `409` if a binding already exists for that device or appliance (partial unique
index; the API surfaces it as a conflict rather than a 500).

### 8.5 Telemetry, mesh health, cost

| Method | Path | Purpose |
|---|---|---|
| GET | `/telemetry/series` | `?site_id=&device_id=&from=&to=&resolution=raw\|hourly\|daily` |
| GET | `/telemetry/live?site_id=` | Reads `device_current_state`, not the hypertable |
| GET | `/telemetry/summary` | Totals by device / appliance / room for a window |
| GET | `/mesh/health?hub_id=` | Per-device LQI, parent, hop count, weak links |
| GET | `/costs/series` | Same params; KES breakdown |
| GET | `/costs/summary` | Period totals, marginal rate, band position |
| GET | `/costs/breakdown?site_id=&period=` | Per-appliance share, incl. unmetered gap |
| GET | `/insights?site_id=` | Ranked recommendations |
| GET | `/exports/csv?site_id=&from=&to=` | Signed download URL (entitlement-gated) |

Every cost response carries `is_estimated` and, when true, a machine-readable reason — the
UI uses it to label figures honestly (Database Design §3.1).

`/telemetry/live` reads the current-state cache. It must never scan `telemetry_raw`; that
path is the most common user action in the product and the most expensive query in the
database.

### 8.6 Tariffs and billing period

| Method | Path | Purpose |
|---|---|---|
| GET | `/tariffs/current?site_id=` | Active schedule, bands, levies |
| GET | `/tariffs/schedules` | Version history |
| GET | `/sites/{site_id}/billing-period` | Current period, kWh accumulated, band |
| POST | `/sites/{site_id}/billing-period/reset` | Correct accumulator from a KPLC bill |
| GET | `/sites/{site_id}/token-purchases` | Prepaid purchase history |
| POST | `/sites/{site_id}/token-purchases` | Record purchase; rejects duplicate token or receipt |
| POST | `/webhooks/mpesa/daraja` | Daraja callback — signature-verified, replay-guarded by receipt |

### 8.7 Modes, rules, schedules

| Method | Path | Purpose |
|---|---|---|
| GET | `/sites/{site_id}/modes` | List modes + active state |
| POST | `/sites/{site_id}/modes` | Create custom mode |
| POST | `/modes/{mode_id}/activate` | Activate (deactivates conflicting modes) |
| POST | `/modes/{mode_id}/deactivate` | Deactivate |
| GET | `/sites/{site_id}/rules` | List rules |
| POST | `/sites/{site_id}/rules` | Create — validated against shared JSON Schema |
| PATCH | `/rules/{rule_id}` | Update; bumps `config_version`, records `updated_by` |
| DELETE | `/rules/{rule_id}` | Remove |
| POST | `/rules/{rule_id}/test` | Dry-run against last 24 h of data |
| GET | `/sites/{site_id}/schedules` | List schedule entries |
| POST | `/sites/{site_id}/schedules` | Create (local wall-clock; wrap permitted) |
| PATCH | `/schedules/{entry_id}` | Update |
| DELETE | `/schedules/{entry_id}` | Remove |

Any write here increments `hubs.config_version` and triggers a downlink push, subject to the
`edge_schema_version` gate in §6.2.

### 8.8 Alerts, budgets, notifications

| Method | Path | Purpose |
|---|---|---|
| GET | `/sites/{site_id}/alert-definitions` | List |
| POST | `/sites/{site_id}/alert-definitions` | Create |
| PATCH | `/alert-definitions/{id}` | Update thresholds, severity, cooldown |
| DELETE | `/alert-definitions/{id}` | Remove |
| GET | `/alerts?site_id=&status=open\|closed` | Alert events |
| POST | `/alerts/{alert_event_id}/acknowledge` | Acknowledge |
| GET | `/notifications?user_id=` | Delivery history with status and suppression reason |
| GET | `/sites/{site_id}/budgets` | List budgets |
| POST | `/sites/{site_id}/budgets` | Create |
| PATCH | `/budgets/{budget_id}` | Update limit, warn threshold, breach action |

`/notifications` exists so support can answer "I never got the alert" — it distinguishes
never-sent from sent-and-failed from suppressed by quiet hours.

### 8.9 Subscription

| Method | Path | Purpose |
|---|---|---|
| GET | `/plans` | Public plan catalogue |
| GET | `/subscription` | Current subscription + **resolved** entitlement |
| POST | `/subscription/change` | Upgrade/downgrade → M-Pesa STK ref — **step-up required** |
| POST | `/subscription/cancel` | Cancel at period end |
| GET | `/subscription/payments` | Payment history |

`/subscription` returns entitlement already resolved from `plans.limits` merged with
`entitlement_overrides`. Clients never compute entitlement themselves, and limits are
enforced in middleware regardless of what the client believes.

### 8.10 Realtime

```
WSS /v1/stream?site_id=<uuid>
```

Events: `telemetry.tick`, `device.state`, `device.commissioning`, `alert.opened`,
`alert.closed`, `mode.changed`, `hub.online`, `hub.offline`, `command.acked`,
`firmware.progress`.

---

## 9. Local hub API

Reachable with **no internet**. This is why a native mobile app is required rather than a
web-only client.

**Discovery:** mDNS service `_ecotrack._tcp.local`, hostname `ecotrack-<serial>.local`
**Base:** `https://ecotrack-<serial>.local:8443/local/v1`
**Trust:** self-signed hub certificate, **pinned** by the app using `cert_fingerprint`
obtained from the cloud during pairing. No public CA involved.
**Auth:** site-scoped local token issued at pairing, presented as a bearer token.

### 9.1 Endpoints

| Method | Path | Purpose |
|---|---|---|
| GET | `/identity` | `hub_id`, serial, fw, `config_version`, `edge_schema_version` — unauthenticated |
| POST | `/pair` | Exchange cloud-issued claim token for a local token |
| GET | `/state` | Full snapshot: devices, states, reachability, active mode |
| GET | `/devices` | Device list from `device_cache` |
| GET | `/devices/{ieee}` | Single device state |
| POST | `/devices/{ieee}/command` | Actuate — **`Idempotency-Key` required** |
| GET | `/live` | Latest watts/volts per device |
| GET | `/today` | Today's kWh and estimated KES from local tariff cache |
| GET | `/rollups?from=&to=` | Local hourly history |
| GET | `/alerts/active` | Open alerts from `alert_state` |
| GET | `/modes` | Cached modes + active |
| POST | `/modes/{key}/activate` | Activate locally; queued to outbox for cloud |
| GET | `/health` | Uptime, mesh status, queue depth, `clock_conf`, uplink state |
| WSS | `/events` | Live state and telemetry stream |

### 9.2 Bounded offline capability

Deliberately limited. The local API can read state, actuate devices, activate modes, and
display estimated KES. It **cannot** create rules, change tariffs, manage users, or serve
long history — those require the cloud, and the app shows them as unavailable rather than
failing opaquely.

### 9.3 Edge schema migration contract

The daemon at startup:

1. Reads `MAX(version)` from `schema_migrations`.
2. **Version ahead of this binary** → halt, log, report `schema_ahead` on next heartbeat. Do
   not migrate downward; do not operate on data this build does not understand.
3. **Version behind** → apply ordered migrations, each in its own transaction, recording
   every step.
4. Report `edge_schema_version` on connect. The cloud withholds any config payload requiring
   a higher schema and queues a firmware update instead.

Without this contract, the first schema change shipped over OTA bricks hubs in the field.

---

## 10. Security model

| Layer | Control |
|---|---|
| Hub ↔ cloud | Mutual TLS, per-hub client certificate, topic ACLs scoped to `hub_id` |
| App ↔ hub | Certificate pinning via cloud-issued `cert_fingerprint` + local bearer token |
| App ↔ cloud | JWT, 15-min access token, rotating refresh tracked in `auth_sessions` |
| Session revocation | Per-session and revoke-all, by `refresh_token_jti` |
| High-consequence actions | OTP step-up re-verification (§8.1) |
| Rate limiting | Redis counters with TTL, applied in middleware; config in `rate_limit_config` |
| OTP handling | Hashed at rest, 5-minute expiry, 3 attempts, Redis send throttle |
| Database | RLS on `tenant_id`, enforced per connection; TLS to the database |
| Certificates | Tracked with expiry; 30-day advance alerting |
| Firmware | Signed images, signature verified on-device before flash |
| Secrets | Hub private key with restricted filesystem permissions; never in the repo |
| Audit | All config mutations to `audit_log`; `UPDATE`/`DELETE` revoked from the app role |

Hubs initiate **outbound** connections only. No inbound port forwarding, no public exposure
of household hardware.

### Scoping notes

**CSRF** applies to cookie-borne credentials. The mobile app uses `Authorization: Bearer`
and is not exposed. If the web dashboard adopts cookie sessions, CSRF protection is handled
by framework middleware with `SameSite` cookies — not by a database table.

**MFA beyond step-up** is deferred. Adding TOTP on top of an SMS-OTP first factor gains
little for a Kenyan household product. Step-up re-verification covers the actions that
matter.

**Security headers, SSRF allowlists and outbound destinations** are code and reverse-proxy
configuration, versioned in the repository. Making them runtime-mutable via database rows
would weaken rather than harden them.

---

## 11. Operations

### 11.1 Failure behaviour

| Failure | Behaviour |
|---|---|
| Internet down | Hub runs rules and schedules normally; app uses LAN path; data buffers |
| Hub power lost | Battery backup carries it; on restart RTC seeds time at `clock_conf` 1 until NTP |
| Cloud unreachable for days | Outbox accumulates by priority; rollups preserved, raw evicted oldest-first |
| Zigbee device unreachable | `reachable = 0`, distinguished from `off`; alert after grace period |
| Command to unreachable device | Held in `cmd_queue` until reachable or `expires_at` |
| Command sent to offline hub | Queued with `expires_at`; expired commands never replay |
| Duplicate command (LAN + cloud) | `cmd_dedup` makes the second a no-op returning the cached result |
| Clock unsynced | Data stored at low `clock_conf`, excluded from aggregates until reconciled |
| Hub SD-card failure | Restore from backup, or RMA flow (§11.3) |
| Certificate expiring | `cert_expiring` alert at 30 days; renewal pushed over the existing channel |

### 11.2 Backup policy

Nightly hub backup to object storage: `schema_migrations` version, `meta`, `device_cache`,
`rollup_hourly`, and the **Zigbee network key** (encrypted). Metadata recorded in
`hub_backup_metadata` with a SHA-256 checksum.

The network key is the operationally critical item. Without it, replacing a hub means
physically re-pairing every device in the household by hand.

### 11.3 Hub replacement / RMA flow

1. `POST /hubs/{hub_id}/replace` creates a `hub_replacements` row and a new `hubs` record.
2. Latest backup for the old hub is restored onto the new hub, including the network key.
3. `devices.hub_id` is re-pointed to the new hub. `ieee_addr` is stable, so telemetry
   history and appliance bindings survive intact.
4. Devices rejoin the restored network automatically. Any that do not are flagged for manual
   re-pairing and counted in `devices_repaired`.
5. Old hub set to `status = 'replaced'`; its certificate revoked.

Without this path, a failed hub orphans every device — because `devices` is keyed
`UNIQUE (hub_id, ieee_addr)` — and loses the appliance binding history.

### 11.4 OTA rollout

Staged by `fw_channel` (`dev → beta → stable`). Each release declares a minimum
`edge_schema_version`; the orchestrator will not push a config payload to a hub whose schema
is behind, and will not push firmware to a hub reporting `schema_ahead`. Progress is
streamed to the app as `firmware.progress`.

---

## 12. Compliance — Kenya Data Protection Act 2019

The governing regime is the **DPA 2019**, not GDPR.

Household energy telemetry is occupancy-revealing: it shows when a home is empty. PIR
occupancy sensors make that more direct. This is not incidental metadata and should not be
treated as such.

**In the system now:**

- `consent_records` — per-purpose, timestamped, withdrawable, with evidence of how consent
  was captured
- `data_classification` — per-column sensitivity and retention
- `/me/data-export` and `/me/data-erasure` — subject access and erasure
- Log masking on classified columns

**Outstanding programme items, not schema:**

- Registration with the Office of the Data Protection Commissioner as a data controller
- A documented lawful basis for each processing purpose
- A retention schedule reconciled against `data_classification.retention_days`
- A data-processing agreement with any third party (SMS gateway, cloud host) receiving
  personal data

---

## 13. Interface structure

### 13.1 Mobile app (Android-first, React Native or Flutter)

**Transport abstraction is the central design decision.** One client interface, two
implementations; screens never know which is in use.

```
UI screens
    │
    ▼
EcoTrackClient (interface)
    ├── LanTransport    → mDNS + pinned TLS → hub
    └── CloudTransport  → HTTPS → api.ecotrack.co.ke
         │
    Selection: LAN if hub resolvable and reachable, else cloud.
    Both carry the same Idempotency-Key, so a command travelling
    both routes is applied once.
```

**Connection preferences live on the device, not the server.** Preferred path, LAN timeout,
and discovery mode are per-installation choices; storing them per site in the cloud would
mean a user's two phones overwrite each other's settings. Only genuine per-site facts —
`static_ip`, `local_api_port`, `allow_lan_commands`, `allow_cloud_commands` — are
server-side.

**Navigation tree:**

```
Home
├── Site selector (multi-site tenants)
├── Now card ....... live watts, today's kWh, estimated KES (labelled)
├── Mode switcher .. Eco · Comfort · Away · Night
├── Quick controls . favourited appliances, toggle
└── Alert banner ... open alerts, tap to detail

Devices
├── Grouped by room
├── Device detail
│   ├── Live power, state, reachability
│   ├── Toggle + override with TTL
│   ├── 24 h / 7 d / 30 d consumption
│   ├── Signal quality and mesh parent
│   └── Bound appliance, calibration (installer role)
└── Add device → pairing flow with live commissioning status

Insights
├── Spend breakdown by appliance (incl. unmetered gap)
├── Band position + marginal rate
├── Budget progress
├── Trends vs previous period
└── Recommendations

Automation
├── Modes (edit membership, priority)
├── Schedules (per appliance, wall-clock, overnight supported)
├── Rules (trigger → condition → action builder)
└── Budgets

Account
├── Profile, sites, members (per-site roles)
├── Active sessions and log out everywhere
├── Preferences (units, quiet hours, channels)
├── Privacy and consents
├── Meter setup (prepaid/postpaid, token entry)
├── Subscription and payments
└── Hub status, backups, diagnostics
```

**Connection state is always visible:**

| State | Meaning | Capability |
|---|---|---|
| Local | On hub Wi-Fi, LAN path active | Control + live data, no history/config |
| Cloud | Remote, hub online | Full |
| Cloud (hub offline) | Hub unreachable | History only; controls disabled with reason |
| Offline | No connectivity | Cached last-known state, read-only |

**Kenya-specific:** Android-first, data-light payloads, on-device cache so the app opens
usefully with no connectivity, M-Pesa STK push for subscriptions, all monetary values in KES
with estimation clearly labelled.

### 13.2 Web dashboard

Cloud-only. Never attempts to reach the hub directly — browsers cannot do mDNS discovery,
and a self-signed local certificate either triggers a full-page warning or is blocked as
mixed content from a hosted origin.

```
Overview ....... multi-site rollup, spend, alerts
Analytics ...... long-horizon series, comparisons, CSV export
Sites .......... per-site drill-down, device inventory, mesh map
Automation ..... rule authoring (richer editor than mobile)
Billing ........ tariff history, reconciliation, subscription
Admin .......... members, per-site roles, audit log, consents
```

### 13.3 Installer / admin console

Separate surface, `installer` role. Commissioning wizard with live interview status, Zigbee
mesh visualisation from `device_health_history`, CT calibration against a known resistive
load, per-hub log access, backup/restore, RMA initiation, OTA channel assignment.

---

## 14. Open items

1. **Radio topology** — resolved here as Zigbee-only; `System_Overview` still describes a
   433 MHz hybrid and must be updated before CDIE procurement proceeds against it.
2. **SBC selection** — pending measured stack footprint and Kenyan landed cost.
3. **Prepaid band assignment** — see Database Design §3.1; blocks accurate KES until token
   ingestion lands.
4. **Free-tier remote access** — whether remote access is a paid feature is an unmade
   product decision. `plans.limits.remote_access` expresses either model; settle before
   pricing is published.
5. **Beachhead segment** — households vs small commercial affects device counts per site,
   plan limits, and the installation ladder.
6. **Grant deliverable scope** — whether custom hardware demonstration is required
   determines how much ESP32-C6 node development sits on the critical path.
7. **`pg_jsonschema` availability** — verify on the chosen managed Postgres before relying
   on database-level JSON validation; application-layer validation is required regardless.
8. **RLS on continuous aggregates** — confirm tenant isolation holds on the aggregate read
   path, not only on the base hypertable. Pre-launch test.
