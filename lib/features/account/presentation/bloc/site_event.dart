part of 'site_bloc.dart';

sealed class SiteEvent extends Equatable {
  const SiteEvent();
  @override
  List<Object?> get props => [];
}

class SitesSubscribed extends SiteEvent {
  const SitesSubscribed();
}

class SitesRefreshed extends SiteEvent {
  const SitesRefreshed();
}

class SiteSelected extends SiteEvent {
  const SiteSelected(this.siteId);
  final String siteId;
  @override
  List<Object?> get props => [siteId];
}

class SiteCreated extends SiteEvent {
  const SiteCreated(this.body);
  final Map<String, dynamic> body;
  @override
  List<Object?> get props => [body];
}

class SiteUpdated extends SiteEvent {
  const SiteUpdated(this.siteId, this.body);
  final String siteId;
  final Map<String, dynamic> body;
  @override
  List<Object?> get props => [siteId, body];
}
