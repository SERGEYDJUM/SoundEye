import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:soundeye/audiodata.dart';

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
          maxX: AudioDataTrack.trackLength.toDouble(),
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
