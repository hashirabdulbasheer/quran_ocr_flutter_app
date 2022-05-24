import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:quran_ocr_app/models/result_model.dart';

class QRNetwork {

  /// TODO: Replace with the url of the backend server
  static const String url = "http://192.168.0.103:5000/ocr";

  /// Send the image to backend to perform OCR and determine the text in it
  static Future<List<QRResultModel>> getText(String filePath) async {
    // File file = await QRUtils.getImageFileFromAssets("assets/images/sample2.png");
    File file = File(filePath);
    var request = http.MultipartRequest('POST', Uri.parse(url));
    Map<String, String> headers = {"Content-type": "multipart/form-data"};
    request.files.add(
      http.MultipartFile('file', file.readAsBytes().asStream(), file.lengthSync(),
          filename: "sample.png", contentType: MediaType('image', 'png')),
    );
    request.headers.addAll(headers);
    final response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      return resultModelFromJson(respStr);
    }
    return [];
  }
}
