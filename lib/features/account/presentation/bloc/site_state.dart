part of 'site_bloc.dart';

enum SiteStatus { initial, loading, loaded, saving, error }

class SiteState extends Equatable {
  const SiteState({
    required this.status,
    required this.sites,
    this.selectedSiteId,
    this.siteRole,
    this.error,
  });

  const SiteState.initial()
    : status = SiteStatus.initial,
      sites = const [],
      selectedSiteId = null,
      siteRole = null,
      error = null;

  final SiteStatus status;
  final List<Site> sites;
  final String? selectedSiteId;

  /// Per-site role for the current user, once members are loaded for it.
  final Role? siteRole;
  final String? error;

  bool get hasNoSites => status == SiteStatus.loaded && sites.isEmpty;

  Site? get selectedSite {
    for (final s in sites) {
      if (s.id == selectedSiteId) return s;
    }
    return sites.isEmpty ? null : sites.first;
  }

  SiteState copyWith({
    SiteStatus? status,
    List<Site>? sites,
    String? selectedSiteId,
    Object? siteRole = _sentinel,
    Object? error = _sentinel,
  }) {
    return SiteState(
      status: status ?? this.status,
      sites: sites ?? this.sites,
      selectedSiteId: selectedSiteId ?? this.selectedSiteId,
      siteRole: identical(siteRole, _sentinel)
          ? this.siteRole
          : siteRole as Role?,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }

  static const _sentinel = Object();

  @override
  List<Object?> get props => [status, sites, selectedSiteId, siteRole, error];
}
