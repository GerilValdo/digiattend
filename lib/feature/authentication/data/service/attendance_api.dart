import 'dart:convert';
import 'package:digiattend/core/constants/endpoint.dart';
import 'package:digiattend/core/service/auth_local_storage.dart';
import 'package:digiattend/feature/authentication/data/models/attendance_model.dart';
import 'package:http/http.dart' as http;

class AttendanceAPI {
  static Future<AttendanceModel> checkIn({
    required String attendanceDate,
    required String checkIn,
    required double lat,
    required double lng,
    required String address,
    required String status,
    String? alasanIzin,
  }) async {
    final url = Uri.parse(Endpoint.absenCheckIn);
    final token = await AuthLocalStorage.getToken();

    final body = {
      "attendance_date": attendanceDate,
      "check_in": checkIn,
      "check_in_lat": lat,
      "check_in_lng": lng,
      "check_in_address": address,
      "status": status,
      if (status == "izin") "alasan_izin": alasanIzin ?? "",
    };

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    final jsonRes = jsonDecode(response.body);

    return AttendanceModel.fromJson(jsonRes);
  }

  static Future<AttendanceModel> checkOut({
  required String attendanceDate,
  required String checkOut,
  required double lat,
  required double lng,
  required String address,
}) async {
  final url = Uri.parse(Endpoint.absenCheckOut);
  final token = await AuthLocalStorage.getToken();

  final body = {
    "attendance_date": attendanceDate,
    "check_out": checkOut,
    "check_out_lat": lat,
    "check_out_lng": lng,
    "check_out_location": "$lat,$lng",
    "check_out_address": address,
  };

  final response = await http.post(
    url,
    headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode(body),
  );

  final jsonRes = jsonDecode(response.body);

  return AttendanceModel.fromJson(jsonRes);
}

  static Future<List<AttendanceData>> getHistory() async {
  final url = Uri.parse(Endpoint.attendanceHistory);
  final token = await AuthLocalStorage.getToken();

  final response = await http.get(
    url,
    headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  final jsonRes = jsonDecode(response.body);

  if (response.statusCode == 200) {
    final List data = jsonRes["data"];
    return data.map((e) => AttendanceData.fromJson(e)).toList();
  } else {
    throw Exception(jsonRes["message"] ?? "Gagal mengambil history");
  }
}

}
