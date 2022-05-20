import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';
import 'result_screen.dart';
import '../utils/utils.dart';

class QRCropScreen extends StatefulWidget {
  final XFile image;

  const QRCropScreen({Key? key, required this.image}) : super(key: key);

  @override
  State<QRCropScreen> createState() => QRCropScreenState();
}

class QRCropScreenState extends State<QRCropScreen> {
  final _cropKey = GlobalKey<CropState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _processCroppedImage().then((path) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QAResultsScreen(imageFilePath: path)),
              );
            });
          },
          child: const Icon(Icons.navigate_next),
        ),
        appBar: AppBar(title: const Text("Select the word")),
        body: Crop(image: Image.file(File(widget.image.path)).image, key: _cropKey));
  }

  Future<String> _processCroppedImage() async {
    String croppedFilePath = await QRUtils.getCroppedPath();
    final crop = _cropKey.currentState;
    if (crop != null) {
      Rect? area = crop.area;
      if (area != null) {
        final croppedFile =
            await ImageCrop.cropImage(file: File(widget.image.path), area: crop.area!);
        final file = File(croppedFilePath);
        if (file.existsSync()) {
          file.delete();
        }
        await file.writeAsBytes(await croppedFile.readAsBytes());
      }
    }
    return croppedFilePath;
  }
}
