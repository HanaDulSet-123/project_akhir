// To parse this JSON data, do
//
//     final absenToday = absenTodayFromJson(jsonString);

import 'dart:convert';

AbsenToday absenTodayFromJson(String str) =>
    AbsenToday.fromJson(json.decode(str));

String absenTodayToJson(AbsenToday data) => json.encode(data.toJson());

class AbsenToday {
  String? message;
  Data? data;

  AbsenToday({this.message, this.data});

  factory AbsenToday.fromJson(Map<String, dynamic> json) => AbsenToday(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class Data {
  DateTime? attendanceDate;
  String? checkInTime;
  String? checkOutTime;
  String? checkInAddress;
  String? checkOutAddress;
  String? status;
  dynamic alasanIzin;

  Data({
    this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.checkInAddress,
    this.checkOutAddress,
    this.status,
    this.alasanIzin,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    attendanceDate: json["attendance_date"] == null
        ? null
        : DateTime.parse(json["attendance_date"]),
    checkInTime: json["check_in_time"],
    checkOutTime: json["check_out_time"],
    checkInAddress: json["check_in_address"],
    checkOutAddress: json["check_out_address"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
  );

  Map<String, dynamic> toJson() => {
    "attendance_date":
        "${attendanceDate!.year.toString().padLeft(4, '0')}-${attendanceDate!.month.toString().padLeft(2, '0')}-${attendanceDate!.day.toString().padLeft(2, '0')}",
    "check_in_time": checkInTime,
    "check_out_time": checkOutTime,
    "check_in_address": checkInAddress,
    "check_out_address": checkOutAddress,
    "status": status,
    "alasan_izin": alasanIzin,
  };
}
