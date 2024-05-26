import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:soundeye/constants.dart' as constants;

class Spectrogram extends StatelessWidget {
  const Spectrogram({super.key, required this.samples});

  final List<ScatterSpot> samples;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ScatterChart(
        ScatterChartData(
          minX: 0,
          maxX: constants.TRACK_LENGTH.toDouble(),
          maxY: 10,
          minY: 0,
          scatterSpots: samples,
          titlesData: const FlTitlesData(
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
