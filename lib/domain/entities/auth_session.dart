import 'package:equatable/equatable.dart';

/// A device session from `GET /auth/sessions`.
class AuthSession extends Equatable {
  const AuthSession({
    required this.id,
    required this.isCurrent,
    this.deviceName,
    this.ipAddress,
    this.loginAt,
    this.lastActivity,
    this.expiresAt,
  });

  final String id;
  final bool isCurrent;
  final String? deviceName;
  final String? ipAddress;
  final DateTime? loginAt;
  final DateTime? lastActivity;
  final DateTime? expiresAt;

  String get label =>
      deviceName?.trim().isNotEmpty == true ? deviceName! : 'Unknown device';

  @override
  List<Object?> get props => [id, isCurrent, deviceName, lastActivity];
}
