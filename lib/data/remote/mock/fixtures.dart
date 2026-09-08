import 'dart:math';

import 'package:dio/dio.dart';

/// Canned Tier-B responses shaped per System_Design §8. Deterministic per path
/// so the UI is stable between rebuilds; small random jitter on live values.
abstract final class MockFixtures {
  static final _devices = <Map<String, dynamic>>[
    _device('d-fridge', 'Kitchen fridge', 'smart_plug', 'r-kitchen', true, 120),
    _device('d-kettle', 'Kettle', 'smart_plug', 'r-kitchen', false, 0),
    _device('d-tv', 'Living room TV', 'smart_plug', 'r-living', true, 85),
    _device('d-iron', 'Iron', 'smart_plug', 'r-bedroom', false, 0),
    _device(
      'd-heater',
      'Water heater',
      'relay_module',
      'r-bathroom',
      true,
      2400,
    ),
    _device(
      'd-lights',
      'Living room lights',
      'light_node',
      'r-living',
      true,
      45,
    ),
  ];

  static final _rooms = <Map<String, dynamic>>[
    {'room_id': 'r-kitchen', 'name': 'Kitchen', 'room_type': 'kitchen'},
    {'room_id': 'r-living', 'name': 'Living room', 'room_type': 'living'},
    {'room_id': 'r-bedroom', 'name': 'Bedroom', 'room_type': 'bedroom'},
    {'room_id': 'r-bathroom', 'name': 'Bathroom', 'room_type': 'bathroom'},
  ];

  static final _modes = <Map<String, dynamic>>[
    {
      'mode_id': 'm-eco',
      'key': 'eco',
      'display_name': 'Eco',
      'is_active': true,
    },
    {
      'mode_id': 'm-home',
      'key': 'home',
      'display_name': 'Home',
      'is_active': false,
    },
    {
      'mode_id': 'm-away',
      'key': 'away',
      'display_name': 'Away',
      'is_active': false,
    },
    {
      'mode_id': 'm-night',
      'key': 'night',
      'display_name': 'Night',
      'is_active': false,
    },
  ];

  static final _alerts = <Map<String, dynamic>>[
    {
      'alert_event_id': 'a-1',
      'severity': 'warning',
      'alert_type': 'standby_waste',
      'title': 'TV drawing standby power',
      'description': 'Living room TV has used 0.4 kWh on standby today.',
      'opened_at': _hoursAgo(3),
      'closed_at': null,
      'acknowledged_at': null,
    },
    {
      'alert_event_id': 'a-2',
      'severity': 'critical',
      'alert_type': 'power_spike',
      'title': 'Unusual load on the water heater',
      'description': 'Sustained 2.4 kW for over 40 minutes.',
      'opened_at': _hoursAgo(1),
      'closed_at': null,
      'acknowledged_at': null,
    },
    {
      'alert_event_id': 'a-3',
      'severity': 'info',
      'alert_type': 'budget_threshold',
      'title': "You're at 80% of your weekly budget",
      'description': 'KES 640 of KES 800 used.',
      'opened_at': _hoursAgo(20),
      'closed_at': _hoursAgo(19),
      'acknowledged_at': _hoursAgo(19),
    },
  ];

  static bool handles(RequestOptions o) {
    final p = o.path;
    return p.contains('/devices') ||
        p.contains('/telemetry') ||
        p.contains('/costs') ||
        p.contains('/insights') ||
        p.contains('/modes') ||
        p.contains('/rules') ||
        p.contains('/schedules') ||
        p.contains('/budgets') ||
        p.contains('/alerts') ||
        p.contains('/appliances') ||
        p.contains('/tariffs') ||
        (p.contains('/sites/') && p.contains('/rooms')) ||
        p.contains('/hubs');
  }

  /// Returns `(statusCode, body)` or null to let the request through.
  static (int, Object)? respond(RequestOptions o, Random rng) {
    final p = o.path;
    final m = o.method.toUpperCase();

    if (p.endsWith('/telemetry/live')) {
      return (
        200,
        {'devices': _devices.map((d) => _liveReading(d, rng)).toList()},
      );
    }
    if (p.endsWith('/telemetry/summary')) {
      return (200, _telemetrySummary());
    }
    if (p.contains('/telemetry/series')) {
      return (200, {'points': _series(rng, 24)});
    }
    if (p.endsWith('/costs/summary')) {
      return (200, _costSummary());
    }
    if (p.endsWith('/costs/breakdown')) {
      return (200, {'appliances': _costBreakdown()});
    }
    if (p.contains('/costs/series')) {
      return (200, {'points': _series(rng, 7, cost: true)});
    }
    if (p.endsWith('/insights')) {
      return (200, {'recommendations': _insights()});
    }
    if (p.endsWith('/devices')) {
      return (200, _devices);
    }
    if (RegExp(r'/devices/[^/]+$').hasMatch(p) && m == 'GET') {
      final id = p.split('/').last;
      final d = _devices.firstWhere(
        (e) => e['device_id'] == id,
        orElse: () => _devices.first,
      );
      return (200, d);
    }
    if (p.contains('/devices/') && p.endsWith('/commands') && m == 'POST') {
      final action = (o.data is Map) ? (o.data as Map)['state'] : 'toggle';
      return (
        202,
        {
          'command_id': 'cmd-${rng.nextInt(99999)}',
          'status': 'acked',
          'state': action,
        },
      );
    }
    if (p.contains('/rooms')) {
      return (200, _rooms);
    }
    if (p.contains('/modes/') && p.endsWith('/activate') && m == 'POST') {
      final key = p.split('/')[p.split('/').indexOf('modes') + 1];
      for (final mode in _modes) {
        mode['is_active'] = mode['mode_id'] == key || mode['key'] == key;
      }
      return (200, {'ok': true});
    }
    if (p.contains('/modes')) {
      return (200, _modes);
    }
    if (p.contains('/rules')) {
      return (200, _rules());
    }
    if (p.contains('/schedules')) {
      return (200, _schedules());
    }
    if (p.contains('/budgets')) {
      return (200, _budgets());
    }
    if (p.contains('/alerts/') && p.endsWith('/acknowledge') && m == 'POST') {
      final id = p.split('/')[p.split('/').indexOf('alerts') + 1];
      for (final a in _alerts) {
        if (a['alert_event_id'] == id) a['acknowledged_at'] = _hoursAgo(0);
      }
      return (200, {'ok': true});
    }
    if (p.contains('/alerts')) {
      return (200, _alerts);
    }
    if (p.contains('/appliances')) {
      return (200, _appliances());
    }
    if (p.contains('/tariffs/current')) {
      return (200, _tariff());
    }
    if (p.contains('/hubs') && m == 'GET') {
      return (200, [_hub()]);
    }
    return null;
  }

  // --- builders ---------------------------------------------------

  static Map<String, dynamic> _device(
    String id,
    String name,
    String cls,
    String room,
    bool on,
    num watts,
  ) => {
    'device_id': id,
    'friendly_name': name,
    'device_class': cls,
    'room_id': room,
    'relay_state': on,
    'reachable': true,
    'watts': watts,
    'last_seen_at': _hoursAgo(0),
    'capabilities': {'switch': cls != 'sensor', 'metering': true},
  };

  static Map<String, dynamic> _liveReading(Map<String, dynamic> d, Random rng) {
    final base = (d['watts'] as num).toDouble();
    final jitter = base == 0 ? 0.0 : base * (rng.nextDouble() * 0.1 - 0.05);
    return {
      'device_id': d['device_id'],
      'watts': (base + jitter).clamp(0, double.infinity),
      'volts': 238 + rng.nextInt(6),
      'amps': ((base + jitter) / 240).toStringAsFixed(2),
      'relay_state': d['relay_state'],
      'reachable': true,
    };
  }

  static Map<String, dynamic> _telemetrySummary() => {
    'live_watts': 2775,
    'today_kwh': 8.42,
    'today_kwh_estimated': true,
    'yesterday_kwh': 11.05,
    'daily_budget_kwh': 12.0,
  };

  static Map<String, dynamic> _costSummary() => {
    'period': 'monthly',
    'kwh_accumulated': '182.400000',
    'kes_accumulated': '4231.850000',
    'marginal_rate': '27.540000',
    'band_position': 'band 2 of 3',
    'is_estimated': true,
    'estimate_reason': 'prepaid_band_unknown',
    'today_kes': '236.400000',
  };

  static List<Map<String, dynamic>> _costBreakdown() => [
    {
      'label': 'Water heater',
      'kes': '1683.200000',
      'share': 0.40,
      'appliance_id': 'ap-heater',
    },
    {
      'label': 'Fridge',
      'kes': '846.400000',
      'share': 0.20,
      'appliance_id': 'ap-fridge',
    },
    {
      'label': 'Lighting',
      'kes': '592.500000',
      'share': 0.14,
      'appliance_id': 'ap-lights',
    },
    {
      'label': 'TV & electronics',
      'kes': '423.200000',
      'share': 0.10,
      'appliance_id': 'ap-tv',
    },
    {
      'label': 'Other (unmetered)',
      'kes': '686.350000',
      'share': 0.16,
      'appliance_id': null,
    },
  ];

  static Map<String, dynamic> _tariff() => {
    'schedule_id': 't-2026',
    'code': 'DC',
    'bands': [
      {
        'band_order': 1,
        'min_kwh': 0,
        'max_kwh': 30,
        'energy_kes_per_kwh': '16.500000',
      },
      {
        'band_order': 2,
        'min_kwh': 30,
        'max_kwh': 100,
        'energy_kes_per_kwh': '27.540000',
      },
      {
        'band_order': 3,
        'min_kwh': 100,
        'max_kwh': null,
        'energy_kes_per_kwh': '32.700000',
      },
    ],
    'levies': [
      {'code': 'FCC', 'display_name': 'Fuel cost charge', 'rate': '3.180000'},
      {'code': 'FOREX', 'display_name': 'Forex adjustment', 'rate': '1.040000'},
      {'code': 'EPRA', 'display_name': 'EPRA levy', 'rate': '0.080000'},
      {'code': 'VAT', 'display_name': 'VAT (16%)', 'rate': '0.160000'},
    ],
  };

  static List<Map<String, dynamic>> _series(
    Random rng,
    int n, {
    bool cost = false,
  }) {
    final now = DateTime.now();
    return List.generate(n, (i) {
      final t = now.subtract(
        Duration(hours: cost ? 0 : n - i, days: cost ? n - i : 0),
      );
      final v = cost ? 150 + rng.nextInt(120) : 300 + rng.nextInt(2500);
      return {'t': t.toIso8601String(), 'value': v};
    });
  }

  static List<Map<String, dynamic>> _insights() => [
    {
      'id': 'ins-1',
      'title': 'Shift the water heater to off-peak',
      'detail': 'Running it 22:00–05:00 could save about KES 480/month.',
      'severity': 'tip',
      'estimated_saving_kes': '480.000000',
    },
    {
      'id': 'ins-2',
      'title': 'TV standby is costing you',
      'detail': 'About KES 90/month. A smart plug schedule fixes it.',
      'severity': 'tip',
      'estimated_saving_kes': '90.000000',
    },
  ];

  static List<Map<String, dynamic>> _rules() => [
    {
      'rule_id': 'ru-1',
      'name': 'Turn off iron after 30 min',
      'enabled': true,
      'trigger': {
        'type': 'power',
        'device_id': 'd-iron',
        'op': '>',
        'watts': 800,
        'for_s': 1800,
      },
      'actions': [
        {'type': 'switch', 'state': 'off'},
      ],
    },
    {
      'rule_id': 'ru-2',
      'name': 'Lights off when away',
      'enabled': true,
      'trigger': {'type': 'mode_enter', 'mode_key': 'away'},
      'actions': [
        {'type': 'switch', 'state': 'off'},
      ],
    },
  ];

  static List<Map<String, dynamic>> _schedules() => [
    {
      'schedule_entry_id': 'sc-1',
      'appliance_id': 'ap-heater',
      'days_mask': 127,
      'start_local': '22:00',
      'end_local': '05:00',
      'action': 'on',
      'enabled': true,
    },
  ];

  static List<Map<String, dynamic>> _budgets() => [
    {
      'budget_id': 'b-1',
      'period': 'weekly',
      'limit_kes': '800.00',
      'warn_at_pct': 80,
      'spent_kes': '624.30',
      'action_on_breach': 'notify',
      'enabled': true,
    },
  ];

  static List<Map<String, dynamic>> _appliances() => [
    {
      'appliance_id': 'ap-fridge',
      'name': 'Kitchen fridge',
      'appliance_type': 'fridge',
      'is_critical': true,
    },
    {
      'appliance_id': 'ap-heater',
      'name': 'Water heater',
      'appliance_type': 'water_heater',
      'is_critical': false,
    },
    {
      'appliance_id': 'ap-tv',
      'name': 'Living room TV',
      'appliance_type': 'tv',
      'is_critical': false,
    },
    {
      'appliance_id': 'ap-lights',
      'name': 'Living room lights',
      'appliance_type': 'lighting',
      'is_critical': false,
    },
  ];

  static Map<String, dynamic> _hub() => {
    'hub_id': 'hub-1',
    'serial': 'EC0T1234',
    'status': 'active',
    'fw_version': '1.4.2',
    'last_seen_at': _hoursAgo(0),
    'uplink_type': 'wifi',
  };

  static String _hoursAgo(int h) =>
      DateTime.now().subtract(Duration(hours: h)).toIso8601String();
}
