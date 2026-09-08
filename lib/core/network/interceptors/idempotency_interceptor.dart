import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../constants/api_endpoints.dart';

/// Adds `Idempotency-Key: <uuid v4>` to actuating POSTs so the server (and the
/// edge `cmd_dedup`) apply a command exactly once — even when it travels over
/// both LAN and cloud.
///
/// A caller that already owns a key (a queued outbox item being retried) passes
/// it via `options.extra['idempotency_key']` and it is reused verbatim.
class IdempotencyInterceptor extends Interceptor {
  IdempotencyInterceptor({Uuid? uuid}) : _uuid = uuid ?? const Uuid();
  final Uuid _uuid;

  /// Path fragments whose POSTs actuate hardware / state.
  static const _actuatingFragments = <String>[
    '/commands',
    '/command',
    '/activate',
    '/deactivate',
    '/acknowledge',
    '/pairing-mode',
    '/resync',
  ];

  static const kExtraKey = 'idempotency_key';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method.toUpperCase();
    if (method == 'POST' && _needsKey(options.path)) {
      final existing = options.extra[kExtraKey] as String?;
      options.headers[ApiHeaders.idempotencyKey] = existing ?? _uuid.v4();
    }
    handler.next(options);
  }

  bool _needsKey(String path) =>
      _actuatingFragments.any((f) => path.contains(f));
}
