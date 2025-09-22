// To parse this JSON data, do
//
//     final listTrainingModel = listTrainingModelFromJson(jsonString);

import 'dart:convert';

ListTrainingModel listTrainingModelFromJson(String str) =>
    ListTrainingModel.fromJson(json.decode(str));

String listTrainingModelToJson(ListTrainingModel data) =>
    json.encode(data.toJson());

class ListTrainingModel {
  String? message;
  List<TrainingData>? data; // <-- UBAH TIPE LIST INI

  ListTrainingModel({this.message, this.data});

  factory ListTrainingModel.fromJson(Map<String, dynamic> json) =>
      ListTrainingModel(
        message: json["message"],
        data: json["data"] == null
            ? []
            // V-- UBAH MAPPING KE CLASSS BARU
            : List<TrainingData>.from(
                json["data"]!.map((x) => TrainingData.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

// UBAH NAMA CLASS DARI Datum MENJADI TrainingData
class TrainingData {
  int? id;
  String? title;

  TrainingData({this.id, this.title});

  factory TrainingData.fromJson(Map<String, dynamic> json) =>
      TrainingData(id: json["id"], title: json["title"]);

  Map<String, dynamic> toJson() => {"id": id, "title": title};
}
