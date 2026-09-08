import 'package:equatable/equatable.dart';

import '../value_objects/phone_number.dart';
import '../value_objects/role.dart';

/// The signed-in user (from `/me`). `role` is the tenant-wide role; per-site
/// narrowing happens in `SiteContext` (Phase 4).
class User extends Equatable {
  const User({
    required this.id,
    required this.tenantId,
    required this.phone,
    required this.role,
    this.displayName,
    this.email,
    this.locale = 'en-KE',
    this.status = 'active',
    this.lastLoginAt,
  });

  final String id;
  final String tenantId;
  final PhoneNumber phone;
  final Role role;
  final String? displayName;
  final String? email;
  final String locale;
  final String status;
  final DateTime? lastLoginAt;

  String get name =>
      displayName?.trim().isNotEmpty == true ? displayName! : phone.national;

  bool get isActive => status == 'active';

  @override
  List<Object?> get props => [
    id,
    tenantId,
    phone.e164,
    role,
    displayName,
    status,
  ];
}
