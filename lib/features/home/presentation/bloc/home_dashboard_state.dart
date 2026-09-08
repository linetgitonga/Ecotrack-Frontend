part of 'home_dashboard_bloc.dart';

enum DashboardStatus { initial, loading, loaded, error }

class HomeDashboardState extends Equatable {
  const HomeDashboardState({
    this.status = DashboardStatus.initial,
    this.usage,
    this.cost,
    this.modes = const [],
    this.quickDevices = const [],
    this.unreadAlerts = 0,
    this.error,
  });

  final DashboardStatus status;
  final LiveUsage? usage;
  final CostSummary? cost;
  final List<EnergyMode> modes;
  final List<Device> quickDevices;
  final int unreadAlerts;
  final String? error;

  EnergyMode? get activeMode {
    for (final m in modes) {
      if (m.isActive) return m;
    }
    return null;
  }

  HomeDashboardState copyWith({
    DashboardStatus? status,
    LiveUsage? usage,
    CostSummary? cost,
    List<EnergyMode>? modes,
    List<Device>? quickDevices,
    int? unreadAlerts,
    Object? error = _s,
  }) => HomeDashboardState(
    status: status ?? this.status,
    usage: usage ?? this.usage,
    cost: cost ?? this.cost,
    modes: modes ?? this.modes,
    quickDevices: quickDevices ?? this.quickDevices,
    unreadAlerts: unreadAlerts ?? this.unreadAlerts,
    error: identical(error, _s) ? this.error : error as String?,
  );

  static const _s = Object();

  @override
  List<Object?> get props => [
    status,
    usage,
    cost,
    modes,
    quickDevices,
    unreadAlerts,
    error,
  ];
}
