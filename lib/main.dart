import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:noble_quran/models/word.dart';
import 'package:noble_quran/noble_quran.dart';
import 'screens/camera_screen.dart';

List<NQWord> qrWords = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MyApp(camera: firstCamera));
  _loadQuranWords();
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({super.key, required this.camera});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quran OCR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QRTakePictureScreen(camera: camera),
    );
  }
}

/// load and save the quran words in memory
_loadQuranWords() async {
  for (var i = 0; i < 114; i++) {
    List<List<NQWord>> words = await NobleQuran.getSurahWordByWord(i);
    for (List<NQWord> aya in words) {
      qrWords.addAll(aya);
    }
  }
}
