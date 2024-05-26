import 'dart:async';
import 'dart:core';

import 'package:circular_buffer/circular_buffer.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:soundeye/constants.dart' as constants;

final logger = Logger('SoundEyeLogger');

class SampleBlock {
  late DateTime timestamp;
  late List<double> samples;

  SampleBlock(this.samples) {
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

  CircularBuffer<SampleBlock> finishedBlocks = CircularBuffer(constants.INTERNAL_BUFFER_SIZE);
  int finishedBlocksCount = 0;
  CircularBuffer<double> samples = CircularBuffer(constants.BLOCK_SIZE);
  int bufferHead = 0;

  void toggle() {
    if (active) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  SampleBlock _getSamples() {
    return SampleBlock(List.from(samples));
  }

  void _startRecording() async {
    MicStream.shouldRequestPermission(true);

    stream = MicStream.microphone(
      audioSource: AudioSource.DEFAULT,
      sampleRate: constants.SAMPLE_RATE,
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
      sample = pcmSample.$1.toDouble();
    } else {
      sample = pcmSample.toDouble();
    }

    sample /= 32767;
    samples.add(sample);
    bufferHead += 1;

    if (bufferHead == constants.BLOCK_SIZE) {
      finishedBlocks.add(_getSamples());
      finishedBlocksCount += 1;
      bufferHead = 0;
      if (finishedBlocksCount == constants.INTERNAL_BUFFER_SIZE) {
        notifyListeners();
        finishedBlocksCount = 0;
      }
    }
  }
}