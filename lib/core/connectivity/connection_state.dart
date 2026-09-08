import 'package:equatable/equatable.dart';

/// The four states the connection indicator can show (System_Design §13.1).
enum ConnectionMode {
  /// On the hub's LAN, pinned-TLS session active. Green.
  lan,

  /// Remote via the cloud API; hub reachable. Blue.
  cloud,

  /// Cloud reachable but the hub's last heartbeat is stale. Blue, controls off.
  cloudHubOffline,

  /// No connectivity — cached last-known state only. Red.
  offline,
}

extension ConnectionModeX on ConnectionMode {
  bool get isOnline => this != ConnectionMode.offline;

  /// Can the user actuate devices right now?
  bool get canControlDevices =>
      this == ConnectionMode.lan || this == ConnectionMode.cloud;

  /// Is long history / configuration available? (LAN API is bounded — §9.2.)
  bool get canReadHistory =>
      this == ConnectionMode.cloud || this == ConnectionMode.cloudHubOffline;

  bool get canEditConfiguration =>
      this == ConnectionMode.cloud || this == ConnectionMode.cloudHubOffline;
}

/// Immutable snapshot of the current connection.
class EcoConnection extends Equatable {
  const EcoConnection({
    required this.mode,
    required this.since,
    this.hubId,
    this.hubBaseUrl,
    this.lastDataAt,
  });

  factory EcoConnection.offline({DateTime? since, DateTime? lastDataAt}) =>
      EcoConnection(
        mode: ConnectionMode.offline,
        since: since ?? DateTime.fromMillisecondsSinceEpoch(0),
        lastDataAt: lastDataAt,
      );

  final ConnectionMode mode;
  final DateTime since;
  final String? hubId;

  /// `https://ecotrack-<serial>.local:8443/local/v1` when [mode] is `lan`.
  final String? hubBaseUrl;

  /// When cached data was last refreshed — drives "updated 12m ago".
  final DateTime? lastDataAt;

  EcoConnection copyWith({
    ConnectionMode? mode,
    DateTime? since,
    String? hubId,
    String? hubBaseUrl,
    DateTime? lastDataAt,
  }) => EcoConnection(
    mode: mode ?? this.mode,
    since: since ?? this.since,
    hubId: hubId ?? this.hubId,
    hubBaseUrl: hubBaseUrl ?? this.hubBaseUrl,
    lastDataAt: lastDataAt ?? this.lastDataAt,
  );

  @override
  List<Object?> get props => [mode, hubId, hubBaseUrl];
}
