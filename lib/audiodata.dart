import 'dart:core';
import 'dart:math';
import 'package:circular_buffer/circular_buffer.dart';
import 'package:fftea/fftea.dart';
import 'package:soundeye/audiosource.dart';

final _fft = FFT(bufferSize);

class AudioData {
  late DateTime timestamp;
  late double loudness;
  late List<double> magnitudes;
  bool empty = false;

  AudioData(SoundBlock block) {
    timestamp = block.timestamp;
    magnitudes = _fft.realFft(block.samples).magnitudes();

    double rms = sqrt(block.samples.reduce((v, el) => v + el*el) / block.samples.length);
    loudness = log(rms) / ln10 * 20.0;
  }

  AudioData.zero() {
    timestamp = DateTime.now();
    empty = true;
    loudness = 0.0;
    magnitudes = List.empty();
  }
}

class AudioDataTrack {
  static const double blockDuration = 1024 / 48000;
  static const int trackLength = 2048;

  CircularBuffer<AudioData> blocks = CircularBuffer(trackLength);
  
  AudioDataTrack() {
    for (int i = 0; i < blocks.capacity; i++) {
      blocks.add(AudioData.zero());
    }
  }

  void push(SoundBlock block) {
    blocks.add(AudioData(block));
  }

  List<double> getLoudnessPoints() {
    return List.from(blocks.map((el) => el.loudness));
  }
}