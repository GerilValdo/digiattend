import 'dart:convert';
import 'dart:developer';
import 'package:digiattend/core/constants/endpoint.dart';
import 'package:digiattend/core/service/auth_local_storage.dart';
import 'package:http/http.dart' as http;

class AuthAPI {
  static Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    String profilePhoto = '',
    required int batchId,
    required int trainingId,
  }) async {
    final url = Uri.parse(Endpoint.register);

    final body = {
      "name": name,
      "email": email,
      "password": password,
      "jenis_kelamin": jenisKelamin,
      "profile_photo": profilePhoto,
      "batch_id": batchId.toString(),
      "training_id": trainingId.toString(),
    };

    final response = await http.post(
      url,
      headers: {"Accept": "application/json"},
      body: body,
    );

    log(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception(json.decode(response.body)["message"]);
    }
  }

  static Future<Map<String, dynamic>> loginUser({
  required String email,
  required String password,
}) async {
  final url = Uri.parse(Endpoint.login);

  final body = {
    "email": email,
    "password": password,
  };

  final response = await http.post(
    url,
    headers: {"Accept": "application/json"},
    body: body,
  );

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final token = jsonData["data"]["token"];
    final user = jsonData["data"]["user"];

    // SIMPAN KE LOCAL STORAGE
    await AuthLocalStorage.saveLoginData(
      token: token,
      user: user,
    );

    return jsonData["data"];
  } else {
    throw Exception(json.decode(response.body)["message"]);
  }
}


}
