import 'dart:core';
import 'dart:math';
import 'dart:ui';
import 'package:circular_buffer/circular_buffer.dart';
import 'package:color_map/color_map.dart';
import 'package:fftea/fftea.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:logging/logging.dart';
import 'package:soundeye/audiosource.dart';
import 'package:soundeye/constants.dart' as constants;

final logger = Logger('SoundEyeLogger');

final _fft = FFT(constants.BLOCK_SIZE);

// for (int i = pos; i < pos + size; i++)
// {
//         int j = i - pos; // j = index into Hann window function
//         signal_in[i] = (double)(signal_in[i] * 0.5 * (1.0 - Math.cos(2.0 * Math.PI * j / size)));
// }

class AudioData {
  late DateTime timestamp;
  late double power;
  // According to ISO 266
  late List<double> magnitudes;
  bool empty = false;

  AudioData(SampleBlock block) {
    timestamp = block.timestamp;

    double energy = block.samples.reduce((val, el) => val + el * el);
    power = energy / block.samples.length;
    
    if (power < 0.01) {
        power = 0;
    } else {
      power = 10 * log(power) / ln10 + 21;
    }

    // Windowing before FFT
    for (var i = 0; i < block.samples.length; i++) {
      double hamming = 0.54 - 0.46 * cos(2.0 * pi * i / block.samples.length);
      block.samples[i] *= hamming;
    }

    List<double> fftRes = _fft.realFft(block.samples).discardConjugates().magnitudes();
    
    magnitudes = List.filled(constants.ISO_BINS.length, 0);
    List<int> bandSizes = List.filled(constants.ISO_BINS.length,0);

    int currentBin = 0;
    for (int i = 1; i < constants.BLOCK_SIZE ~/ 2; i++) {
      int freq = i * constants.SAMPLE_RATE ~/ constants.BLOCK_SIZE;
      if (freq > constants.ISO_BINS[currentBin]) {
        if (freq > constants.ISO_BINS.last) {
          break;
        }
        currentBin += 1;
      }

      magnitudes[currentBin] += fftRes[i] / constants.BLOCK_SIZE;
      bandSizes[currentBin] += 1;
    }

    // print(magnitudes);

    for (int i = 0; i < magnitudes.length; i++) {
      magnitudes[i] /= bandSizes[i].clamp(1, 1000);

      // if (magnitudes[i] < 0.1) {
      //   magnitudes[i] = 0;
      // }

      // magnitudes[i] = 20 * log(magnitudes[i]) / ln10 + 21;
    }

    double magPeak = magnitudes.reduce(max);
    for (int i = 0; i < magnitudes.length; i++) {
      magnitudes[i] /= magPeak;
    }
  }

  AudioData.zero() {
    timestamp = DateTime.now();
    empty = true;
    power = 0.0;
    magnitudes = List.filled(constants.ISO_BINS.length, 0);
  }
}

class AudioDataTrack {
  CircularBuffer<AudioData> blocks = CircularBuffer(constants.TRACK_LENGTH);

  AudioDataTrack() {
    for (int i = 0; i < blocks.capacity; i++) {
      blocks.add(AudioData.zero());
    }
  }

  void push(SampleBlock block) {
    assert(block.timestamp.isAfter(blocks.last.timestamp));
    blocks.add(AudioData(block));
  }

  Iterable<FlSpot> loudnessPoints() {
    double avg = blocks.first.power;
    int w = 3;

    return blocks
        .map((el) {
          avg = (avg * (w-1) + el.power) / w;
          return avg;
        })
        .indexed
        .map((el) => FlSpot(el.$1.toDouble(), el.$2));
  }

  List<ScatterSpot> spectrogramPoints() {
    List<ScatterSpot> points = [];
    Colormap cmap = Colormaps.Spectral;
    for (int i = 0; i < constants.TRACK_LENGTH; i++) {
      for (int j = 0; j < blocks[i].magnitudes.length; j++) {
        double datapoint = clampDouble(1 - blocks[i].magnitudes[j], 0, 1);

        double r = cmap(datapoint).x * 255;
        double g = cmap(datapoint).y * 255;
        double b = cmap(datapoint).z * 255;
        
        points.add(ScatterSpot(
          i.toDouble() * 2,
          j.toDouble(),
          dotPainter: FlDotCirclePainter(
              color: Color.fromARGB(255, r.toInt(), g.toInt(), b.toInt()),
              radius: 2),
        ));
      }
    }
    return points;
  }
}
