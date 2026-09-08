import 'package:equatable/equatable.dart';

enum AlertSeverity { info, warning, critical }

enum AlertStatus { open, acknowledged, closed }

class AlertEvent extends Equatable {
  const AlertEvent({
    required this.id,
    required this.severity,
    required this.title,
    required this.description,
    required this.openedAt,
    this.type,
    this.closedAt,
    this.acknowledgedAt,
  });

  final String id;
  final AlertSeverity severity;
  final String title;
  final String description;
  final DateTime openedAt;
  final String? type;
  final DateTime? closedAt;
  final DateTime? acknowledgedAt;

  AlertStatus get status {
    if (closedAt != null) return AlertStatus.closed;
    if (acknowledgedAt != null) return AlertStatus.acknowledged;
    return AlertStatus.open;
  }

  static AlertSeverity severityFromApi(String v) => switch (v) {
    'critical' => AlertSeverity.critical,
    'warning' => AlertSeverity.warning,
    _ => AlertSeverity.info,
  };

  @override
  List<Object?> get props => [id, severity, title, closedAt, acknowledgedAt];
}
