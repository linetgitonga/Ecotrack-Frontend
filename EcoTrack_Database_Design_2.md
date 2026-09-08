# EcoTrack — Database Design

**Version:** 1.0
**Supersedes:** v0.9
**Scope:** Cloud system-of-record (PostgreSQL + TimescaleDB) and edge local store (SQLite)
**Companion documents:** `EcoTrack_System_Design.md`, `EcoTrack_Gap_Analysis_Validation.md`

---

## 0. Design principles

1. **Cloud is the system of record. Edge is a cache with an outbox.** The two schemas are
   deliberately different shapes, not subset/superset.
2. **Devices and appliances are separate entities.** Appliances outlive the hardware
   metering them.
3. **Tariffs are versioned data, never code.** Historical bills must reproduce exactly
   after a rate change.
4. **Energy is derived from cumulative counters, not integrated power.** Outages then cost
   accuracy, not correctness.
5. **Money is stored at working precision and rounded only at display.** Never at
   intermediate storage.
6. **Alerts are stateful intervals, not events.** Prevents notification storms from
   cycling loads.
7. **Schedules are stored in local wall-clock time**, never as UTC instants, and may wrap
   past midnight.
8. **Every tenant-scoped table carries `tenant_id` directly** so row-level security is a
   single predicate, not a join chain.
9. **Ephemeral counters belong in Redis, not Postgres.** Rate-limit state, OTP throttling
   and session activity counters are never database writes on the request path.

### Changes in v1.0

| Area | Change |
|---|---|
| Authentication | `auth_sessions`, `auth_otp_requests`, `auth_failed_attempts` added |
| Authorization | `site_members` for per-site roles; full RBAC deferred |
| Money | `cost_hourly` monetary columns widened to `numeric(14,6)` |
| Schedules | Overnight wrap now permitted; degenerate zero-length forbidden |
| Devices | Commissioning lifecycle, current-state cache, health history, metering mode |
| Operations | Firmware updates, hub backups, hub replacement, notification delivery |
| Compliance | Consent records and data classification under Kenya DPA 2019 |
| Integrity | Binding overlap, billing period, token purchase, alert constraints |
| Edge | Schema versioning, command queue, outbox retry metadata |
| Audit | Write-once by privilege revocation; hash chain deferred |

---

# PART 1 — CLOUD SCHEMA (PostgreSQL 15+ / TimescaleDB 2.x)

## 1.1 Tenancy and identity

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE tenants (
  tenant_id       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  display_name    text NOT NULL,
  county          text,
  created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE users (
  user_id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES tenants,
  phone_e164      text UNIQUE NOT NULL,       -- primary identity in KE
  email           text UNIQUE,
  display_name    text,
  role            text NOT NULL CHECK (role IN ('owner','member','viewer','installer')),
  locale          text NOT NULL DEFAULT 'en-KE',
  status          text NOT NULL DEFAULT 'active'
                    CHECK (status IN ('active','suspended','deleted')),
  created_at      timestamptz NOT NULL DEFAULT now(),
  last_login_at   timestamptz
);

CREATE TABLE sites (                           -- a household or premises
  site_id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES tenants,
  label           text NOT NULL,
  timezone        text NOT NULL DEFAULT 'Africa/Nairobi',
  meter_type      text NOT NULL CHECK (meter_type IN ('prepaid','postpaid')),
  kplc_account_no text,
  kplc_meter_no   text,
  supply_phase    text NOT NULL DEFAULT 'single'
                    CHECK (supply_phase IN ('single','three')),
  occupant_count  int,
  status          text NOT NULL DEFAULT 'active'
                    CHECK (status IN ('active','suspended','decommissioned')),
  -- server-side connectivity facts (client preferences live on the device)
  static_ip            inet,
  local_api_port       int NOT NULL DEFAULT 8443,
  allow_lan_commands   boolean NOT NULL DEFAULT true,
  allow_cloud_commands boolean NOT NULL DEFAULT true,
  created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE rooms (
  room_id   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES tenants,
  site_id   uuid NOT NULL REFERENCES sites,
  name      text NOT NULL,
  room_type text                               -- kitchen, bedroom, shop_floor, outdoor
);

CREATE INDEX ON users (tenant_id);
CREATE INDEX ON sites (tenant_id) WHERE status = 'active';
CREATE INDEX ON rooms (site_id);
```

### Per-site membership

`users.role` is tenant-wide, which is too coarse once a tenant has more than one site — a
`member` would otherwise hold equal rights on both. `site_members` closes that hole without
the weight of a full RBAC system.

```sql
CREATE TABLE site_members (
  site_id     uuid NOT NULL REFERENCES sites,
  user_id     uuid NOT NULL REFERENCES users,
  tenant_id   uuid NOT NULL,
  role        text NOT NULL CHECK (role IN ('owner','member','viewer','installer')),
  granted_by  uuid REFERENCES users,
  granted_at  timestamptz NOT NULL DEFAULT now(),
  revoked_at  timestamptz,
  PRIMARY KEY (site_id, user_id)
);

CREATE INDEX ON site_members (user_id) WHERE revoked_at IS NULL;
```

Effective permission is the **narrower** of `users.role` and `site_members.role`. A full
permission/role/assignment model is deferred until commercial multi-site customers justify
it.

### Row-level security

The application sets `app.tenant_id` per connection or transaction.

```sql
ALTER TABLE sites ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON sites
  USING (tenant_id = current_setting('app.tenant_id')::uuid);
```

Repeat for: `users`, `rooms`, `site_members`, `hubs`, `devices`, `appliances`,
`appliance_bindings`, `device_current_state`, `modes`, `rules`, `schedules`, `overrides`,
`budgets`, `alert_definitions`, `alert_events`, `commands`, `billing_periods`,
`token_purchases`, `cost_hourly`, `telemetry_raw`, `subscriptions`, `consent_records`,
`notification_deliveries`.

> **Verify before launch.** Continuous aggregates refresh under the owner's privileges and
> do not inherit the querying session's RLS context. Confirm that both the refresh job and
> every read path against `telemetry_hourly` / `telemetry_daily` isolate correctly, or
> tenant data can leak through the aggregate even though the base hypertable is protected.
> This is a pre-launch test, not an assumption.

---

## 1.2 Authentication and session state

Phone OTP is the only authentication factor, which makes attempt limiting and session
revocation load-bearing rather than optional.

```sql
CREATE TABLE auth_sessions (
  session_id        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           uuid NOT NULL REFERENCES users,
  refresh_token_jti text UNIQUE NOT NULL,
  ip_address        inet,
  device_name       text,               -- user-visible: "Samsung A14"
  login_at          timestamptz NOT NULL DEFAULT now(),
  last_activity     timestamptz NOT NULL DEFAULT now(),
  expires_at        timestamptz NOT NULL,
  is_revoked        boolean NOT NULL DEFAULT false,
  revoked_at        timestamptz,
  revoked_reason    text
);

CREATE INDEX ON auth_sessions (refresh_token_jti) WHERE is_revoked = false;
CREATE INDEX ON auth_sessions (user_id, expires_at)  WHERE is_revoked = false;
```

Access tokens stay stateless and short-lived (15 min); only refresh tokens are tracked.
`last_activity` is written on refresh, not per request — per-request writes would put
Postgres on the hot path of every API call.

```sql
CREATE TABLE auth_otp_requests (
  request_id   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  phone_e164   text NOT NULL,
  code_hash    text NOT NULL,           -- never store the code itself
  purpose      text NOT NULL CHECK (purpose IN ('login','pairing','recovery','step_up')),
  attempts     int NOT NULL DEFAULT 0,
  max_attempts int NOT NULL DEFAULT 3,
  verified_at  timestamptz,
  created_at   timestamptz NOT NULL DEFAULT now(),
  expires_at   timestamptz NOT NULL DEFAULT (now() + interval '5 minutes')
);

CREATE INDEX ON auth_otp_requests (phone_e164, created_at DESC);

CREATE TABLE auth_failed_attempts (
  attempt_id   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  identifier   text NOT NULL,           -- phone or session subject
  ip_address   inet NOT NULL,
  user_agent   text,
  reason       text,
  attempted_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX ON auth_failed_attempts (identifier, attempted_at DESC);
CREATE INDEX ON auth_failed_attempts (ip_address, attempted_at DESC);
```

**Two constraints deliberately absent.** There is no `UNIQUE (phone_e164, code)` — six-digit
codes legitimately recur, and uniqueness would intermittently reject valid sends, which
users experience as "the code never arrived". And no partial index uses `now()` in its
predicate: Postgres requires index predicates to be `IMMUTABLE`, so such statements do not
execute at all. Time windows are applied at query time.

**Send throttling lives in Redis**, keyed by phone and by IP with TTL. The tables above are
the audit record, not the rate limiter.

### Step-up verification

Rather than a full MFA subsystem, high-consequence actions re-verify by OTP:

- Subscription change or payment
- Removing a site member or transferring ownership
- Unclaiming a hub
- Any `installer`-role action on a site the installer does not own

```sql
CREATE TABLE rate_limit_config (
  endpoint         text NOT NULL,
  method           text NOT NULL,
  limit_per_minute int NOT NULL DEFAULT 60,
  limit_per_hour   int NOT NULL DEFAULT 1000,
  requires_auth    boolean NOT NULL DEFAULT true,
  updated_at       timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (endpoint, method)
);
```

Configuration only. Counters are Redis keys with TTL — see System Design §10.

---

## 1.3 Hubs, certificates, devices, appliances

```sql
CREATE TABLE hubs (
  hub_id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         uuid NOT NULL REFERENCES tenants,
  site_id           uuid NOT NULL REFERENCES sites,
  serial            text UNIQUE NOT NULL,
  cert_fingerprint  text UNIQUE,               -- SHA-256, pinned by mobile app
  claim_code        text UNIQUE,               -- one-time, consumed at pairing
  fw_version        text,
  fw_channel        text NOT NULL DEFAULT 'stable'
                      CHECK (fw_channel IN ('dev','beta','stable')),
  edge_schema_version int NOT NULL DEFAULT 1,  -- gates OTA compatibility
  local_hostname    text,                      -- ecotrack-<serial>.local
  last_seen_at      timestamptz,
  last_ipv4         inet,
  last_ipv6         inet,
  uplink_type       text CHECK (uplink_type IN ('wifi','ethernet','cellular')),
  config_version    bigint NOT NULL DEFAULT 0, -- cloud increments
  applied_version   bigint NOT NULL DEFAULT 0, -- hub reports back
  status            text NOT NULL DEFAULT 'unclaimed' CHECK (status IN
                      ('unclaimed','active','suspended','replaced','retired')),
  commissioned_at   timestamptz
);
```

### Certificate lifecycle

Without expiry tracking, hub certificates fail silently and in cohorts — every hub
commissioned in one week fails in one week, in the field, with no warning.

```sql
CREATE TABLE certificates (
  cert_id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  hub_id             uuid REFERENCES hubs,
  tenant_id          uuid REFERENCES tenants,
  cert_type          text NOT NULL CHECK (cert_type IN
                       ('hub_server','hub_client','cloud_server')),
  serial_number      text UNIQUE NOT NULL,
  fingerprint_sha256 text UNIQUE NOT NULL,
  subject_cn         text NOT NULL,
  issuer_cn          text NOT NULL,
  not_before         timestamptz NOT NULL,
  not_after          timestamptz NOT NULL,
  status             text NOT NULL DEFAULT 'active'
                       CHECK (status IN ('pending','active','revoked','expired')),
  revoked_at         timestamptz,
  revocation_reason  text,
  last_renewed_at    timestamptz,
  created_at         timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX ON certificates (not_after) WHERE status = 'active';
```

A daily job raises a `cert_expiring` alert at 30 days.

### Hub replacement

SD-card failure on low-cost SBCs is a *when*. Because `devices` is keyed
`UNIQUE (hub_id, ieee_addr)`, a hub swap without an explicit path orphans every device and
loses the appliance binding history.

```sql
CREATE TABLE hub_replacements (
  replacement_id   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id        uuid NOT NULL,
  site_id          uuid NOT NULL REFERENCES sites,
  old_hub_id       uuid NOT NULL REFERENCES hubs,
  new_hub_id       uuid NOT NULL REFERENCES hubs,
  reason           text NOT NULL CHECK (reason IN
                     ('sd_failure','hardware_fault','upgrade','rma','lost')),
  devices_migrated int NOT NULL DEFAULT 0,
  devices_repaired int NOT NULL DEFAULT 0,   -- required manual re-pairing
  network_key_restored boolean NOT NULL DEFAULT false,
  started_at       timestamptz NOT NULL DEFAULT now(),
  completed_at     timestamptz,
  notes            text
);
```

Devices are re-homed by updating `devices.hub_id`. `ieee_addr` is stable across the swap, so
telemetry history and appliance bindings survive. If the Zigbee network key was backed up
(§1.10), devices rejoin without physical re-pairing.

### Devices

```sql
CREATE TABLE devices (
  device_id       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES tenants,
  hub_id          uuid NOT NULL REFERENCES hubs,
  room_id         uuid REFERENCES rooms,
  ieee_addr       text NOT NULL,               -- Zigbee EUI-64; stable join key
  friendly_name   text NOT NULL,               -- user-renameable, never a join key
  device_class    text NOT NULL CHECK (device_class IN
                    ('smart_plug','light_node','ct_main','ct_circuit',
                     'relay_module','sensor')),
  metering_mode   text NOT NULL DEFAULT 'direct' CHECK (metering_mode IN
                    ('direct','ct_main','ct_subcircuit','none')),
  model           text,                        -- e.g. TS011F
  vendor          text,
  capabilities    jsonb NOT NULL DEFAULT '{}', -- {switch,metering,dimming,occupancy}
  ct_ratio        numeric,                     -- CT clamps only
  calibration     jsonb,                       -- {v_gain,i_gain,phase_offset}

  -- commissioning lifecycle
  commissioning_status text NOT NULL DEFAULT 'discovered' CHECK (commissioning_status IN
                    ('discovered','interviewing','joined','configured','failed')),
  commissioning_attempts   int NOT NULL DEFAULT 0,
  commissioning_started_at timestamptz,
  commissioning_timeout_at timestamptz,
  interview_completed_at   timestamptz,
  commissioning_error      text,

  commissioned_at timestamptz,
  retired_at      timestamptz,
  UNIQUE (hub_id, ieee_addr)
);

CREATE INDEX ON devices (hub_id) WHERE retired_at IS NULL;
CREATE INDEX ON devices (commissioning_status)
  WHERE commissioning_status IN ('discovered','interviewing','failed');
```

Zigbee interview takes 30–60 s and fails often enough that this is a primary support
surface. Without the lifecycle columns the pairing screen has nothing to render between
"started" and "done".

`metering_mode = 'none'` marks the synthetic unmetered-gap device used for whole-home
reconciliation (§3.2).

### Current state cache

```sql
CREATE TABLE device_current_state (
  device_id      uuid PRIMARY KEY REFERENCES devices,
  tenant_id      uuid NOT NULL,
  site_id        uuid NOT NULL,
  watts          real,
  volts          real,
  relay_state    boolean,
  reachable      boolean NOT NULL DEFAULT true,
  last_seen_at   timestamptz NOT NULL,
  updated_at     timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX ON device_current_state (site_id);
```

**Written by the ingest worker, not by a row trigger on `telemetry_raw`.** A per-row trigger
on a hypertable insert path costs throughput at exactly the moment it is least affordable —
during backlog replay after an outage.

Without this table, every app cold start scans recent `telemetry_raw` per device, under RLS,
on a compressed hypertable. That is the worst query in the system and it runs on the most
common user action.

### Appliances and bindings

```sql
CREATE TABLE appliances (
  appliance_id      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         uuid NOT NULL REFERENCES tenants,
  site_id           uuid NOT NULL REFERENCES sites,
  room_id           uuid REFERENCES rooms,
  name              text NOT NULL,             -- "Kitchen fridge"
  appliance_type    text NOT NULL,             -- fridge, kettle, iron, tv, water_heater, unmetered
  rated_watts       numeric,
  is_critical       boolean NOT NULL DEFAULT false,  -- never auto-shed
  duty_cycle_class  text CHECK (duty_cycle_class IN
                      ('continuous','cyclic','intermittent','on_demand')),
  created_at        timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE appliance_bindings (
  binding_id    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL,
  appliance_id  uuid NOT NULL REFERENCES appliances,
  device_id     uuid NOT NULL REFERENCES devices,
  bound_from    timestamptz NOT NULL DEFAULT now(),
  bound_until   timestamptz,
  CHECK (bound_until IS NULL OR bound_until > bound_from)
);

-- at most one open binding per side; prevents ambiguous cost attribution
CREATE UNIQUE INDEX uk_device_active_binding
  ON appliance_bindings (device_id)    WHERE bound_until IS NULL;
CREATE UNIQUE INDEX uk_appliance_active_binding
  ON appliance_bindings (appliance_id) WHERE bound_until IS NULL;

CREATE INDEX ON appliance_bindings (device_id, bound_from DESC);
CREATE INDEX ON appliance_bindings (appliance_id, bound_from DESC);
```

Cross-tenant binding is prevented structurally rather than by trigger:

```sql
ALTER TABLE appliances ADD UNIQUE (tenant_id, appliance_id);
ALTER TABLE devices    ADD UNIQUE (tenant_id, device_id);

ALTER TABLE appliance_bindings
  ADD FOREIGN KEY (tenant_id, appliance_id) REFERENCES appliances (tenant_id, appliance_id),
  ADD FOREIGN KEY (tenant_id, device_id)    REFERENCES devices    (tenant_id, device_id);
```

Composite foreign keys beat a `BEFORE INSERT` trigger here: enforced by the planner, no
write-time cost, and impossible to bypass.

**Why devices and appliances are separate:** a plug moves from the fridge to the microwave.
Keyed on `device_id` alone, last month's fridge spend silently becomes microwave spend.
Bindings make reassignment a new row, not a mutation.

**`is_critical`** is the load-shedding safety rail. A fridge must never be switched off by an
eco rule, and that belongs in the data model rather than in rule-authoring discipline.

---

## 1.4 Telemetry and device health

```sql
CREATE TABLE telemetry_raw (
  time          timestamptz NOT NULL,
  tenant_id     uuid NOT NULL,
  device_id     uuid NOT NULL,
  watts         real,
  volts         real,
  amps          real,
  power_factor  real,
  energy_wh_cum double precision,   -- device lifetime counter
  relay_state   boolean,
  clock_conf    smallint NOT NULL DEFAULT 2,  -- 0=rtc_only 1=drifted 2=ntp_synced
  PRIMARY KEY (device_id, time)
);

SELECT create_hypertable('telemetry_raw', 'time',
       chunk_time_interval => interval '1 day');

ALTER TABLE telemetry_raw SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'device_id',
  timescaledb.compress_orderby   = 'time DESC'
);

SELECT add_compression_policy('telemetry_raw', interval '2 days');
SELECT add_retention_policy  ('telemetry_raw', interval '30 days');
```

```sql
CREATE MATERIALIZED VIEW telemetry_hourly
WITH (timescaledb.continuous) AS
SELECT time_bucket('1 hour', time) AS bucket,
       tenant_id,
       device_id,
       avg(watts) AS avg_w,
       max(watts) AS peak_w,
       GREATEST(max(energy_wh_cum) - min(energy_wh_cum), 0) AS energy_wh,
       count(*)   AS sample_count
FROM telemetry_raw
WHERE clock_conf = 2
GROUP BY bucket, tenant_id, device_id;

SELECT add_continuous_aggregate_policy('telemetry_hourly',
  start_offset => interval '3 days',
  end_offset   => interval '1 hour',
  schedule_interval => interval '30 minutes');

CREATE MATERIALIZED VIEW telemetry_daily
WITH (timescaledb.continuous) AS
SELECT time_bucket('1 day', bucket) AS day,
       tenant_id, device_id,
       sum(energy_wh) AS energy_wh,
       max(peak_w)    AS peak_w
FROM telemetry_hourly
GROUP BY day, tenant_id, device_id;
```

**Retention:** raw 30 days, hourly ~2 years, daily indefinitely.

- Energy is `max(cum) − min(cum)`, so dropped samples cost resolution, not totals. The
  `GREATEST(..., 0)` guard absorbs counter resets and device replacement.
- The `clock_conf = 2` filter prevents RTC-drifted data landing in the wrong tariff hour.
  Rows at confidence 0/1 are retained but excluded until reconciled.
- `start_offset` of 3 days lets late-arriving buffered data fold in automatically. Longer
  outages require a targeted refresh — see §1.11.

### Mesh health

The architecture claims mesh reliability in dense housing as a design advantage. Without
link-quality history that claim cannot be substantiated, a weak-link node cannot be
diagnosed, and router placement cannot be advised.

```sql
CREATE TABLE device_health_history (
  sampled_at       timestamptz NOT NULL,
  tenant_id        uuid NOT NULL,
  device_id        uuid NOT NULL REFERENCES devices,
  hub_id           uuid NOT NULL REFERENCES hubs,
  lqi              smallint,
  rssi             smallint,
  battery_pct      smallint,
  reachable        boolean NOT NULL,
  parent_device_id uuid REFERENCES devices,
  hop_count        smallint,
  PRIMARY KEY (device_id, sampled_at)
);

SELECT create_hypertable('device_health_history', 'sampled_at',
       chunk_time_interval => interval '7 days');
SELECT add_retention_policy('device_health_history', interval '90 days');
```

**Sampled every 15 minutes, not at telemetry cadence.** Link quality changes slowly; a full
hypertable at telemetry rate would be disproportionate to its diagnostic value.

---

## 1.5 Tariffs — KPLC modelling

Rates change by gazette; historical bills must not move retroactively.

```sql
CREATE TABLE tariff_schedules (
  schedule_id    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  utility        text NOT NULL DEFAULT 'KPLC',
  code           text NOT NULL,          -- DC (domestic), SC (small commercial)
  effective_from date NOT NULL,
  effective_to   date,
  gazette_ref    text,
  UNIQUE (utility, code, effective_from)
);

CREATE TABLE tariff_bands (
  band_id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  schedule_id        uuid NOT NULL REFERENCES tariff_schedules,
  band_order         int  NOT NULL,
  min_kwh            numeric NOT NULL,
  max_kwh            numeric,            -- NULL = unbounded
  energy_kes_per_kwh numeric(14,6) NOT NULL,
  UNIQUE (schedule_id, band_order),
  CHECK (max_kwh IS NULL OR max_kwh > min_kwh)
);

CREATE TABLE tariff_levies (
  levy_id       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  schedule_id   uuid NOT NULL REFERENCES tariff_schedules,
  code          text NOT NULL,     -- FCC, FOREX, INFLATION, WARMA, EPRA, REP, VAT
  display_name  text,
  basis         text NOT NULL CHECK (basis IN
                  ('per_kwh','percent_of_energy','percent_of_subtotal','fixed_monthly')),
  rate          numeric(14,6) NOT NULL,
  applies_order int NOT NULL,       -- levies stack; order is significant
  taxable       boolean NOT NULL DEFAULT true,
  UNIQUE (schedule_id, code)
);

CREATE TABLE site_tariff_assignment (
  site_id       uuid NOT NULL REFERENCES sites,
  schedule_id   uuid NOT NULL REFERENCES tariff_schedules,
  assigned_from date NOT NULL,
  PRIMARY KEY (site_id, assigned_from)
);
```

### Three structural facts the model must respect

1. **Bands are monthly-cumulative, not instantaneous.** Cost per kWh depends on how much the
   site has already consumed this billing month. There is therefore no fixed "shillings per
   hour" — the same kettle costs more on the 28th than on the 3rd.
2. **Levies stack in a defined order and some are VAT-able.** `applies_order` + `taxable`
   absorb EPRA changes as data edits, not migrations.
3. **Prepaid token purchases and postpaid billing cycles reset the accumulator
   differently.** Both are tracked.

```sql
CREATE TABLE billing_periods (
  period_id       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL,
  site_id         uuid NOT NULL REFERENCES sites,
  period_start    date NOT NULL,
  period_end      date,
  kwh_accumulated numeric(14,6) NOT NULL DEFAULT 0,   -- drives band position
  kes_accumulated numeric(14,6) NOT NULL DEFAULT 0,
  is_current      boolean NOT NULL DEFAULT true,
  is_estimated    boolean NOT NULL DEFAULT true,
  UNIQUE (site_id, period_start),
  CHECK (period_end IS NULL OR period_end > period_start),
  CHECK (kwh_accumulated >= 0)
);

-- exactly one current period per site; two silently corrupts every KES figure
CREATE UNIQUE INDEX uk_site_current_period
  ON billing_periods (site_id) WHERE is_current = true;

CREATE TABLE token_purchases (
  purchase_id    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      uuid NOT NULL,
  site_id        uuid NOT NULL REFERENCES sites,
  purchased_at   timestamptz NOT NULL,
  amount_kes     numeric(14,2) NOT NULL,
  units_kwh      numeric(14,6),                  -- from receipt where available
  mpesa_receipt  text,
  token_digits   text,
  source         text NOT NULL CHECK (source IN ('manual','sms_parse','daraja')),
  consumed_at    timestamptz,
  created_at     timestamptz NOT NULL DEFAULT now(),
  CHECK (amount_kes > 0),
  CHECK (units_kwh IS NULL OR units_kwh > 0),
  CHECK (token_digits IS NULL OR token_digits ~ '^\d{20}$')   -- STS token format
);

CREATE UNIQUE INDEX uk_token_digits ON token_purchases (token_digits)
  WHERE token_digits IS NOT NULL;
CREATE UNIQUE INDEX uk_mpesa_receipt ON token_purchases (mpesa_receipt)
  WHERE mpesa_receipt IS NOT NULL;
```

These constraints protect billing accuracy directly. A duplicate receipt inflates
`kwh_accumulated`, which shifts the band, which corrupts every KES figure for the rest of
the month.

### Cost is stored, not recomputed

```sql
CREATE TABLE cost_hourly (
  bucket        timestamptz NOT NULL,
  tenant_id     uuid NOT NULL,
  site_id       uuid NOT NULL,
  device_id     uuid,                 -- NULL = whole-site aggregate row
  energy_kwh    numeric(14,6) NOT NULL,
  marginal_rate numeric(14,6) NOT NULL,   -- KES/kWh in force at that moment
  energy_kes    numeric(14,6) NOT NULL,
  levies_kes    numeric(14,6) NOT NULL,
  vat_kes       numeric(14,6) NOT NULL,
  total_kes     numeric(14,6) NOT NULL,
  schedule_id   uuid NOT NULL REFERENCES tariff_schedules,
  is_estimated  boolean NOT NULL DEFAULT true,
  PRIMARY KEY (site_id, bucket, device_id)
);
```

**Scale 6, not 2.** A 5 W standby load for one hour at ~KES 25/kWh is about KES 0.125.
Rounded to two decimals that becomes 0.13 — a 4% error applied consistently to exactly the
standby loads this product exists to surface. Across 20 devices × 720 hours the error
compounds and the per-appliance breakdown stops summing to the site total. **Round only at
the display and invoice boundary.**

Pinning `schedule_id` per row is what lets last year's figures reproduce after a rate
change. `is_estimated` propagates to the UI — see §3.1.

---

## 1.6 Modes, rules, schedules, overrides

```sql
CREATE TABLE modes (
  mode_id      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id    uuid,                  -- NULL = system-provided template
  site_id      uuid REFERENCES sites,
  key          text NOT NULL,         -- eco, comfort, away, night, sleep
  display_name text NOT NULL,
  description  text,
  priority     int NOT NULL DEFAULT 100,
  is_active    boolean NOT NULL DEFAULT false,
  activated_at timestamptz,
  UNIQUE (site_id, key)
);

CREATE TABLE rules (
  rule_id      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id    uuid NOT NULL,
  site_id      uuid NOT NULL REFERENCES sites,
  mode_id      uuid REFERENCES modes,     -- NULL = active in all modes
  name         text NOT NULL,
  enabled      boolean NOT NULL DEFAULT true,
  priority     int NOT NULL DEFAULT 100,
  trigger      jsonb NOT NULL,
  conditions   jsonb NOT NULL DEFAULT '[]',
  actions      jsonb NOT NULL,
  version      bigint NOT NULL DEFAULT 1,
  updated_by   uuid REFERENCES users,
  updated_at   timestamptz NOT NULL DEFAULT now()
);
```

`updated_by` exists because in a multi-member household "who disabled the water heater
schedule" is a question that will be asked.

### Schedules — overnight wrap is legal

```sql
CREATE TABLE schedules (
  schedule_entry_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id    uuid NOT NULL,
  site_id      uuid NOT NULL REFERENCES sites,
  appliance_id uuid REFERENCES appliances,
  mode_id      uuid REFERENCES modes,
  days_mask    smallint NOT NULL,     -- bitmask, Mon=1 … Sun=64
  start_local  time NOT NULL,
  end_local    time NOT NULL,
  action       text NOT NULL CHECK (action IN ('on','off','allow','block')),
  enabled      boolean NOT NULL DEFAULT true,
  updated_by   uuid REFERENCES users,

  CHECK (days_mask > 0),
  CHECK (start_local <> end_local)     -- wrap permitted; zero-length forbidden
);
```

> **Wrap semantics — normative.** When `start_local > end_local` the window wraps past
> midnight and means `[start_local, 24:00) ∪ [00:00, end_local)`. The day selected by
> `days_mask` is the day the window **starts**. A Monday entry of 22:00 → 06:00 runs from
> Monday 22:00 until Tuesday 06:00.
>
> A constraint of `start_local < end_local` would reject every overnight window — including
> Night mode, which is a core feature. Cloud validator and edge scheduler must implement
> the wrap identically.

```sql
CREATE TABLE overrides (
  override_id   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL,
  device_id     uuid NOT NULL REFERENCES devices,
  desired_state boolean NOT NULL,
  source        text NOT NULL CHECK (source IN ('app','physical_switch','installer')),
  created_by    uuid REFERENCES users,
  created_at    timestamptz NOT NULL DEFAULT now(),
  expires_at    timestamptz            -- NULL = until next scheduled transition
);
```

### Trigger / action grammar (JSONB)

```jsonc
// trigger
{"type":"schedule",  "cron":"0 22 * * *"}
{"type":"occupancy", "room_id":"…", "vacant_minutes":10}
{"type":"power",     "device_id":"…", "op":">", "watts":2000, "for_s":300}
{"type":"budget",    "threshold_pct":80}
{"type":"mode_enter","mode_key":"away"}

// condition
{"type":"time_between","start":"18:00","end":"22:00"}   // wrap semantics as above
{"type":"mode_active","mode_key":"eco"}
{"type":"device_state","device_id":"…","state":"on"}

// action
{"type":"switch","target":{"appliance_id":"…"},"state":"off"}
{"type":"notify","severity":"warning","template":"appliance_left_on"}
{"type":"set_mode","mode_key":"eco"}
```

Validated in the application layer against a shared JSON Schema, since the edge daemon
evaluates the same documents. If `pg_jsonschema` is available on the chosen managed
Postgres, add matching CHECK constraints as defence in depth — **verify provider support
first**, as several managed offerings do not include that extension.

### Conflict precedence

```
manual override (within TTL)
  > safety rule
  > critical-appliance guard
  > active mode rule (by priority)
  > schedule
  > default state
```

The physical override switch writes to `overrides` with `source = 'physical_switch'`.
Without that, the rules engine fights the occupant.

---

## 1.7 Preferences, budgets, alerts, notifications

```sql
CREATE TABLE user_preferences (
  user_id             uuid PRIMARY KEY REFERENCES users,
  currency            text NOT NULL DEFAULT 'KES',
  units_display       text NOT NULL DEFAULT 'kwh_and_kes'
                        CHECK (units_display IN ('kwh','kes','kwh_and_kes')),
  default_site_id     uuid REFERENCES sites,
  quiet_hours_start   time,
  quiet_hours_end     time,          -- wrap semantics per §1.6
  channels            jsonb NOT NULL DEFAULT '{"push":true,"sms":false,"email":false}',
  notify_min_severity text NOT NULL DEFAULT 'warning'
                        CHECK (notify_min_severity IN ('info','warning','critical')),
  data_saver          boolean NOT NULL DEFAULT false
);

CREATE TABLE budgets (
  budget_id        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id        uuid NOT NULL,
  site_id          uuid NOT NULL REFERENCES sites,
  period           text NOT NULL CHECK (period IN ('daily','weekly','monthly')),
  limit_kes        numeric(14,2),
  limit_kwh        numeric(14,6),
  warn_at_pct      int NOT NULL DEFAULT 80 CHECK (warn_at_pct BETWEEN 1 AND 100),
  action_on_breach text NOT NULL DEFAULT 'notify'
                     CHECK (action_on_breach IN
                       ('notify','notify_and_eco','notify_and_shed')),
  enabled          boolean NOT NULL DEFAULT true,
  CHECK (limit_kes IS NOT NULL OR limit_kwh IS NOT NULL)
);

CREATE TABLE alert_definitions (
  alert_def_id  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid,
  site_id       uuid REFERENCES sites,
  alert_type    text NOT NULL,   -- power_spike, standby_waste, budget_threshold,
                                 -- token_low, device_offline, anomaly_cusum,
                                 -- voltage_out_of_range, appliance_left_on,
                                 -- mesh_degraded, cert_expiring
  scope         jsonb NOT NULL DEFAULT '{}',
  params        jsonb NOT NULL,  -- {watts:2500, for_s:120, hysteresis_pct:10}
  severity      text NOT NULL CHECK (severity IN ('info','warning','critical')),
  cooldown_s    int NOT NULL DEFAULT 3600,
  evaluated_at  text NOT NULL DEFAULT 'edge'
                  CHECK (evaluated_at IN ('edge','cloud','both')),
  enabled       boolean NOT NULL DEFAULT true
);

CREATE TABLE alert_events (
  alert_event_id  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL,
  site_id         uuid NOT NULL,
  alert_def_id    uuid REFERENCES alert_definitions,
  device_id       uuid,
  appliance_id    uuid,
  opened_at       timestamptz NOT NULL,
  closed_at       timestamptz,
  peak_value      numeric,
  context         jsonb,
  detected_by     text NOT NULL CHECK (detected_by IN ('edge','cloud')),
  acknowledged_by uuid REFERENCES users,
  acknowledged_at timestamptz,
  dedup_key       text NOT NULL,
  UNIQUE (tenant_id, dedup_key, opened_at),
  CHECK (closed_at IS NULL OR closed_at >= opened_at)
);

CREATE INDEX ON alert_events (site_id, opened_at DESC) WHERE closed_at IS NULL;
CREATE INDEX idx_open_alerts_by_dedup
  ON alert_events (dedup_key) WHERE closed_at IS NULL;
```

**Alerts are stateful intervals.** A fridge cycling around a threshold would otherwise
generate hundreds of notifications. `opened_at`/`closed_at`, `cooldown_s` and a hysteresis
band in `params` prevent that. `detected_by` + `dedup_key` let an edge-raised and a
cloud-raised alert for the same condition converge on one row.

### Notification delivery

SMS costs money and push silently fails. Without a delivery record, "I never got the budget
alert" is unanswerable — never-sent, sent-and-failed, and suppressed-by-quiet-hours are
indistinguishable.

```sql
CREATE TABLE notification_deliveries (
  delivery_id       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         uuid NOT NULL,
  user_id           uuid NOT NULL REFERENCES users,
  alert_event_id    uuid REFERENCES alert_events,
  channel           text NOT NULL CHECK (channel IN ('push','sms','email')),
  status            text NOT NULL CHECK (status IN
                      ('queued','sent','delivered','failed','suppressed')),
  suppressed_reason text,          -- quiet_hours | below_severity | channel_disabled
  provider_ref      text,          -- FCM message id / SMS gateway id
  cost_kes          numeric(10,4), -- SMS only
  error             text,
  queued_at         timestamptz NOT NULL DEFAULT now(),
  sent_at           timestamptz,
  delivered_at      timestamptz
);

CREATE INDEX ON notification_deliveries (user_id, queued_at DESC);
CREATE INDEX ON notification_deliveries (alert_event_id);
```

---

## 1.8 Subscriptions and entitlement

```sql
CREATE TABLE plans (
  plan_id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code            text UNIQUE NOT NULL,     -- free, plus, pro, commercial
  display_name    text NOT NULL,
  price_kes_month numeric(10,2) NOT NULL,
  limits          jsonb NOT NULL,
  is_public       boolean NOT NULL DEFAULT true
);
```

```jsonc
// plans.limits — single source of truth for entitlement
{
  "max_devices": 5,
  "max_sites": 1,
  "history_days": 30,
  "nilm": false,
  "sms_alerts_month": 0,
  "api_access": false,
  "export_csv": false,
  "remote_access": true
}
```

```sql
CREATE TABLE subscriptions (
  subscription_id      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id            uuid NOT NULL REFERENCES tenants,
  plan_id              uuid NOT NULL REFERENCES plans,
  status               text NOT NULL CHECK (status IN
                         ('trialing','active','past_due','cancelled')),
  current_period_start timestamptz,
  current_period_end   timestamptz,
  mpesa_ref            text,
  cancelled_at         timestamptz
);

CREATE TABLE subscription_payments (
  payment_id      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  subscription_id uuid NOT NULL REFERENCES subscriptions,
  amount_kes      numeric(10,2) NOT NULL,
  paid_at         timestamptz,
  mpesa_receipt   text UNIQUE,          -- also the Daraja callback replay guard
  status          text NOT NULL CHECK (status IN
                    ('pending','success','failed','reversed'))
);

-- narrow patch over plan limits; explicitly not a parallel definition
CREATE TABLE entitlement_overrides (
  tenant_id   uuid PRIMARY KEY REFERENCES tenants,
  overrides   jsonb NOT NULL,     -- same keys as plans.limits; merged over it
  reason      text,
  granted_by  uuid REFERENCES users,
  expires_at  timestamptz
);
```

**Entitlement is derived in one place:** `subscriptions → plans.limits`, merged with
`entitlement_overrides` where present, resolved in middleware. Two tables independently
encoding what a user may do will drift, and the drift presents as a support ticket from a
customer who paid but cannot use a feature.

> **Open product decision.** Whether the free tier is LAN-only with remote access as a paid
> feature is *not yet decided*. `plans.limits.remote_access` can express it either way. See
> System Design §12.

---

## 1.9 Sync bookkeeping and audit

```sql
CREATE TABLE hub_config_versions (
  hub_id        uuid NOT NULL REFERENCES hubs,
  version       bigint NOT NULL,
  payload       jsonb NOT NULL,   -- modes, rules, schedules, calibration, alert defs, tariff
  payload_hash  text NOT NULL,    -- SHA-256, verified by hub before apply
  min_edge_schema_version int NOT NULL DEFAULT 1,
  created_at    timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (hub_id, version)
);

CREATE TABLE commands (
  command_id      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL,
  hub_id          uuid NOT NULL REFERENCES hubs,
  device_id       uuid NOT NULL REFERENCES devices,
  idempotency_key text NOT NULL,
  payload         jsonb NOT NULL,
  status          text NOT NULL CHECK (status IN
                    ('pending','sent','acked','failed','expired')),
  issued_by       uuid REFERENCES users,
  issued_via      text CHECK (issued_via IN ('cloud','lan')),
  route_attempted text CHECK (route_attempted IN ('lan','cloud','both')),
  route_succeeded text CHECK (route_succeeded IN ('lan','cloud')),
  issued_at       timestamptz NOT NULL DEFAULT now(),
  acked_at        timestamptz,
  expires_at      timestamptz NOT NULL,
  error           text,
  UNIQUE (hub_id, idempotency_key)
);

CREATE INDEX ON commands (hub_id, status) WHERE status IN ('pending','sent');
```

`route_attempted` / `route_succeeded` diagnose the LAN-versus-cloud path. Per-command
latency is **not** stored here — that is metrics data and belongs in the metrics pipeline,
not a transactional table.

**`expires_at` matters.** A "switch off" queued while the hub was offline for six hours must
not fire when it reconnects at midnight.

### Audit log — write-once by privilege

```sql
CREATE TABLE audit_log (
  audit_id   bigserial PRIMARY KEY,
  tenant_id  uuid,
  user_id    uuid,
  session_id uuid REFERENCES auth_sessions,
  category   text NOT NULL CHECK (category IN
               ('config','auth','authz','billing','device','security')),
  action     text NOT NULL,
  entity     text NOT NULL,
  entity_id  uuid,
  before     jsonb,
  after      jsonb,
  ip_address inet,
  request_id text,
  success    boolean NOT NULL DEFAULT true,
  error      text,
  at         timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX ON audit_log (tenant_id, at DESC);
CREATE INDEX ON audit_log (category, at DESC);

REVOKE UPDATE, DELETE ON audit_log FROM PUBLIC;
REVOKE UPDATE, DELETE ON audit_log FROM ecotrack_app;
```

**One log table, not two.** A separate `security_events` table would overlap ~70% and force
every investigation to query both and join on timestamps. `category` distinguishes them.

**Hash chaining is deliberately deferred.** A `BEFORE INSERT` trigger reading the previous
row's hash forks under concurrency — two simultaneous inserts chain from the same
predecessor, and verification then reports tampering during entirely normal operation.
`bigserial` gaps from rolled-back transactions compound it. If tamper evidence becomes a
requirement, implement periodic Merkle anchoring in a single serialized worker:

```sql
CREATE TABLE audit_chain_anchors (
  anchor_id     bigserial PRIMARY KEY,
  from_audit_id bigint NOT NULL,
  to_audit_id   bigint NOT NULL,
  merkle_root   text NOT NULL,
  prev_root     text,
  anchored_at   timestamptz NOT NULL DEFAULT now()
);
```

For a pre-launch household product, privilege revocation plus off-box log shipping is
proportionate.

---

## 1.10 Backups and data protection

```sql
CREATE TABLE hub_backup_metadata (
  backup_id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  hub_id               uuid NOT NULL REFERENCES hubs,
  tenant_id            uuid NOT NULL,
  created_at           timestamptz NOT NULL,
  config_version       bigint NOT NULL,
  edge_schema_version  int NOT NULL,
  rollup_from          timestamptz,
  rollup_to            timestamptz,
  includes_network_key boolean NOT NULL DEFAULT false,
  object_key           text NOT NULL,       -- encrypted at rest
  size_bytes           bigint,
  checksum_sha256      text NOT NULL
);

CREATE INDEX ON hub_backup_metadata (hub_id, created_at DESC);
```

**The Zigbee network key is part of the backup.** Losing it means physically re-pairing every
device in the household by hand. It is stored encrypted, and restoring it is what lets the
`hub_replacements` flow complete without a site visit.

### Consent and data classification — Kenya DPA 2019

The governing regime is the **Data Protection Act 2019**, not GDPR. Household energy
telemetry is occupancy-revealing; combined with PIR sensors it shows when a home is empty.
That warrants explicit treatment.

```sql
CREATE TABLE consent_records (
  consent_id     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      uuid NOT NULL,
  user_id        uuid NOT NULL REFERENCES users,
  purpose        text NOT NULL CHECK (purpose IN
                   ('service_delivery','occupancy_analytics','nilm_disaggregation',
                    'marketing','research_aggregate','third_party_sharing')),
  granted        boolean NOT NULL,
  granted_at     timestamptz NOT NULL DEFAULT now(),
  withdrawn_at   timestamptz,
  policy_version text NOT NULL,
  evidence       jsonb              -- {method:'app_checkbox', ip, app_version}
);

CREATE INDEX ON consent_records (user_id, purpose, granted_at DESC);

CREATE TABLE data_classification (
  table_name     text NOT NULL,
  column_name    text NOT NULL,
  classification text NOT NULL CHECK (classification IN
                   ('public','internal','confidential','restricted')),
  dpa_category   text,            -- personal | sensitive personal (DPA 2019)
  retention_days int NOT NULL DEFAULT 730,
  mask_in_logs   boolean NOT NULL DEFAULT true,
  reviewed_at    timestamptz,
  reviewed_by    uuid REFERENCES users,
  PRIMARY KEY (table_name, column_name)
);
```

Outstanding obligations, tracked as programme items rather than schema: registration with
the Office of the Data Protection Commissioner as a data controller, a documented lawful
basis per processing purpose, and a data-subject access/erasure procedure.

---

## 1.11 Operational notes

- **Late-arriving data.** A hub offline beyond the continuous-aggregate `start_offset`
  triggers a targeted `refresh_continuous_aggregate()` for the affected window, followed by
  re-running the cost worker for that site and range.
- **Cost recomputation.** `cost_hourly` rows are recomputed, not appended, when
  `billing_periods.kwh_accumulated` is corrected by a token receipt or a KPLC bill.
- **Rounding.** Monetary values are stored at scale 6 and rounded to 2 decimals only at the
  API response or invoice boundary.
- **Deletion.** Tenant deletion is soft (`users.status`) followed by a scheduled hard purge;
  telemetry is deleted by `tenant_id` across all three resolutions plus
  `device_health_history`.
- **Certificate expiry.** Daily job over `certificates.not_after` raises `cert_expiring` at
  30 days.

---

# PART 2 — EDGE SCHEMA (SQLite, WAL mode)

Not a subset of the cloud schema. Integer keys, no UUID overhead, bounded footprint,
designed to survive unclean shutdown on an SD card.

```sql
PRAGMA journal_mode = WAL;
PRAGMA synchronous  = NORMAL;
PRAGMA foreign_keys = ON;
```

## 2.1 Schema versioning — required before first deployment

Without a version marker and a migration runner, the first schema change shipped over OTA
will brick hubs in the field. The daemon must refuse to start against an unknown future
schema rather than operate on data it may corrupt.

```sql
CREATE TABLE schema_migrations (
  version     INTEGER PRIMARY KEY,
  applied_at  INTEGER NOT NULL,
  description TEXT NOT NULL
);

INSERT INTO schema_migrations (version, applied_at, description)
VALUES (1, strftime('%s','now'), 'initial schema');
```

**Daemon startup contract:**

1. Read `MAX(version)` from `schema_migrations`.
2. If it exceeds the version this binary knows: **halt**, log, and report `schema_ahead` in
   the next heartbeat. Do not migrate downward; do not operate.
3. If lower: apply ordered migrations, each in its own transaction, recording every step.
4. Report `edge_schema_version` to the cloud on connect. The cloud refuses to push a config
   payload whose `min_edge_schema_version` exceeds it.

## 2.2 Core tables

```sql
CREATE TABLE meta (k TEXT PRIMARY KEY, v TEXT);
-- hub_id, site_id, tenant_id, config_version, tz, clock_conf,
-- last_ntp_sync, fw_version, cloud_last_ack_seq, zigbee_pan_id

CREATE TABLE device_cache (
  local_id      INTEGER PRIMARY KEY,
  device_uuid   TEXT UNIQUE NOT NULL,
  ieee_addr     TEXT UNIQUE NOT NULL,
  friendly_name TEXT,
  device_class  TEXT,
  metering_mode TEXT,
  is_critical   INTEGER NOT NULL DEFAULT 0,
  capabilities  TEXT,          -- JSON
  calibration   TEXT,          -- JSON
  retired       INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE samples (              -- ring buffer, capped by age and row count
  ts            INTEGER NOT NULL,   -- unix seconds
  local_id      INTEGER NOT NULL,
  watts         REAL,
  volts         REAL,
  amps          REAL,
  energy_wh_cum REAL,
  relay_state   INTEGER,
  clock_conf    INTEGER NOT NULL DEFAULT 2,
  PRIMARY KEY (local_id, ts)
) WITHOUT ROWID;

CREATE TABLE rollup_hourly (        -- never evicted
  hour_ts    INTEGER NOT NULL,
  local_id   INTEGER NOT NULL,
  energy_wh  REAL NOT NULL,
  avg_w      REAL,
  peak_w     REAL,
  clock_conf INTEGER NOT NULL,
  synced     INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (local_id, hour_ts)
) WITHOUT ROWID;

CREATE TABLE health_samples (       -- 15-minute cadence, 30-day local retention
  ts              INTEGER NOT NULL,
  local_id        INTEGER NOT NULL,
  lqi             INTEGER,
  rssi            INTEGER,
  battery_pct     INTEGER,
  reachable       INTEGER NOT NULL,
  parent_local_id INTEGER,
  synced          INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (local_id, ts)
) WITHOUT ROWID;
```

## 2.3 Rules, schedules, state

```sql
CREATE TABLE rules_cache (
  rule_id  TEXT PRIMARY KEY,
  mode_key TEXT,
  priority INTEGER,
  enabled  INTEGER,
  spec     TEXT NOT NULL         -- trigger + conditions + actions JSON
);

CREATE TABLE schedule_cache (
  entry_id  TEXT PRIMARY KEY,
  local_id  INTEGER,
  mode_key  TEXT,
  days_mask INTEGER,
  start_min INTEGER,             -- minutes since local midnight
  end_min   INTEGER,             -- may be < start_min: wraps past midnight
  action    TEXT,
  enabled   INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE mode_state (
  mode_key     TEXT PRIMARY KEY,
  is_active    INTEGER NOT NULL DEFAULT 0,
  priority     INTEGER,
  activated_at INTEGER
);

CREATE TABLE local_state (
  local_id       INTEGER PRIMARY KEY,
  desired_state  INTEGER,
  reported_state INTEGER,
  reachable      INTEGER NOT NULL DEFAULT 1,   -- distinct from 'off'
  last_seen_at   INTEGER,
  last_cmd_at    INTEGER,
  override_until INTEGER,
  updated_at     INTEGER
);
```

The scheduler evaluates `start_min > end_min` as a wrap, matching cloud semantics in §1.6.
The two implementations must agree; this is the single most likely place for cloud and edge
behaviour to diverge unnoticed, so it belongs in the shared test suite.

## 2.4 Command handling

```sql
CREATE TABLE cmd_queue (
  cmd_id          TEXT PRIMARY KEY,
  device_local_id INTEGER NOT NULL,
  payload         TEXT NOT NULL,
  idempotency_key TEXT NOT NULL,
  expires_at      INTEGER NOT NULL,
  status          TEXT NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending','sent','acked','failed','expired')),
  created_at      INTEGER NOT NULL,
  last_try_at     INTEGER,
  retry_count     INTEGER NOT NULL DEFAULT 0,
  last_error      TEXT
);

CREATE INDEX idx_cmd_queue_pending ON cmd_queue (expires_at) WHERE status = 'pending';

CREATE TABLE cmd_dedup (
  idempotency_key TEXT PRIMARY KEY,
  applied_at      INTEGER NOT NULL,
  result          TEXT
);
```

`cmd_queue` holds commands accepted while a Zigbee device is temporarily unreachable —
sleeping end devices, or a node whose parent router has dropped. Without it those commands
are simply lost.

`cmd_dedup` makes it safe for the app to send the same command over LAN and cloud
concurrently: the second arrival is a no-op returning the cached result.

## 2.5 Sync, alerts, tariff

```sql
CREATE TABLE outbox (
  seq            INTEGER PRIMARY KEY AUTOINCREMENT,
  kind           TEXT NOT NULL,   -- rollup | health | alert | event | ack | state | log
  payload        TEXT NOT NULL,
  priority       INTEGER NOT NULL DEFAULT 0,   -- higher drains first
  created_at     INTEGER NOT NULL,
  attempts       INTEGER NOT NULL DEFAULT 0,
  next_try_at    INTEGER,
  last_backoff_s INTEGER DEFAULT 60,
  last_error     TEXT
);

CREATE INDEX idx_outbox_pending ON outbox (priority DESC, next_try_at);

CREATE TABLE alert_state (
  dedup_key   TEXT PRIMARY KEY,
  alert_type  TEXT NOT NULL,
  local_id    INTEGER,
  opened_at   INTEGER NOT NULL,
  last_seen   INTEGER NOT NULL,
  peak_value  REAL,
  notified_at INTEGER,
  closed_at   INTEGER
);

CREATE TABLE tariff_cache (        -- enough to display KES with no internet
  schedule_id    TEXT PRIMARY KEY,
  bands_json     TEXT NOT NULL,
  levies_json    TEXT NOT NULL,
  effective_from TEXT
);

CREATE TABLE period_state (
  period_start    TEXT PRIMARY KEY,
  kwh_accumulated REAL NOT NULL DEFAULT 0,
  is_current      INTEGER NOT NULL DEFAULT 1
);
```

`priority` matters after a long outage: alerts and state changes must drain ahead of a week
of bulk rollups, or a critical notification arrives hours late.

## 2.6 Edge behaviours

- **Eviction order under pressure:** oldest `samples` first, then `health_samples`; never
  `rollup_hourly`. A week of raw at 1-minute resolution across 20 devices is roughly 200k
  rows — comfortable, and the cap makes the footprint deterministic.
- **`local_state.reachable`** separates *offline* from *off*. A relay module upstream of a
  flipped wall switch goes unreachable, not off; conflating them produces constant false
  alerts.
- **`tariff_cache` + `period_state`** let the local API return live KES with no internet.
  Cloud recomputes authoritatively on sync; edge figures are advisory and flagged as such.
- **Local API access logging goes to the system journal, not SQLite.** An audit row per HTTP
  request would compete with telemetry ingest for the same write lock.

---

# PART 3 — OPEN QUESTIONS

## 3.1 Band assignment for prepaid meters

Bands accumulate over the *utility's* billing month, but EcoTrack observes only consumption
downstream of its own sensors. For prepaid sites the true accumulator is unknowable without
token receipt parsing.

Until M-Pesa/SMS ingestion is live, `cost_hourly.is_estimated` stays `true` and the UI must
label the figure as an estimate. This is the single place where over-claiming accuracy will
cost user trust fastest.

## 3.2 Whole-home reconciliation

The sum of plug-level readings will not equal the `ct_main` reading. The gap is unmetered
load, modelled explicitly as an appliance with `appliance_type = 'unmetered'` bound to a
device with `metering_mode = 'none'`, rather than letting the two numbers silently disagree.

## 3.3 Physical override presentation

`local_state.reachable` and `device_current_state.reachable` distinguish unreachable from
off. The UX question remains open: should an unreachable device show as "off", "unknown", or
"check switch"? The data model supports all three; the decision belongs with user research.

## 3.4 Free-tier remote access

`plans.limits.remote_access` can express either model. Whether remote access is a paid
feature is an unmade product decision, not a schema question — but it should be settled
before pricing is published.
