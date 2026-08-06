/// GlassChart Demo — wraps a real fl_chart LineChart in liquid glass, with
/// axis-tick labels wired through GlassChart.adaptiveAxisLabel.
///
/// Run standalone:
///   flutter run -t example/lib/demos/glass_chart_demo.dart
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_liquid_glass_widgets/liquid_glass_widgets.dart';

class GlassChartDemo extends StatelessWidget {
  const GlassChartDemo({super.key});

  static const _thisWeek = [3, 4, 3.5, 5, 4.5, 6, 7];
  static const _lastWeek = [2, 2.5, 3, 3, 3.5, 4, 4];
  static const _weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  List<FlSpot> _spots(List<double> values) => [
        for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
      ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/wallpaper.jpg', fit: BoxFit.cover),
          Container(color: CupertinoColors.black.withValues(alpha: 0.25)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GlassChart',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GlassChart(
                    title: 'Weekly Active Users',
                    legend: const [
                      GlassChartLegendEntry(
                        color: CupertinoColors.activeBlue,
                        label: 'This week',
                      ),
                      GlassChartLegendEntry(
                        color: CupertinoColors.systemGrey,
                        label: 'Last week',
                      ),
                    ],
                    child: SizedBox(
                      height: 220,
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: 8,
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.round();
                                  if (index < 0 ||
                                      index >= _weekdayLabels.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: GlassChart.adaptiveAxisLabel(
                                      context,
                                      _weekdayLabels[index],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _spots(
                                _thisWeek.map((e) => e.toDouble()).toList(),
                              ),
                              isCurved: true,
                              color: CupertinoColors.activeBlue,
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: CupertinoColors.activeBlue
                                    .withValues(alpha: 0.15),
                              ),
                            ),
                            LineChartBarData(
                              spots: _spots(
                                _lastWeek.map((e) => e.toDouble()).toList(),
                              ),
                              isCurved: true,
                              color: CupertinoColors.systemGrey,
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
