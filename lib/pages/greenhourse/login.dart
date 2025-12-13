import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/session.dart';
import 'package:iot_app/pages/Farm/mainFarm.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _IpServerController = TextEditingController();
  final _PathtoAPIController = TextEditingController();
  bool _isLoading = false;
  String baseURL = "";

  @override
  void initState() {
    super.initState();
    loadConfig();
  }

  void loadConfig() async {
    final config = await ServerConfig.loadServerConfig();

    setState(() {
      _IpServerController.text = config['ip'] ?? "";
      _PathtoAPIController.text = config['path'] ?? "";
      baseURL = "${_IpServerController.text}/${_PathtoAPIController.text}";
    });
  }

  void _login() async {
    setState(() => _isLoading = true);

    var username = _usernameController.text.trim();
    var password = _passwordController.text.trim();

    // if (username.isEmpty || password.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('กรุณากรอกชื่อผู้ใช้และรหัสผ่าน')));
    //   setState(() => _isLoading = false);
    //   return;
    // }

    username = "admin";
    password = "abc+123";
    baseURL = "49.0.69.152/iotsf/api-app";

    final response = await ApiService.checkLogin(username, password, 'http://$baseURL/');


    setState(() => _isLoading = false);

    if (response['status'] == 'success') {
      var user = response['user'];
      user['baseURL'] = 'http://$baseURL/';

      final prefs = await SharedPreferences.getInstance();
      String userJson = jsonEncode(user);
      await prefs.setString('user', userJson);

      await loadUserData();
      // เข้าสู่ระบบสำเร็จ
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('ยินดีต้อนรับ ${response['user']['username']}')),
      // );
      // ไปหน้า HomePage หรือ Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => mainboardPage()),
        // MaterialPageRoute(builder: (_) => DashboardPage()),
        // MaterialPageRoute(builder: (_) => ConfigPage()),
      );
    } else {
      // เข้าสู่ระบบไม่สำเร็จ
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response['message'] ?? 'เข้าสู่ระบบไม่สำเร็จ')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxwidth = MediaQuery.of(context).size.width;
    final maxheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 70, 70, 70),
      // appBar: AppBar(title: const Text('เข้าสู่ระบบ')),
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              width: maxwidth,
              child: Align(
                alignment: AlignmentGeometry.bottomRight,
                child: GestureDetector(
                  child: Icon(Icons.settings, size: 36, color: Colors.white),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setStateDialog) => AlertDialog(
                            title: Text("ตั้งค่า server"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: maxwidth * 0.15,
                                        height: maxheight * 0.05,
                                        child: Text('Result : ', style: TextStyle(color: Colors.black)),
                                      ),
                                      SizedBox(width: maxwidth * 0.4, height: maxheight * 0.05, child: Text(baseURL)),
                                    ],
                                  ),
                                ),

                                TextField(
                                  controller: _IpServerController,
                                  decoration: const InputDecoration(labelText: 'IP server.'),
                                  onChanged: (value) {
                                    setStateDialog(() {
                                      baseURL = '$value/${_PathtoAPIController.text}';
                                    });
                                  },
                                ),
                                SizedBox(
                                  width: maxwidth * 0.8,
                                  child: Text('ex. 123.456.789.000', style: TextStyle(color: Colors.black45)),
                                ),
                                TextField(
                                  controller: _PathtoAPIController,
                                  decoration: const InputDecoration(labelText: 'Path to API'),
                                  onChanged: (value) {
                                    setStateDialog(() {
                                      baseURL = '${_IpServerController.text}/$value';
                                    });
                                  },
                                ),
                                SizedBox(
                                  width: maxwidth * 0.8,
                                  child: Text('ex. iot/api', style: TextStyle(color: Colors.black45)),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("ปิด"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await ServerConfig.saveServerConfig(
                                    _IpServerController.text.trim(),
                                    _PathtoAPIController.text.trim(),
                                  );

                                  Navigator.pop(context);
                                },
                                child: Text("บันทึก"),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            Align(
              alignment: AlignmentGeometry.center,
              child: Container(
                width: maxwidth * 0.7,
                height: maxheight * 0.4 < 350 ? 350 : maxheight * 0.4,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                        child: Text("Login", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(labelText: 'ชื่อผู้ใช้'),
                      ),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'รหัสผ่าน'),
                        obscureText: true,
                      ),
                      const SizedBox(height: 10),
                      Text("Now fixed User admin"),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 255, 130, 1)),
                              ),
                              onPressed: _login,
                              child: const Text('Login', style: TextStyle(color: Colors.white)),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
