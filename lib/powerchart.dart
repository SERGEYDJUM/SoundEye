import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:soundeye/constants.dart' as constants;

class PowerChart extends StatelessWidget {
  const PowerChart(
      {super.key, required this.samples, required this.showTitles});

  final List<FlSpot> samples;
  final bool showTitles;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: LineChart(
        LineChartData(
          maxX: constants.TRACK_LENGTH.toDouble(),
          minX: 0,
          minY: 0,
          maxY: 21,
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
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) => touchedSpots
                  .map((e) => LineTooltipItem(
                        "-${((constants.TRACK_LENGTH - e.x) * constants.BLOCK_DURATION).toStringAsFixed(3)} s, ${e.y.toStringAsFixed(2)}",
                        const TextStyle(),
                      ))
                  .toList(),
            ),
          ),
          titlesData: (showTitles)
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
                          String bandLabel = v.toString();

                          return Text(
                            bandLabel, 
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.visible, 
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      )),
                )
              : const FlTitlesData(show: false),
          borderData: FlBorderData(
            border: const Border(
              top: BorderSide.none,
              left: BorderSide.none,
              right: BorderSide.none,
              bottom: BorderSide(),
            ),
          ),
        ),
        duration: Duration.zero,
      ),
    );
  }
}
