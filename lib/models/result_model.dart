// To parse this JSON data, do
//
//     final resultModel = resultModelFromJson(jsonString);

import 'dart:convert';

List<QRResultModel> resultModelFromJson(String str) =>
    List<QRResultModel>.from(json.decode(str).map((x) => QRResultModel.fromJson(x)));

String resultModelToJson(List<QRResultModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class QRResultModel {
  QRResultModel({
    required this.score,
    required this.text,
  });

  double score;
  String text;

  factory QRResultModel.fromJson(Map<String, dynamic> json) => QRResultModel(
        score: json["score"].toDouble(),
        text: json["text"],
      );

  Map<String, dynamic> toJson() => {
        "score": score,
        "text": text,
      };
}
