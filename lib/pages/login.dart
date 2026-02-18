import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/session.dart';
import 'package:iot_app/pages/mainMenu.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool passwordVisible = false;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _IpServerController = TextEditingController();
  final _PathtoAPIController = TextEditingController(text: "iotsf/api-app");
  final _portWebsocketController = TextEditingController(text: "8765");
  bool _isLoading = false;
  String baseURL = "";

  String statuslogin = '';

  @override
  void initState() {
    super.initState();
    loadConfig();
  }

  Future<void> loadConfig() async {
    final config = await ServerConfig.loadServerConfig();
    final re = await RememberConfig.loadRememberConfig();
    if (!mounted) return;
    setState(() {
      _usernameController.text = re['e'] ?? _usernameController.text;
      _passwordController.text = re['p'] ?? _passwordController.text;
      _IpServerController.text = config['ip'] ?? _IpServerController.text;
      _portWebsocketController.text = config['portws'] ?? _portWebsocketController.text;
      _PathtoAPIController.text = config['path'] ?? _PathtoAPIController.text;
      baseURL = "${_IpServerController.text}/${_PathtoAPIController.text}";
    });
  }

  void _login() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    var username = _usernameController.text.trim();
    var password = _passwordController.text.trim();

    // username = username == "" ? "superadmin" : username;
    // password = password == "" ? "abc+123" : password;
    // baseURL = "49.0.69.152/iotsf/api-app";

    final response = await ApiService.checkLogin(username, password, 'http://$baseURL/');

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response['status'] == 'success') {
      await RememberConfig.saveRememberConfig(username, password);
      var user = response['user'];
      user['IP'] = _IpServerController.text;
      user['portws'] = _portWebsocketController.text;
      user['baseURL'] = 'http://$baseURL/';

      final prefs = await SharedPreferences.getInstance();
      String userJson = jsonEncode(user);
      await prefs.setString('user', userJson);

      await loadUserData();

      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const mainboardPage()), (route) => false);
    } else {
      // เข้าสู่ระบบไม่สำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxwidth = MediaQuery.of(context).size.width;
    final maxheight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        // appBar: AppBar(title: const Text('เข้าสู่ระบบ')),
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Container(
                    width: maxwidth > 400 ? 400 : maxwidth,
                    color: Colors.white,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // SizedBox(
                        //   height: 50,
                        //   child: Text("Login", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        // ),
                        SizedBox(height: maxheight * 0.2, child: Image.asset("assets/logo_app.png", width: 120)),
                        SizedBox(
                          child: Column(
                            spacing: 4,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                width: maxwidth,
                                child: Text("Your Username", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              SizedBox(
                                height: 60,
                                child: TextField(
                                  controller: _usernameController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: maxwidth,
                                child: Text("Your Password", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              SizedBox(
                                // height: 60,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _passwordController,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(8)),
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              passwordVisible ? Icons.visibility : Icons.visibility_off,
                                              color: Color.fromARGB(255, 255, 130, 0),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                passwordVisible = !passwordVisible;
                                              });
                                            },
                                          ),
                                        ),
                                        obscureText: !passwordVisible,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                child: Align(
                                  alignment: AlignmentGeometry.topCenter,
                                  child: Text(baseURL),
                                ),
                              ),
                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : SizedBox(
                                      width: maxwidth,
                                      height: 45,
                                      child: TextButton(
                                        style: ButtonStyle(
                                          backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 255, 130, 1)),
                                          shape: WidgetStatePropertyAll(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8), // 👈 ปรับตรงนี้
                                            ),
                                          ),
                                        ),

                                        onPressed: _login,
                                        child: const Text('Login', style: TextStyle(color: Colors.white)),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: maxwidth,
                child: Align(
                  alignment: AlignmentGeometry.topRight,
                  child: GestureDetector(
                    child: Padding(
                      padding: EdgeInsetsGeometry.all(20),
                      child: Icon(Icons.settings, size: maxwidth * 0.05, color: Colors.black),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setStateDialog) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                              title: Text("ตั้งค่า server", style: TextStyle(fontWeight: FontWeight.bold)),
                              backgroundColor: Colors.white,
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // SizedBox(
                                    //   child: Row(
                                    //     children: [
                                    //       SizedBox(
                                    //         height: maxheight * 0.05,
                                    //         child: Text('Result : ', style: TextStyle(color: Colors.black)),
                                    //       ),
                                    //       SizedBox(width: maxwidth * 0.4, height: maxheight * 0.05, child: Text(baseURL)),
                                    //     ],
                                    //   ),
                                    // ),
                                    // TextField(
                                    //   controller: _IpServerController,
                                    //   decoration: const InputDecoration(labelText: 'IP/DNS server.'),
                                    //   onChanged: (value) {
                                    //     setStateDialog(() {
                                    //       baseURL = '$value/${_PathtoAPIController.text}';
                                    //     });
                                    //   },
                                    // ),
                                    // SizedBox(
                                    //   width: maxwidth * 0.8,
                                    //   child: Text('ex. 123.456.789.000', style: TextStyle(color: Colors.black45)),
                                    // ),
                                    // TextField(
                                    //   controller: _PathtoAPIController,
                                    //   decoration: const InputDecoration(labelText: 'Path to API'),
                                    //   onChanged: (value) {
                                    //     setStateDialog(() {
                                    //       baseURL = '${_IpServerController.text}/$value';
                                    //     });
                                    //   },
                                    // ),
                                    // SizedBox(
                                    //   width: maxwidth * 0.8,
                                    //   child: Text('ex. iot/api', style: TextStyle(color: Colors.black45)),
                                    // ),
                                    // TextField(
                                    //   controller: _portWebsocketController,
                                    //   decoration: const InputDecoration(labelText: 'Port Websocket'),
                                    //   onChanged: (value) {
                                    //     setStateDialog(() {
                                    //       _IpServerController.text = value;
                                    //     });
                                    //   },
                                    // ),
                                    _buildTextField(
                                      label: 'IP / DNS Server',
                                      placeholder: 'ex. 123.456.789.000',
                                      textController: _IpServerController,
                                    ),
                                    SizedBox(height: 16),
                                    _buildTextField(
                                      label: 'Path to API',
                                      placeholder: 'ex. iot/api',
                                      textController: _PathtoAPIController,
                                    ),
                                    SizedBox(height: 16),
                                    _buildTextField(
                                      label: 'Port Websocket',
                                      placeholder: 'ex. 8080',
                                      textController: _portWebsocketController,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                              ),

                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('CANCEL', style: TextStyle(color: Colors.grey)),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    // จัดการการบันทึกข้อมูลที่นี่
                                    await ServerConfig.saveServerConfig(
                                      _IpServerController.text.trim(),
                                      _PathtoAPIController.text.trim(),
                                      _portWebsocketController.text.trim(),
                                    );
                                    await loadConfig();
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text('SAVE', style: TextStyle(color: Colors.white)),
                                ),
                                // TextButton(
                                //   onPressed: () {
                                //     Navigator.pop(context);
                                //   },
                                //   child: Text("ปิด"),
                                // ),
                                // TextButton(
                                //   onPressed: () async {
                                //     await ServerConfig.saveServerConfig(
                                //       _IpServerController.text.trim(),
                                //       _PathtoAPIController.text.trim(),
                                //       _portWebsocketController.text.trim(),
                                //     );
                                //     await loadConfig();
                                //     Navigator.pop(context);
                                //   },
                                //   child: Text("บันทึก"),
                                // ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String placeholder,
    required TextEditingController textController,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        TextField(
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            contentPadding: EdgeInsets.symmetric(vertical: 8),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent, width: 2)),
          ),
          controller: textController,
        ),
      ],
    );
  }
}
