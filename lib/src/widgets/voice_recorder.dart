import 'dart:async';
import 'dart:convert';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;

class VoiceRecorder extends StatefulWidget {
  final double voiceLevel;
  const VoiceRecorder({super.key, required this.voiceLevel});

  @override
  State<StatefulWidget> createState() {
    return VoiceRecorderState();
  }
}

class VoiceRecorderState extends State<VoiceRecorder> {
  final String filePath = "/storage/emulated/0/recordedfile.wav";

  String soundType = '';
  String explanation = '';

  late AudioRecorder audioRecorder;

  @override
  void initState() {
    audioRecorder = AudioRecorder();
    super.initState();
  }

  Future<void> recordAudio() async {
    if (!(await Permission.manageExternalStorage.isGranted)) {
      await Permission.manageExternalStorage.request();
    }
    audioRecorder.start(const RecordConfig(encoder: AudioEncoder.wav),
        path: filePath);

    await Future.delayed(const Duration(seconds: 10));
    await audioRecorder.stop();

    classificationRequest();
  }

  Future<void> classificationRequest() async {
    Uri apiUrl = Uri.parse('http://10.0.2.2:5000/upload_audio');

    var request = http.MultipartRequest('POST', apiUrl);
    request.files.add(await http.MultipartFile.fromPath('audio', filePath));

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> responseJson = json.decode(responseBody);

        setState(() {
          soundType = responseJson['prediction'];
        });

        await gptRequest(widget.voiceLevel);

        if (kDebugMode) print(responseBody);
        if (kDebugMode) print('Dosya başarıyla gönderildi');
      } else {
        if (kDebugMode) print('Dosya gönderme hatası: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (kDebugMode) print('İstek hatası: $e');
    }
  }

  Future<void> gptRequest(double decibel) async {
    final openAI = OpenAI.instance.build(
        token: "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",
        baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 10)),
        enableLog: true);

    var response = await openAI.onChatCompletion(
        request: ChatCompleteText(model: Gpt4ChatModel(), messages: [
      Messages(
          role: Role.user,
          content:
              "${decibel.toStringAsFixed(4)} desibel $soundType sesinde ne kadar süre durmak kulağıma zarar verir")
    ]));

    setState(() {
      for (var element in response!.choices) {
        explanation = element.message != null ? element.message!.content : "";
      }
    });
    for (var element in response!.choices) {
      if (kDebugMode) print("data -> ${element.message?.content}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(soundType),
          const Spacer(),
          Flexible(
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Text(
                  explanation,
                )),
          ),
          const Spacer(),
          FloatingActionButton(
            onPressed: () => recordAudio(),
            child: const Icon(Icons.search),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    audioRecorder.dispose();
    super.dispose();
  }
}
