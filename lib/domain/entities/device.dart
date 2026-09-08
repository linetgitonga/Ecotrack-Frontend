import 'package:equatable/equatable.dart';

class Device extends Equatable {
  const Device({
    required this.id,
    required this.name,
    required this.deviceClass,
    required this.relayState,
    required this.reachable,
    this.roomId,
    this.roomName,
    this.watts = 0,
    this.volts,
    this.amps,
    this.lastSeenAt,
    this.switchable = true,
  });

  final String id;
  final String name;
  final String
  deviceClass; // smart_plug | light_node | relay_module | sensor | ...
  final bool relayState;
  final bool reachable;
  final String? roomId;
  final String? roomName;
  final double watts;
  final double? volts;
  final double? amps;
  final DateTime? lastSeenAt;
  final bool switchable;

  bool get isOn => relayState && reachable;

  /// UX §3.3 open question — we show unreachable as its own state, not "off".
  String get statusLabel =>
      !reachable ? 'Unreachable' : (relayState ? 'ON' : 'OFF');

  Device copyWith({bool? relayState, double? watts, bool? reachable}) => Device(
    id: id,
    name: name,
    deviceClass: deviceClass,
    relayState: relayState ?? this.relayState,
    reachable: reachable ?? this.reachable,
    roomId: roomId,
    roomName: roomName,
    watts: watts ?? this.watts,
    volts: volts,
    amps: amps,
    lastSeenAt: lastSeenAt,
    switchable: switchable,
  );

  @override
  List<Object?> get props => [id, name, relayState, reachable, watts, roomId];
}

class LiveUsage extends Equatable {
  const LiveUsage({
    required this.liveWatts,
    required this.todayKwh,
    required this.todayKes,
    required this.isEstimated,
    this.dailyBudgetKwh,
  });

  final double liveWatts;
  final double todayKwh;
  final double todayKes; // display value (KES, 2dp)
  final bool isEstimated;
  final double? dailyBudgetKwh;

  double? get budgetProgress => dailyBudgetKwh == null || dailyBudgetKwh == 0
      ? null
      : (todayKwh / dailyBudgetKwh!).clamp(0, 1);

  @override
  List<Object?> get props => [liveWatts, todayKwh, todayKes, isEstimated];
}

class EnergyMode extends Equatable {
  const EnergyMode({
    required this.id,
    required this.key,
    required this.name,
    required this.isActive,
  });

  final String id;
  final String key; // eco | home | away | night
  final String name;
  final bool isActive;

  @override
  List<Object?> get props => [id, key, isActive];
}
