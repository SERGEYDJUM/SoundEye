import 'package:fl_chart/fl_chart.dart';
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';
import 'package:soundeye/audiodata.dart';
import 'audiosource.dart';

final logger = Logger('SoundEyeLogger');

class SoundEye extends StatefulWidget {
  const SoundEye({super.key, required this.title});

  final String title;

  @override
  State<SoundEye> createState() => _SoundEyeState();
}

class _SoundEyeState extends State<SoundEye> {
  late AudioDataTrack audioTrack = AudioDataTrack();
  late MicAudioSource audioSource;

  void _onPause() {
    setState(() {
      audioSource.toggle();
    });
  }

  void _onNewBlock() {
    setState(() {
      audioTrack.push(audioSource.finishedBlock);
    });
  }

  @override
  void initState() {
    super.initState();
    audioSource = MicAudioSource();
    audioSource.addListener(_onNewBlock);
  }

  @override
  void dispose() {
    audioSource.removeListener(_onNewBlock);
    audioSource.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: 2,
              child: LineChart(
                LineChartData(
                  maxX: AudioDataTrack.trackLength.toDouble(),
                  minX: 0,
                  minY: -1,
                  maxY: 1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: audioTrack.lodnessPoints().toList(),
                      isCurved: false,
                      dotData: const FlDotData(
                        show: false,
                      ),
                    ),
                  ],
                ),
                duration: Duration.zero,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onPause,
        tooltip: 'Pause',
        child: (audioSource.active) ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
      ),
    );
  }
  //   return Scaffold(
  //     body: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: <Widget>[
  //           LineChart(
  //             LineChartData(
  //               minX: 0,
  //               maxX: AudioDataTrack.trackLength.toDouble(),
  //               minY: -50,
  //               maxY: 150,
  //               lineBarsData: [LineChartBarData(
  //                 spots: List.from(audioTrack.lodnessPoints()),
  //                 isCurved: true,
  //                 color: Colors.black
  //               )],
  //             )
  //           ),
  //           Text(
  //             audioTrack.blocks.last.loudness.toString(),
  //             style: Theme.of(context).textTheme.headlineMedium,
  //           ),
  //         ],
  //       ),
  //     ),
  //     floatingActionButton: FloatingActionButton(
  //       onPressed: _onPause,
  //       tooltip: 'Increment',
  //       child: const Icon(Icons.add),
  //     ), // This trailing comma makes auto-formatting nicer for build methods.
  //   );
  // }
}
