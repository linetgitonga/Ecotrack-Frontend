import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../app/themes/colors.dart';
import '../../core/extensions/context_extensions.dart';

/// A simple time-series line chart. [values] is Y in chronological order;
/// [labels] optionally labels the X ticks.
class UsageLineChart extends StatelessWidget {
  const UsageLineChart({
    super.key,
    required this.values,
    this.labels = const [],
    this.height = 180,
    this.color = EcoColors.primary,
    this.unitSuffix = '',
  });

  final List<double> values;
  final List<String> labels;
  final double height;
  final Color color;
  final String unitSuffix;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Not enough data yet',
            style: context.textTheme.bodySmall,
          ),
        ),
      );
    }
    final maxY = values.reduce((a, b) => a > b ? a : b) * 1.15;
    return SizedBox(
      height: height,
      child: Semantics(
        label:
            'Usage trend chart. Latest ${values.last.toStringAsFixed(0)}'
            '$unitSuffix.',
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY == 0 ? 1 : maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY / 3,
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  interval: maxY / 3 == 0 ? 1 : maxY / 3,
                  getTitlesWidget: (v, _) => Text(
                    v.toStringAsFixed(0),
                    style: context.textTheme.labelMedium,
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: labels.isNotEmpty,
                  reservedSize: 24,
                  interval: 1,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= labels.length) return const SizedBox();
                    return Text(
                      labels[i],
                      style: context.textTheme.labelMedium,
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  for (var i = 0; i < values.length; i++)
                    FlSpot(i.toDouble(), values[i]),
                ],
                isCurved: true,
                color: color,
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: color.withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontal "top consumers" bars with a label + value + share.
class ShareBars extends StatelessWidget {
  const ShareBars({super.key, required this.rows});

  /// (label, valueText, share 0..1)
  final List<(String, String, double)> rows;

  static const _palette = [
    EcoColors.primary,
    EcoColors.secondary,
    EcoColors.warning,
    Color(0xFF9B59B6),
    Color(0xFF95A5A6),
  ];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Breakdown: ${rows.map((r) => '${r.$1} ${r.$2}').join(', ')}',
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      rows[i].$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium,
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: rows[i].$3.clamp(0, 1),
                        minHeight: 10,
                        backgroundColor: context.colors.surfaceContainerHighest,
                        color: _palette[i % _palette.length],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Text(
                      rows[i].$2,
                      textAlign: TextAlign.end,
                      style: context.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
