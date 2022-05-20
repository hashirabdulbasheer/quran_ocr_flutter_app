import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:quran_ocr_app/screens/crop_screen.dart';

class QRTakePictureScreen extends StatefulWidget {
  const QRTakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  QRTakePictureScreenState createState() => QRTakePictureScreenState();
}

class QRTakePictureScreenState extends State<QRTakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Take a picture"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _capturePicture().then((imageFile) {
            if (imageFile != null) {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => QRCropScreen(image: imageFile)));
            }
            _controller.resumePreview();
          });
        },
        child: const Icon(Icons.camera_alt),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Column(
              children: [
                Expanded(child: CameraPreview(_controller)),
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<XFile?> _capturePicture() async {
    try {
      await _initializeControllerFuture;
      XFile imageFile = await _controller.takePicture();
      return imageFile;
    } catch (_) {}
    return null;
  }
}
