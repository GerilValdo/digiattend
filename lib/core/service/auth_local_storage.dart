import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalStorage {
  static const String keyToken = "auth_token";
  static const String keyUser = "auth_user";

  /// Save token & user
  static Future<void> saveLoginData({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyToken, token);
    await prefs.setString(keyUser, jsonEncode(user));
  }

  /// Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyToken);
  }

  /// Get user (return Map)
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(keyUser);

    if (data == null) return null;
    return jsonDecode(data);
  }

  /// Remove token & user → Logout
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyToken);
    await prefs.remove(keyUser);
  }

    /// Update name only
  static Future<void> updateUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(keyUser);

    if (data == null) return;

    final map = jsonDecode(data);
    map["name"] = name;

    await prefs.setString(keyUser, jsonEncode(map));
  }

  /// Update profile photo only
  static Future<void> updateUserPhoto(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(keyUser);

    if (data == null) return;

    final map = jsonDecode(data);
    map["profile_photo"] = path;

    await prefs.setString(keyUser, jsonEncode(map));
  }

  /// Update full user data with UserModel copy
  static Future<void> updateUserModel(Map<String, dynamic> newUser) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(keyUser, jsonEncode(newUser));
}

}
