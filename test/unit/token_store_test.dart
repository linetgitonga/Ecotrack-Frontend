import 'dart:convert';

import 'package:ecotrack/core/auth/token_store.dart';
import 'package:ecotrack/data/local/preferences/secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemSecure extends Fake implements SecureStorage {
  String? _refresh;
  @override
  Future<String?> readRefreshToken() async => _refresh;
  @override
  Future<void> writeRefreshToken(String token) async => _refresh = token;
  @override
  Future<void> deleteRefreshToken() async => _refresh = null;
  @override
  Future<void> clearAuth() async => _refresh = null;
}

String _jwt(Map<String, dynamic> claims) {
  String seg(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${seg({'alg': 'HS256'})}.${seg(claims)}.sig';
}

void main() {
  late TokenStore store;

  setUp(() => store = TokenStore(_MemSecure()));

  test('decodes exp and refresh_jti from the access token', () {
    final exp =
        DateTime.now()
            .add(const Duration(minutes: 15))
            .millisecondsSinceEpoch ~/
        1000;
    store.setAccessToken(_jwt({'exp': exp, 'refresh_jti': 'jti-123'}));
    expect(store.hasAccessToken, isTrue);
    expect(store.isAccessTokenExpired, isFalse);
    expect(store.currentRefreshJti, 'jti-123');
  });

  test('reports an already-expired token', () {
    final past =
        DateTime.now()
            .subtract(const Duration(minutes: 1))
            .millisecondsSinceEpoch ~/
        1000;
    store.setAccessToken(_jwt({'exp': past}));
    expect(store.isAccessTokenExpired, isTrue);
  });

  test('setPair persists the refresh token; clear wipes both', () async {
    await store.setPair(
      access: _jwt({'exp': 9999999999}),
      refresh: 'refresh-abc',
    );
    expect(await store.readRefreshToken(), 'refresh-abc');
    await store.clear();
    expect(store.accessToken, isNull);
    expect(await store.readRefreshToken(), isNull);
  });

  test('single-flight refresh lock', () async {
    expect(store.beginRefresh(), isTrue);
    expect(store.beginRefresh(), isFalse);
    expect(store.isRefreshing, isTrue);

    var awaited = false;
    final f = store.awaitRefresh().then((_) => awaited = true);
    store.endRefresh();
    await f;
    expect(awaited, isTrue);
    expect(store.isRefreshing, isFalse);
  });

  test('garbage token does not throw', () {
    store.setAccessToken('not-a-jwt');
    expect(store.currentRefreshJti, isNull);
    expect(store.isAccessTokenExpired, isFalse);
  });
}
