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