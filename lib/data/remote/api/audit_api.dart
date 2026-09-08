import 'package:injectable/injectable.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/error/result.dart';
import '../../../core/network/dio_factory.dart';
import 'api_client.dart';

class AuditEntry {
  AuditEntry({
    required this.id,
    required this.actionType,
    required this.category,
    this.entity,
    this.createdAt,
  });

  final int id;
  final String actionType;
  final String category;
  final String? entity;
  final DateTime? createdAt;

  factory AuditEntry.fromJson(Map<String, dynamic> j) => AuditEntry(
    id: (j['id'] as num).toInt(),
    actionType: j['action_type']?.toString() ?? j['action']?.toString() ?? '',
    category: j['category']?.toString() ?? '',
    entity: j['entity']?.toString(),
    createdAt: DateTime.tryParse(j['created_at']?.toString() ?? ''),
  );
}

/// `GET /v1/audit-log` — the one Tier-A endpoint that IS cursor-paginated.
@lazySingleton
class AuditApi {
  AuditApi(@Named(DioNames.cloud) this._client);
  final ApiClient _client;

  Future<Result<({List<AuditEntry> items, String? nextCursor})>> list({
    String? cursor,
    int limit = 50,
  }) => _client.get<({List<AuditEntry> items, String? nextCursor})>(
    ApiPaths.auditLog,
    query: {'limit': limit, 'cursor': ?cursor},
    parse: (d) {
      final page = ApiEnvelope.paged(d);
      return (
        items: page.items.map(AuditEntry.fromJson).toList(),
        nextCursor: page.nextCursor,
      );
    },
  );
}
