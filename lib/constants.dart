import 'dart:core';


// ignore: constant_identifier_names
const int BLOCK_SIZE = 1024;

// ignore: constant_identifier_names
const int SAMPLE_RATE = 48000;

// ignore: constant_identifier_names
const double BLOCK_DURATION = BLOCK_SIZE / SAMPLE_RATE;

// ignore: constant_identifier_names
const int TRACK_LENGTH = 512;

/// ignore: constant_identifier_names
const List<int> ISO_BINS_CENTERS = [31, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000];

// ignore: constant_identifier_names
const List<int> ISO_BINS = [44, 88, 177, 355, 710, 1420, 2840, 5680, 11360, 22720];

// ignore: constant_identifier_names
const List<String> ISO_BINS_LABELS = ["31", "63", "125", "250", "0.5K", "1K", "2K", "4K", "8K", "16K"];

// ignore: constant_identifier_names
// const int INTERNAL_BUFFER_SIZE = 2;