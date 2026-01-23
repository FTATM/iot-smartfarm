import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> CurrentUser = {};

String pathURL = '';

Future<void> loadUserData() async {
  final prefs = await SharedPreferences.getInstance();
  final userString = prefs.getString('user') ?? '{}';
  CurrentUser = jsonDecode(userString);
}

class ServerConfig {
  static Future<void> saveServerConfig(String ip, String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', ip);
    await prefs.setString('server_path', path);
  }

  static Future<Map<String, String?>> loadServerConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'ip': prefs.getString('server_ip'),
      'path': prefs.getString('server_path'),
    };
  }

  static Future<void> clearConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('server_ip');
    await prefs.remove('server_path');
  }
}

class RememberConfig {
  static Future<void> saveRememberConfig(String email, String pass) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('pass', pass);
  }

    static Future<Map<String, String?>> loadRememberConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'e': prefs.getString('email'),
      'p': prefs.getString('pass'),
    };
  }

  static Future<void> clearRememberConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('pass');
  }
}