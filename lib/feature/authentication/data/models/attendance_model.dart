import 'dart:convert';

AttendanceModel AttendanceModelFromJson(String str) =>
    AttendanceModel.fromJson(json.decode(str));

String AttendanceModelToJson(AttendanceModel data) =>
    json.encode(data.toJson());

class AttendanceModel {
  final String? message;
  final AttendanceData? data;

  AttendanceModel({
    this.message,
    this.data,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      AttendanceModel(
        message: json["message"],
        data: json["data"] == null
            ? null
            : AttendanceData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class AttendanceData {
  final int? id;
  final String? attendanceDate;

  final String? checkInTime;
  final double? checkInLat;
  final double? checkInLng;
  final String? checkInLocation;
  final String? checkInAddress;

  final String? checkOutTime;
  final double? checkOutLat;
  final double? checkOutLng;
  final String? checkOutLocation;
  final String? checkOutAddress;

  final String? status;
  final String? alasanIzin;

  AttendanceData({
    this.id,
    this.attendanceDate,

    this.checkInTime,
    this.checkInLat,
    this.checkInLng,
    this.checkInLocation,
    this.checkInAddress,

    this.checkOutTime,
    this.checkOutLat,
    this.checkOutLng,
    this.checkOutLocation,
    this.checkOutAddress,

    this.status,
    this.alasanIzin,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) => AttendanceData(
        id: json["id"],
        attendanceDate: json["attendance_date"],

        checkInTime: json["check_in_time"],
        checkInLat: json["check_in_lat"]?.toDouble(),
        checkInLng: json["check_in_lng"]?.toDouble(),
        checkInLocation: json["check_in_location"],
        checkInAddress: json["check_in_address"],

        checkOutTime: json["check_out_time"],
        checkOutLat: json["check_out_lat"]?.toDouble(),
        checkOutLng: json["check_out_lng"]?.toDouble(),
        checkOutLocation: json["check_out_location"],
        checkOutAddress: json["check_out_address"],

        status: json["status"],
        alasanIzin: json["alasan_izin"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "attendance_date": attendanceDate,

        "check_in_time": checkInTime,
        "check_in_lat": checkInLat,
        "check_in_lng": checkInLng,
        "check_in_location": checkInLocation,
        "check_in_address": checkInAddress,

        "check_out_time": checkOutTime,
        "check_out_lat": checkOutLat,
        "check_out_lng": checkOutLng,
        "check_out_location": checkOutLocation,
        "check_out_address": checkOutAddress,

        "status": status,
        "alasan_izin": alasanIzin,
      };
}

