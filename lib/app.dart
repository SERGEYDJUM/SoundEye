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
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            // LineChart(
            //   LineChartData()
            // ),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              audioTrack.blocks.last.loudness.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onPause,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
