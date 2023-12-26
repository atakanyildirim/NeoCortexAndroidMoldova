import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:neocortexapp/config/app/app_config.dart';
import 'package:neocortexapp/core/Helper/string.dart';
import 'package:neocortexapp/presentation/pages/tutorial_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthenticateManager {
  String? _token;
  String? _fullname;
  String? _projectId;
  String? _projectName;
  String? _email;
  String? _userID;

  static Future<http.Response> attempt(String email, String password, String version) {
    return http.post(Uri.parse("$baseApiUrl/moblogin"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'email': email, 'password': password, 'version': version, 'os': 'android'}));
  }

  Future<bool> isLogged() async {
    // Token kaydedildi mi? Kaydedilmediyse doğrudan false dön.
    if (isNullOrEmpty(_token)) {
      return false;
    }
    // Token dolu fakat geçerli mi?
    if (JwtDecoder.isExpired(_token!)) return false;
    if (kDebugMode) {
      print("exp time: ${JwtDecoder.getExpirationDate(_token!)}");
      print("exp reaming time: ${JwtDecoder.getRemainingTime(_token!)}");
    }
    return true;
  }

  Future<bool> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("token");
    if (!isNullOrEmpty(_token)) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);
      Map<String, dynamic> authorizedProjects = decodedToken["authorized_projects"];
      _fullname = decodedToken["name_surname"];
      _projectId = authorizedProjects.keys.first.toString();
      _projectName = authorizedProjects[authorizedProjects.keys.first.toString()]["Project Name"];
      _email = decodedToken["e_mail"];
      _userID = decodedToken['user_id'].toString();
    }
    return true;
  }

  static Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const TutorialPage()),
        (route) => false,
      );
    }
  }

  String? getFullName() {
    return _fullname;
  }

  String? getProjectId() {
    return _projectId;
  }

  String? getProjectName() {
    return _projectName;
  }


  String? getEmail() {
    return _email;
  }

  String? getToken() {
    return _token;
  }

  String? getUserID() {
    return _userID;
  }
}
