import 'package:dio/dio.dart';
import 'package:ecotrack/core/error/failure.dart';
import 'package:ecotrack/core/network/error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _resp(
  int status,
  Object? body, {
  Map<String, List<String>>? headers,
}) {
  final req = RequestOptions(path: '/x');
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: req,
      statusCode: status,
      data: body,
      headers: Headers.fromMap(headers ?? const {}),
    ),
  );
}

void main() {
  group('transport errors', () {
    final req = RequestOptions(path: '/x');
    test('connectionError → NetworkFailure', () {
      expect(
        ErrorMapper.fromDio(
          DioException(
            requestOptions: req,
            type: DioExceptionType.connectionError,
          ),
        ),
        isA<NetworkFailure>(),
      );
    });
    test('receiveTimeout → TimeoutFailure', () {
      expect(
        ErrorMapper.fromDio(
          DioException(
            requestOptions: req,
            type: DioExceptionType.receiveTimeout,
          ),
        ),
        isA<TimeoutFailure>(),
      );
    });
    test('badCertificate → CertificatePinFailure', () {
      expect(
        ErrorMapper.fromDio(
          DioException(
            requestOptions: req,
            type: DioExceptionType.badCertificate,
          ),
        ),
        isA<CertificatePinFailure>(),
      );
    });
  });

  group('backend error shape {"error":{"code","message"}}', () {
    test('401', () {
      final f = ErrorMapper.fromDio(
        _resp(401, {
          'error': {'code': 'INVALID_TOKEN', 'message': 'nope'},
        }),
      );
      expect(f, isA<UnauthorizedFailure>());
      expect(f.code, 'INVALID_TOKEN');
    });

    test('409 keeps the server message', () {
      final f = ErrorMapper.fromDio(
        _resp(409, {
          'error': {
            'code': 'CRITICAL_APPLIANCE',
            'message': 'Fridge is critical',
          },
        }),
      );
      expect(f, isA<ConflictFailure>());
      expect(f.message, 'Fridge is critical');
    });

    test('step-up code wins over the 403 status', () {
      final f = ErrorMapper.fromDio(
        _resp(403, {
          'error': {'code': 'STEP_UP_REQUIRED', 'message': 'verify'},
        }),
      );
      expect(f, isA<StepUpRequiredFailure>());
    });

    test('400 with field errors', () {
      final f = ErrorMapper.fromDio(
        _resp(400, {
          'error': {
            'code': 'VALIDATION',
            'message': 'bad',
            'fields': {
              'phone_e164': ['Enter a valid phone number'],
            },
          },
        }),
      );
      expect(f, isA<ValidationFailure>());
      expect(
        (f as ValidationFailure).fieldErrors['phone_e164'],
        'Enter a valid phone number',
      );
    });

    test('429 parses Retry-After header', () {
      final f = ErrorMapper.fromDio(
        _resp(
          429,
          {
            'error': {'message': 'slow down'},
          },
          headers: {
            'retry-after': ['30'],
          },
        ),
      );
      expect(f, isA<RateLimitedFailure>());
      expect((f as RateLimitedFailure).retryAfter, const Duration(seconds: 30));
    });

    test('500 → ServerFailure', () {
      expect(ErrorMapper.fromDio(_resp(500, null)), isA<ServerFailure>());
    });
  });

  group('RFC 7807 fallback (Tier B)', () {
    test('problem+json detail becomes the message', () {
      final f = ErrorMapper.fromDio(
        _resp(404, {
          'type': 'about:blank',
          'title': 'Not Found',
          'detail': 'Device 123 does not exist',
        }),
      );
      expect(f, isA<NotFoundFailure>());
      expect(f.message, 'Device 123 does not exist');
    });
  });
}
