import 'dart:math';

import 'package:dio/dio.dart';
import 'package:ecotrack/data/remote/mock/fixtures.dart';
import 'package:flutter_test/flutter_test.dart';

RequestOptions _req(String path, {String method = 'GET', Object? data}) =>
    RequestOptions(path: path, method: method, data: data);

void main() {
  final rng = Random(1);

  test('handles Tier-B paths only', () {
    expect(MockFixtures.handles(_req('/telemetry/live')), isTrue);
    expect(MockFixtures.handles(_req('/costs/summary')), isTrue);
    expect(MockFixtures.handles(_req('/sites')), isFalse);
    expect(MockFixtures.handles(_req('/auth/otp/request')), isFalse);
  });

  test('telemetry/live returns a devices array with live readings', () {
    final (status, body) = MockFixtures.respond(_req('/telemetry/live'), rng)!;
    expect(status, 200);
    final devices = (body as Map)['devices'] as List;
    expect(devices, isNotEmpty);
    expect(devices.first, containsPair('device_id', isA<String>()));
    expect(devices.first['watts'], isA<num>());
  });

  test('costs/summary carries is_estimated + scale-6 strings', () {
    final (_, body) = MockFixtures.respond(_req('/costs/summary'), rng)!;
    final m = body as Map;
    expect(m['is_estimated'], isTrue);
    expect(m['kes_accumulated'], matches(RegExp(r'^\d+\.\d{6}$')));
  });

  test('device command returns an acked command', () {
    final (status, body) = MockFixtures.respond(
      _req('/devices/d-tv/commands', method: 'POST', data: {'state': 'off'}),
      rng,
    )!;
    expect(status, 202);
    expect((body as Map)['status'], 'acked');
  });

  test('activating a mode flips is_active', () {
    MockFixtures.respond(
      _req('/sites/s1/modes/m-away/activate', method: 'POST'),
      rng,
    );
    final (_, modes) = MockFixtures.respond(_req('/sites/s1/modes'), rng)!;
    final away = (modes as List).firstWhere((m) => m['mode_id'] == 'm-away');
    expect(away['is_active'], isTrue);
  });

  test('unknown Tier-B path returns null', () {
    expect(MockFixtures.respond(_req('/telemetry/unknown-thing'), rng), isNull);
  });
}
