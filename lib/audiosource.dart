import 'dart:async';
import 'dart:core';

import 'package:circular_buffer/circular_buffer.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:mic_stream/mic_stream.dart';

const int bufferSize = 1024;

final logger = Logger('SoundEyeLogger');

class SoundBlock {
  late DateTime timestamp;
  late List<double> samples;

  SoundBlock(this.samples) {
    timestamp = DateTime.now();
  }
}

class MicAudioSource with ChangeNotifier {
  bool active = false;

  late Stream<Uint8List> stream;
  late StreamSubscription listener;

  late int sSampleDepth;
  late int sSampleRate;
  late int sBufferSize;

  late SoundBlock finishedBlock;
  CircularBuffer<double> samples = CircularBuffer(bufferSize);
  int bufferHead = 0;

  void toggle() {
    if (active) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  SoundBlock _getSamples() {
    return SoundBlock(List.from(samples));
  }

  void _startRecording() async {
    MicStream.shouldRequestPermission(true);

    stream = MicStream.microphone(
      audioSource: AudioSource.DEFAULT,
      sampleRate: 48000,
      channelConfig: ChannelConfig.CHANNEL_IN_MONO,
      audioFormat: AudioFormat.ENCODING_PCM_16BIT);

    listener = stream
        .transform(MicStream.toSampleStream)
        .listen(_processSample);

    listener.onError((err, st) => logger.severe(err, st));
    sSampleDepth = await MicStream.bitDepth;
    sSampleRate = await MicStream.sampleRate;
    sBufferSize = await MicStream.bufferSize;
    active = true;
    
    logger.info("MicStream listener ON, buffer size: $sBufferSize");
  }

  void _stopRecording() {
    listener.cancel();
    active = false;
    logger.info("MicStream listener OFF");
  }

  void _processSample(pcmSample) async {
    double sample = 0;

    if (pcmSample is (int, int) || pcmSample is (double, double)) {
      sample = 0.5 * (pcmSample.$1 + pcmSample.$2);
    } else {
      sample = pcmSample.toDouble();
    }

    sample /= 32768;
    samples.add(sample);
    bufferHead += 1;

    if (bufferHead == bufferSize) {
      finishedBlock = _getSamples();
      bufferHead = 0;
      notifyListeners();
    }
  }
}