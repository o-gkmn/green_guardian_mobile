import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:green_guardian/src/widgets/voice_meter.dart';
import 'package:green_guardian/src/widgets/voice_recorder.dart';
import 'package:green_guardian/src/widgets/voice_speed.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double voiceLevel = 0.0;
  NoiseReading? _latestReading;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseMeter? noiseMeter;

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    start();
    super.initState();
  }

  void onData(NoiseReading noiseReading) =>
      setState(() => _latestReading = noiseReading);

  void onError(Object error) {
    if (kDebugMode) print(error);

    stop();
  }

  Future<bool> checkPermission() async => await Permission.microphone.isGranted;

  Future<void> requestPermission() async {
    await Permission.microphone.request();
  }

  Future<void> start() async {
    noiseMeter ??= NoiseMeter();

    if (!(await checkPermission())) await requestPermission();

    _noiseSubscription = noiseMeter?.noise.listen(onData, onError: onError);
  }

  void stop() {
    _noiseSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Green Guardian"),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          VoiceMeter(
              position:
                  _latestReading != null ? _latestReading!.maxDecibel : 0),
          const Spacer(),
          Flexible(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                VoicePercent(
                    percentage: (_latestReading != null
                            ? _latestReading!.maxDecibel
                            : 0) /
                        5.2,
                    radius: 100),
                VoiceRecorder(voiceLevel: (_latestReading != null) ? _latestReading!.maxDecibel : 0.0,)
              ],
            ),
          ),
          const Spacer()
        ],
      ),
    );
  }
}
