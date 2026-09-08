/// Backend role model (`backend_design.md`): a tenant-wide `users.role`, narrowed
/// per site by `site_members.role`. Same four values on both axes.
///
/// Q1 (2026-09-08): the app matches this exactly — no tenant/manager/admin
/// personas. Capability is gated by [effectiveRole].
enum Role {
  owner,
  member,
  viewer,
  installer;

  static Role fromApi(String value) => switch (value.toLowerCase()) {
    'owner' => owner,
    'member' => member,
    'viewer' => viewer,
    'installer' => installer,
    _ => viewer, // fail safe: least privilege
  };

  /// Rank for narrowing. `installer` ranks equal to `member` (its cross-site
  /// step-up requirement is enforced separately).
  int get _rank => switch (this) {
    owner => 3,
    member => 2,
    installer => 2,
    viewer => 1,
  };

  /// Effective permission is the **narrower** of the tenant role and the
  /// per-site role. No site membership row ⇒ tenant role applies.
  static Role effective(Role tenantRole, {Role? siteRole}) {
    if (siteRole == null) return tenantRole;
    return tenantRole._rank <= siteRole._rank ? tenantRole : siteRole;
  }
}

/// Capabilities checked by `RoleGuard` / `context.can(...)`. Keep this list
/// aligned with the plan §1.3 table.
enum Permission {
  viewDashboards,
  controlDevices,
  manageAutomation,
  acknowledgeAlerts,
  manageAppliances,
  manageSiteSettings,
  manageMembers,
  manageSubscription,
  deleteSite,
  commissionDevices,
  calibrateDevices,
  viewHubDiagnostics,
}

extension RoleCapabilities on Role {
  bool can(Permission p) {
    switch (this) {
      case Role.owner:
        return true;
      case Role.member:
        return const {
          Permission.viewDashboards,
          Permission.controlDevices,
          Permission.manageAutomation,
          Permission.acknowledgeAlerts,
          Permission.manageAppliances,
        }.contains(p);
      case Role.viewer:
        return p == Permission.viewDashboards;
      case Role.installer:
        return const {
          Permission.viewDashboards,
          Permission.controlDevices,
          Permission.commissionDevices,
          Permission.calibrateDevices,
          Permission.viewHubDiagnostics,
        }.contains(p);
    }
  }
}
