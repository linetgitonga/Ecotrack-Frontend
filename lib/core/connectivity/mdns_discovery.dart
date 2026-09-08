import 'dart:async';
import 'dart:io' show InternetAddressType;

import 'package:injectable/injectable.dart';
import 'package:multicast_dns/multicast_dns.dart';

import '../constants/app_constants.dart';

/// A hub found on the LAN.
class DiscoveredHub {
  DiscoveredHub({
    required this.serial,
    required this.host,
    required this.port,
    this.address,
  });

  final String serial; // from the instance name: ecotrack-<serial>
  final String host; // ecotrack-<serial>.local
  final int port;
  final String? address; // resolved A record, if any

  String get baseUrl => 'https://${address ?? host}:$port/local/v1';
}

/// Resolves the `_ecotrack._tcp.local` service via mDNS. Web has no mDNS
/// (System_Design §13.2) — callers must not construct this there.
@lazySingleton
class MdnsDiscovery {
  MdnsDiscovery();

  /// Overridable in tests. Defaults to a real [MDnsClient].
  MDnsClient Function() clientFactory = MDnsClient.new;

  static const String _service = '${AppConstants.mdnsServiceType}.local';

  /// Returns the first hub that answers within [timeout], or null.
  Future<DiscoveredHub?> findFirst({
    Duration timeout = const Duration(seconds: 2),
  }) async {
    final all = await findAll(timeout: timeout, stopAfterFirst: true);
    return all.isEmpty ? null : all.first;
  }

  Future<List<DiscoveredHub>> findAll({
    Duration timeout = const Duration(seconds: 3),
    bool stopAfterFirst = false,
  }) async {
    final client = clientFactory();
    final results = <DiscoveredHub>[];
    try {
      await client.start();

      await for (final ptr
          in client
              .lookup<PtrResourceRecord>(
                ResourceRecordQuery.serverPointer(_service),
              )
              .timeout(timeout, onTimeout: (sink) => sink.close())) {
        SrvResourceRecord? srv;
        await for (final rec in client.lookup<SrvResourceRecord>(
          ResourceRecordQuery.service(ptr.domainName),
        )) {
          srv = rec;
          break;
        }
        if (srv == null) continue;

        String? addr;
        await for (final ip in client.lookup<IPAddressResourceRecord>(
          ResourceRecordQuery.addressIPv4(srv.target),
        )) {
          if (ip.address.type == InternetAddressType.IPv4) {
            addr = ip.address.address;
            break;
          }
        }

        results.add(
          DiscoveredHub(
            serial: _serialFrom(ptr.domainName, srv.target),
            host: srv.target,
            port: srv.port,
            address: addr,
          ),
        );
        if (stopAfterFirst) break;
      }
    } catch (_) {
      // mDNS not permitted / no responders — treat as "no hub".
    } finally {
      client.stop();
    }
    return results;
  }

  static String _serialFrom(String instance, String target) {
    final name = instance.split('.').first;
    if (name.startsWith('ecotrack-')) return name.substring('ecotrack-'.length);
    final host = target.split('.').first;
    return host.startsWith('ecotrack-')
        ? host.substring('ecotrack-'.length)
        : host;
  }
}
