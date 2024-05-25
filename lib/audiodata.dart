import 'dart:core';
import 'dart:math';
import 'package:circular_buffer/circular_buffer.dart';
import 'package:fftea/fftea.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:logging/logging.dart';
import 'package:soundeye/audiosource.dart';

final logger = Logger('SoundEyeLogger');

final _fft = FFT(bufferSize);

class AudioData {
  late DateTime timestamp;
  late double power;
  late List<double> magnitudes;
  bool empty = false;

  AudioData(SoundBlock block) {
    timestamp = block.timestamp;
    magnitudes = _fft.realFft(block.samples).magnitudes();

    double energy = block.samples.reduce((val, el) => val + el*el);
    power = energy / block.samples.length;
  }

  AudioData.zero() {
    timestamp = DateTime.now();
    empty = true;
    power = 0.0;
    magnitudes = List.empty();
  }
}

class AudioDataTrack {
  static const double blockDuration = 1024 / 48000;
  static const int trackLength = 1024;

  CircularBuffer<AudioData> blocks = CircularBuffer(trackLength);
  
  AudioDataTrack() {
    for (int i = 0; i < blocks.capacity; i++) {
      blocks.add(AudioData.zero());
    }
  }

  void push(SoundBlock block) {
    blocks.add(AudioData(block));
  }

  Iterable<double> getLoudnessPoints() {
    return blocks.map((el) => el.power);
  }

  Iterable<FlSpot> lodnessPoints() {
    return getLoudnessPoints().indexed.map((el) => FlSpot(el.$1.toDouble(), el.$2));
  }
}