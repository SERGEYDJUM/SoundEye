import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:soundeye/audiodata.dart';

class PowerChart extends StatelessWidget {
  const PowerChart({super.key, required this.samples});

  final List<FlSpot> samples;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: LineChart(
        LineChartData(
          maxX: AudioDataTrack.trackLength.toDouble(),
          minX: 0,
          minY: 0,
          maxY: 1,
          lineBarsData: [
            LineChartBarData(
              spots: samples,
              color: Colors.black,
              isCurved: false,
              dotData: const FlDotData(
                show: false,
              ),
            ),
          ],
          lineTouchData: const LineTouchData(enabled: false),
          titlesData: const FlTitlesData(
            show: false,
          ),
        ),
        duration: Duration.zero,
      ),
    );
  }
}
