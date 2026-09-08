import 'package:bloc_test/bloc_test.dart';
import 'package:ecotrack/core/error/result.dart';
import 'package:ecotrack/data/remote/api/tierb_api.dart';
import 'package:ecotrack/domain/entities/alert.dart';
import 'package:ecotrack/domain/entities/device.dart';
import 'package:ecotrack/domain/entities/site.dart';
import 'package:ecotrack/domain/value_objects/money.dart';
import 'package:ecotrack/features/manager/presentation/bloc/portfolio_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApi extends Mock implements TierBApi {}

Site _site(String id) =>
    Site(id: id, label: 'Site $id', meterType: MeterType.prepaid);

CostSummary _cost(double kes) => CostSummary(
  monthToDate: Money.fromDouble(kes),
  today: Money.zero,
  kwhAccumulated: 0,
  marginalRate: Money.zero,
  isEstimated: true,
);

AlertEvent _critical() => AlertEvent(
  id: 'a1',
  severity: AlertSeverity.critical,
  title: 'Spike',
  description: 'high load',
  openedAt: DateTime.now(),
);

void main() {
  late _MockApi api;

  setUp(() {
    api = _MockApi();
    when(() => api.summary(any())).thenAnswer(
      (_) async => const Ok(
        LiveUsage(liveWatts: 500, todayKwh: 4, todayKes: 0, isEstimated: true),
      ),
    );
  });

  blocTest<PortfolioCubit, PortfolioState>(
    'aggregates cost + watts across sites and collects critical alerts',
    setUp: () {
      when(() => api.costSummary('a')).thenAnswer((_) async => Ok(_cost(1000)));
      when(() => api.costSummary('b')).thenAnswer((_) async => Ok(_cost(500)));
      when(() => api.alerts('a')).thenAnswer((_) async => Ok([_critical()]));
      when(() => api.alerts('b')).thenAnswer((_) async => const Ok([]));
    },
    build: () => PortfolioCubit(api),
    act: (c) => c.load([_site('a'), _site('b')]),
    verify: (c) {
      final s = c.state;
      expect(s.unitCount, 2);
      expect(s.totalWatts, 1000);
      expect(s.totalMonthCost.asDouble, 1500);
      expect(s.totalOpenAlerts, 1);
      expect(s.criticalAlerts, hasLength(1));
      expect(s.criticalAlerts.first.siteLabel, 'Site a');
      expect(s.unitsNeedingAttention, 1);
    },
  );

  blocTest<PortfolioCubit, PortfolioState>(
    'empty site list → loaded with no units',
    build: () => PortfolioCubit(api),
    act: (c) => c.load([]),
    expect: () => [
      isA<PortfolioState>()
          .having((s) => s.loading, 'loading', false)
          .having((s) => s.units, 'units', isEmpty),
    ],
  );
}
