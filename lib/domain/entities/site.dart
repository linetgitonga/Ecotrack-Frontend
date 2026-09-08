import 'package:equatable/equatable.dart';

enum MeterType { prepaid, postpaid }

class Site extends Equatable {
  const Site({
    required this.id,
    required this.label,
    required this.meterType,
    this.timezone = 'Africa/Nairobi',
    this.status = 'active',
    this.kplcAccountNo,
    this.kplcMeterNo,
    this.supplyPhase = 'single',
    this.occupantCount,
    this.allowLanCommands = true,
    this.allowCloudCommands = true,
  });

  final String id;
  final String label;
  final MeterType meterType;
  final String timezone;
  final String status;
  final String? kplcAccountNo;
  final String? kplcMeterNo;
  final String supplyPhase;
  final int? occupantCount;
  final bool allowLanCommands;
  final bool allowCloudCommands;

  bool get isPrepaid => meterType == MeterType.prepaid;
  bool get isActive => status == 'active';

  static MeterType meterFromApi(String v) =>
      v == 'postpaid' ? MeterType.postpaid : MeterType.prepaid;

  @override
  List<Object?> get props => [id, label, meterType, status];
}

class Room extends Equatable {
  const Room({
    required this.id,
    required this.siteId,
    required this.name,
    this.type,
  });

  final String id;
  final String siteId;
  final String name;
  final String? type;

  @override
  List<Object?> get props => [id, siteId, name, type];
}

class SiteMember extends Equatable {
  const SiteMember({
    required this.id,
    required this.userId,
    required this.role,
    this.phoneE164,
    this.displayName,
    this.grantedAt,
  });

  final int id;
  final String userId;
  final String role; // owner | member | viewer | installer
  final String? phoneE164;
  final String? displayName;
  final DateTime? grantedAt;

  String get name => displayName?.trim().isNotEmpty == true
      ? displayName!
      : (phoneE164 ?? 'Member');

  @override
  List<Object?> get props => [id, userId, role];
}
