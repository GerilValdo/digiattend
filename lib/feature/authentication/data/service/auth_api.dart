import 'dart:convert';
import 'package:digiattend/core/constants/endpoint.dart';
import 'package:digiattend/core/service/auth_local_storage.dart';
import 'package:digiattend/feature/authentication/data/models/user_model.dart';
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
    if (response.statusCode == 200 || response.statusCode == 201) return true;
    throw Exception(json.decode(response.body)["message"]);
  }

  static Future<String?> getBatchKeById(int batchId) async {
    final url = Uri.parse(Endpoint.trainingBatches);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body)["data"] as List;

      final batch = data.firstWhere(
        (b) => b["id"] == batchId,
        orElse: () => null,
      );

      return batch?["batch_ke"]?.toString();
    }

    return null;
  }

  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.login);

    final response = await http.post(
      url,
      headers: {"Accept": "application/json"},
      body: {"email": email, "password": password},
    );

    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)["message"]);
    }

    final jsonData = json.decode(response.body);
    final token = jsonData["data"]["token"];
    final user = jsonData["data"]["user"] as Map<String, dynamic>;

    // --- FIX: Ambil batch_ke berdasarkan batch_id ---
    final batchId = int.parse(user["batch_id"].toString());
    final batchKe = await getBatchKeById(batchId);

    // Simpan batch_ke ke dalam user
    user["batch_ke"] = batchKe;

    // Simpan ke local storage
    await AuthLocalStorage.saveLoginData(token: token, user: user);

    return jsonData["data"];
  }

  static Future<UserModel> updateProfileName(String name) async {
    final token = await AuthLocalStorage.getToken();
    final current = await AuthLocalStorage.getUser();
    final url = Uri.parse(Endpoint.updateProfile);

    final response = await http.put(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
      body: {"name": name},
    );

    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)["message"]);
    }

    // Ambil data baru dari server
    final data = json.decode(response.body)["data"] as Map<String, dynamic>;

    // --- FIX: Pertahankan batch_ke lama ---
    final updated = {...current!, ...data, "batch_ke": current["batch_ke"]};

    await AuthLocalStorage.updateUserModel(updated);
    return UserModel.fromJson(updated);
  }

  static Future<UserModel> updateProfilePhoto(String base64) async {
    final token = await AuthLocalStorage.getToken();
    final current = await AuthLocalStorage.getUser();

    final url = Uri.parse(Endpoint.updateProfilePhoto);

    final response = await http.put(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
      body: {"profile_photo": base64},
    );

    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)["message"]);
    }

    final data = json.decode(response.body)["data"];
    final newUrl = data["profile_photo"];

    // --- FIX: pertahankan batch_ke lama ---
    final updated = {
      ...current!,
      "profile_photo": newUrl,
      "batch_ke": current["batch_ke"],
    };

    await AuthLocalStorage.updateUserModel(updated);
    return UserModel.fromJson(updated);
  }
}
