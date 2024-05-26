import 'dart:core';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:circular_buffer/circular_buffer.dart';
import 'package:color_map/color_map.dart';
import 'package:fftea/fftea.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:soundeye/audiosource.dart';
import 'package:soundeye/constants.dart' as constants;

final logger = Logger('SoundEyeLogger');

final _fft = FFT(constants.BLOCK_SIZE);

class AudioData {
  late DateTime timestamp;
  late double power;
  // According to ISO 266
  late List<double> magnitudes;
  bool empty = false;

  AudioData(SampleBlock block) {
    timestamp = block.timestamp;

    List<double> fftRes = _fft.realFft(block.samples).discardConjugates().magnitudes();
    
    magnitudes = List.filled(constants.ISO_BINS.length, 0);
    
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
    }

    // print(magnitudes);

    for (int i = 0; i < magnitudes.length; i++) {
      if (magnitudes[i] < 0.1) {
        magnitudes[i] = 0;
      }

      magnitudes[i] = 20 * log(magnitudes[i]) / ln10 + 21;
    }

    double magPeak = magnitudes.reduce(max);
    for (int i = 0; i < magnitudes.length; i++) {
      magnitudes[i] /= magPeak;
    }

    double energy = block.samples.reduce((val, el) => val + el * el);
    power = energy / block.samples.length;

    // power = fftRes[0] / constants.BLOCK_SIZE;
  }

  AudioData.zero() {
    timestamp = DateTime.now();
    empty = true;
    power = 0.0;
    magnitudes = List.filled(constants.ISO_BINS.length, 0);
  }
}

class AudioDataTrack {
  static const int trackLength = 1024;

  CircularBuffer<AudioData> blocks = CircularBuffer(trackLength);

  AudioDataTrack() {
    for (int i = 0; i < blocks.capacity; i++) {
      blocks.add(AudioData.zero());
    }
  }

  void push(SampleBlock block) {
    blocks.add(AudioData(block));
  }

  Iterable<FlSpot> loudnessPoints() {
    return blocks
        .map((el) => el.power)
        .indexed
        .map((el) => FlSpot(el.$1.toDouble(), el.$2));
  }

  List<ScatterSpot> spectrogramPoints() {
    List<ScatterSpot> points = [];
    Colormap cmap = Colormaps.Spectral;
    for (int i = 0; i < trackLength; i++) {
      for (int j = 0; j < blocks[i].magnitudes.length; j++) {
        double datapoint = clampDouble(1 - blocks[i].magnitudes[j], 0, 1);

        double r = cmap(datapoint).x * 255;
        double g = cmap(datapoint).y * 255;
        double b = cmap(datapoint).z * 255;
        
        points.add(ScatterSpot(
          i.toDouble(),
          j.toDouble(),
          dotPainter: FlDotCirclePainter(
              color: Color.fromARGB(255, r.toInt(), g.toInt(), b.toInt()),
              radius: 1),
        ));
      }
    }
    return points;
  }
}
