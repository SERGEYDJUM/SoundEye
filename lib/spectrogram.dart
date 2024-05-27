import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:soundeye/constants.dart' as constants;

class Spectrogram extends StatelessWidget {
  const Spectrogram(
      {super.key, required this.samples, required this.showLabels});

  final List<ScatterSpot> samples;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ScatterChart(
        ScatterChartData(
          minX: 0,
          maxX: constants.TRACK_LENGTH.toDouble() * 2,
          maxY: 10,
          minY: -1,
          scatterSpots: samples,
          borderData: FlBorderData(show: false),
          titlesData: (showLabels)
              ? FlTitlesData(
                  show: true,
                  bottomTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                      drawBelowEverything: false,
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int v = value.toInt();
                          String bandLabel =
                              (v >= 0 && v < constants.ISO_BINS_CENTERS.length)
                                  ? constants.ISO_BINS_LABELS[v]
                                  : "";

                          return Text(bandLabel,
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      )),
                )
              : const FlTitlesData(
                  show: false,
                ),
          scatterTouchData: ScatterTouchData(
            enabled: false,
          ),
        ),
        swapAnimationDuration: Duration.zero,
      ),
    );
  }
}
