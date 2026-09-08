/// Cloud REST paths, relative to `EnvConfig.apiBaseUrl` (which already ends in
/// `/v1`). **No trailing slashes** — the backend rejects them.
///
/// Grouped by resource. Tier A = implemented today (`backend_design.md`).
/// Tier B = specified in `System_Design §8`, called API-first with a mock
/// fallback (see plan §1.4 A2).
library;

abstract final class ApiPaths {
  // --- Auth & session (Tier A) -----------------------------------------
  static const String otpRequest = '/auth/otp/request';
  static const String otpResend = '/auth/otp/resend';
  static const String otpVerify = '/auth/otp/verify';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String sessions = '/auth/sessions';
  static String session(String id) => '/auth/sessions/$id';
  static const String sessionsRevokeAll = '/auth/sessions/revoke-all';
  static const String stepUpInitiate = '/auth/step-up/initiate';
  static const String stepUpVerify = '/auth/step-up/verify';

  // --- Current user (Tier A: /me, PATCH /me. Tier B: the rest) ---------
  static const String me = '/me';
  static const String mePreferences = '/me/preferences';
  static const String meConsents = '/me/consents';
  static String meConsent(String purpose) => '/me/consents/$purpose';
  static const String mePushTokens = '/me/push-tokens';
  static String mePushToken(String id) => '/me/push-tokens/$id';
  static const String meDataExport = '/me/data-export';
  static const String meDataErasure = '/me/data-erasure';

  // --- Sites / rooms / members (Tier A) --------------------------------
  static const String sites = '/sites';
  static String site(String id) => '/sites/$id';
  static String siteRooms(String siteId) => '/sites/$siteId/rooms';
  static String room(String id) => '/rooms/$id';
  static String siteMembers(String siteId) => '/sites/$siteId/members';
  static String siteMember(String siteId, String userId) =>
      '/sites/$siteId/members/$userId';
  static const String auditLog = '/audit-log';

  // --- Hubs (Tier B) --------------------------------------------------
  static const String hubs = '/hubs';
  static const String hubsClaim = '/hubs/claim';
  static String hub(String id) => '/hubs/$id';
  static String hubClaim(String id) => '/hubs/$id/claim';
  static String hubConnection(String id) => '/hubs/$id/connection';
  static String hubResync(String id) => '/hubs/$id/resync';
  static String hubPairingMode(String id) => '/hubs/$id/pairing-mode';
  static String hubDiagnostics(String id) => '/hubs/$id/diagnostics';
  static String hubBackups(String id) => '/hubs/$id/backups';
  static String hubReplace(String id) => '/hubs/$id/replace';
  static String hubCertificate(String id) => '/hubs/$id/certificate';

  // --- Devices / commissioning / appliances (Tier B) -----------------
  static const String devices = '/devices';
  static String device(String id) => '/devices/$id';
  static const String devicesCommissioning = '/devices/commissioning';
  static String deviceRetryCommissioning(String id) =>
      '/devices/$id/retry-commissioning';
  static String deviceCommands(String id) => '/devices/$id/commands';
  static String deviceHealth(String id) => '/devices/$id/health';
  static String command(String id) => '/commands/$id';
  static const String appliances = '/appliances';
  static String appliance(String id) => '/appliances/$id';
  static String applianceBindings(String id) => '/appliances/$id/bindings';
  static String binding(String id) => '/bindings/$id';

  // --- Telemetry / mesh / cost (Tier B) -----------------------------
  static const String telemetrySeries = '/telemetry/series';
  static const String telemetryLive = '/telemetry/live';
  static const String telemetrySummary = '/telemetry/summary';
  static const String meshHealth = '/mesh/health';
  static const String costsSeries = '/costs/series';
  static const String costsSummary = '/costs/summary';
  static const String costsBreakdown = '/costs/breakdown';
  static const String insights = '/insights';
  static const String exportsCsv = '/exports/csv';

  // --- Tariffs & billing (Tier B) ----------------------------------
  static const String tariffsCurrent = '/tariffs/current';
  static const String tariffSchedules = '/tariffs/schedules';
  static String siteBillingPeriod(String id) => '/sites/$id/billing-period';
  static String siteBillingPeriodReset(String id) =>
      '/sites/$id/billing-period/reset';
  static String siteTokenPurchases(String id) => '/sites/$id/token-purchases';

  // --- Modes / rules / schedules (Tier B) --------------------------
  static String siteModes(String siteId) => '/sites/$siteId/modes';
  static String modeActivate(String id) => '/modes/$id/activate';
  static String modeDeactivate(String id) => '/modes/$id/deactivate';
  static String siteRules(String siteId) => '/sites/$siteId/rules';
  static String rule(String id) => '/rules/$id';
  static String ruleTest(String id) => '/rules/$id/test';
  static String siteSchedules(String siteId) => '/sites/$siteId/schedules';
  static String schedule(String id) => '/schedules/$id';

  // --- Alerts / budgets (Tier B) ---------------------------------
  static String siteAlertDefinitions(String siteId) =>
      '/sites/$siteId/alert-definitions';
  static String alertDefinition(String id) => '/alert-definitions/$id';
  static const String alerts = '/alerts';
  static String alertAcknowledge(String id) => '/alerts/$id/acknowledge';
  static const String notifications = '/notifications';
  static String siteBudgets(String siteId) => '/sites/$siteId/budgets';
  static String budget(String id) => '/budgets/$id';

  // --- Subscription (Tier B) ------------------------------------
  static const String plans = '/plans';
  static const String subscription = '/subscription';
  static const String subscriptionChange = '/subscription/change';
  static const String subscriptionCancel = '/subscription/cancel';
  static const String subscriptionPayments = '/subscription/payments';

  // --- Realtime -------------------------------------------------------
  /// `wss://…/v1/stream?site_id=<uuid>` — see `EnvConfig.wssUrl`.
  static const String stream = '/stream';
}

/// Local hub API paths, relative to `https://ecotrack-<serial>.local:<port>/local/v1`.
abstract final class LanPaths {
  static const String identity = '/identity'; // unauthenticated
  static const String pair = '/pair';
  static const String state = '/state';
  static const String devices = '/devices';
  static String device(String ieee) => '/devices/$ieee';
  static String deviceCommand(String ieee) => '/devices/$ieee/command';
  static const String live = '/live';
  static const String today = '/today';
  static const String rollups = '/rollups';
  static const String alertsActive = '/alerts/active';
  static const String modes = '/modes';
  static String modeActivate(String key) => '/modes/$key/activate';
  static const String health = '/health';
  static const String events = '/events'; // WSS
}

/// Header names used across transports.
abstract final class ApiHeaders {
  static const String authorization = 'Authorization';
  static const String idempotencyKey = 'Idempotency-Key';
  static const String contentType = 'Content-Type';
  static const String retryAfter = 'Retry-After';
}
