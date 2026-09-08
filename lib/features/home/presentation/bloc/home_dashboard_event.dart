part of 'home_dashboard_bloc.dart';

sealed class HomeDashboardEvent extends Equatable {
  const HomeDashboardEvent();
  @override
  List<Object?> get props => [];
}

class DashboardSubscribed extends HomeDashboardEvent {
  const DashboardSubscribed(this.siteId);
  final String siteId;
  @override
  List<Object?> get props => [siteId];
}

class DashboardRefreshed extends HomeDashboardEvent {
  const DashboardRefreshed();
}

class DashboardLiveTick extends HomeDashboardEvent {
  const DashboardLiveTick();
}

class DashboardModeSelected extends HomeDashboardEvent {
  const DashboardModeSelected(this.modeId);
  final String modeId;
  @override
  List<Object?> get props => [modeId];
}

class DashboardQuickToggled extends HomeDashboardEvent {
  const DashboardQuickToggled(this.deviceId);
  final String deviceId;
  @override
  List<Object?> get props => [deviceId];
}
