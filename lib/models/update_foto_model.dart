// To parse this JSON data, do
//
//     final editFotoModel = editFotoModelFromJson(jsonString);

import 'dart:convert';

EditFotoModel editFotoModelFromJson(String str) =>
    EditFotoModel.fromJson(json.decode(str));

String editFotoModelToJson(EditFotoModel data) => json.encode(data.toJson());

class EditFotoModel {
  String? message;
  Data? data;

  EditFotoModel({this.message, this.data});

  factory EditFotoModel.fromJson(Map<String, dynamic> json) => EditFotoModel(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class Data {
  String? profilePhoto;

  Data({this.profilePhoto});

  factory Data.fromJson(Map<String, dynamic> json) =>
      Data(profilePhoto: json["profile_photo"]);

  Map<String, dynamic> toJson() => {"profile_photo": profilePhoto};
}
