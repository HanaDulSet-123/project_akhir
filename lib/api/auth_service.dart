// lib/api/auth_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tugas_ujk/api/endpoint/endpoint.dart';
import 'package:tugas_ujk/models/edit_profile.dart';
import 'package:tugas_ujk/models/forog_password_model.dart';
import 'package:tugas_ujk/models/get_user_model.dart';
import 'package:tugas_ujk/models/register_user_model.dart';
import 'package:tugas_ujk/models/reset_password_model.dart'; // <-- Import model baru
import 'package:tugas_ujk/models/update_foto_model.dart';
import 'package:tugas_ujk/shared_preferenced/shared_preferenced.dart';

class AuthenticationAPI {
  /// REGISTER USER
  static Future<RegisterUserModel> registerUser({
    required String name,
    required String email,
    required String password,
    required String jk,
    File? imageFile,
    required int batchID,
    required int trainingID,
  }) async {
    final url = Uri.parse(Endpoint.register);

    String imageBase64 = "";
    if (imageFile != null) {
      final bytes = imageFile.readAsBytesSync();
      imageBase64 = base64Encode(bytes);
    }

    final response = await http.post(
      url,
      headers: {"Accept": "application/json"},
      body: {
        "name": name,
        "email": email,
        "password": password,
        "jenis_kelamin": jk,
        "profile_photo": imageBase64,
        "batch_id": batchID.toString(),
        "training_id": trainingID.toString(),
      },
    );

    final result = json.decode(response.body);
    if (response.statusCode == 200) {
      return RegisterUserModel.fromJson(result);
    } else {
      throw Exception(result["message"] ?? "Register gagal");
    }
  }

  /// LOGIN USER
  static Future<RegisterUserModel> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.login);

    final response = await http.post(
      url,
      headers: {"Accept": "application/json"},
      body: {"email": email, "password": password},
    );

    final result = json.decode(response.body);
    if (response.statusCode == 200) {
      final data = RegisterUserModel.fromJson(result);

      if (data.data?.token != null) {
        await PreferenceHandler.saveToken(data.data!.token!);
      }
      await PreferenceHandler.saveLogin();

      return data;
    } else {
      throw Exception(result["message"] ?? "Login gagal");
    }
  }

  /// GET PROFILE
  static Future<GetUserModel> getProfile() async {
    final url = Uri.parse(Endpoint.profile);
    final token = await PreferenceHandler.getToken();

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    final result = json.decode(response.body);
    if (response.statusCode == 200) {
      return GetUserModel.fromJson(result);
    } else {
      throw Exception(result["message"] ?? "Get profile gagal");
    }
  }

  /// UPDATE FOTO PROFILE
  static Future<EditFotoModel> updateFoto({File? imageFile}) async {
    final url = Uri.parse(Endpoint.editFoto);
    final token = await PreferenceHandler.getToken();

    String imageBase64 = "";
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      imageBase64 = base64Encode(bytes);
    }

    final response = await http.put(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"profile_photo": imageBase64}),
    );

    final result = json.decode(response.body);
    if (response.statusCode == 200) {
      return EditFotoModel.fromJson(result);
    } else {
      throw Exception(result["message"] ?? "Update foto gagal");
    }
  }

  /// UPDATE PROFILE (nama)
  static Future<EditProfile> updateProfile({required String name}) async {
    final url = Uri.parse(Endpoint.editProfile);
    final token = await PreferenceHandler.getToken();

    final response = await http.put(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"name": name}),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      return EditProfile.fromJson(result);
    } else {
      throw Exception(
        "Gagal memperbarui profil. Server merespons dengan status ${response.statusCode}",
      );
    }
  }

  /// LOGOUT
  static Future<void> logout() async {
    await PreferenceHandler.removeLogin();
    await PreferenceHandler.removeToken();
  }

  // =======================================================================
  // ===== FUNGSI BARU UNTUK FORGOT & RESET PASSWORD =====
  // =======================================================================

  /// FORGOT PASSWORD (Request OTP)
  static Future<ForgotPasswordModel> forgotPassword({
    required String email,
  }) async {
    final url = Uri.parse(Endpoint.forgotPassword);

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"email": email}),
    );

    final result = json.decode(response.body);
    if (response.statusCode == 200) {
      return ForgotPasswordModel.fromJson(result);
    } else {
      throw Exception(result["message"] ?? "Gagal mengirim permintaan reset");
    }
  }

  /// RESET PASSWORD (Submit OTP & New Password)
  static Future<ResetPasswordModel> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.resetPassword);

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"email": email, "otp": otp, "password": password}),
    );

    final result = json.decode(response.body);
    if (response.statusCode == 200) {
      return ResetPasswordModel.fromJson(result);
    } else {
      throw Exception(result["message"] ?? "Gagal mereset password");
    }
  }
}
