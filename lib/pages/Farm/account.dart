import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/session.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool isLoading = true;
  Map<String, dynamic> data = {};

  TextEditingController nameControllers = TextEditingController(text: CurrentUser['name']);
  TextEditingController emailControllers = TextEditingController(text: CurrentUser['email']);
  TextEditingController addressControllers = TextEditingController(text: CurrentUser['address']);
  TextEditingController phoneControllers = TextEditingController(text: CurrentUser['phone_number']);

  @override
  void initState() {
    super.initState();
    setState(() {
      data = CurrentUser;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final maxwidth = MediaQuery.of(context).size.width;
    // final maxheight = MediaQuery.of(context).size.height - kTextTabBarHeight;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                Container(
                  width: maxwidth,
                  // color: Colors.amber,
                  height: 200,
                  child: Column(
                    spacing: 8,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 100, height: 100, child: Image.asset('assets/images/Logo.png')),
                      Container(
                        child: Text(CurrentUser['name'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      Container(child: Text("@${CurrentUser['username']}")),
                    ],
                  ),
                ),
                const Divider(height: 0.5),
                SizedBox(
                  height: 70,
                  width: maxwidth,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                        width: maxwidth,
                        child: Text('Name', style: TextStyle(fontSize: 12)),
                      ),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(width: 0.25),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            border: InputBorder.none,
                          ),
                          controller: nameControllers,
                          onChanged: (value) {
                            setState(() {
                              data['name'] = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 70,
                  width: maxwidth,
                  child: Column(
                    children: [
                      SizedBox(
                        width: maxwidth,
                        height: 20,
                        child: Text('Password', style: TextStyle(fontSize: 12)),
                      ),
                      Align(
                        alignment: AlignmentGeometry.centerLeft,
                        child: Container(
                          height: 30,
                          width: maxwidth * 0.3,
                          decoration: BoxDecoration(
                            border: Border.all(width: 0.25, color: Colors.deepOrange),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: SizedBox(
                            child: TextButton(
                              onPressed: () {
                                TextEditingController passwordController = TextEditingController();
                                TextEditingController newpasswordController = TextEditingController();
                                TextEditingController confirmpasswordController = TextEditingController();
                                String notimessage = "";
                                String notinewmessage = "";
                                String noticomessage = "";
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (contextpass, setStatePasswordDialog) {
                                        return AlertDialog(
                                          title: Text("แก้ไขรหัสผ่าน"),
                                          backgroundColor: Colors.white,
                                          content: Container(
                                            height: 300,
                                            child: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(child: Text("รหัสผ่านปัจจุบัน")),
                                                  Container(
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(width: 0.25),
                                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                                    ),
                                                    child: TextField(
                                                      decoration: InputDecoration(
                                                        contentPadding: EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 0,
                                                        ),
                                                        border: InputBorder.none,
                                                      ),
                                                      obscureText: true,
                                                      controller: passwordController,
                                                    ),
                                                  ),
                                                  Text(notimessage, style: TextStyle(color: Colors.red)),
                                                  SizedBox(child: Text("รหัสผ่านใหม่")),
                                                  Container(
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(width: 0.25),
                                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                                    ),
                                                    child: TextField(
                                                      decoration: InputDecoration(
                                                        contentPadding: EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 0,
                                                        ),
                                                        border: InputBorder.none,
                                                      ),
                                                      obscureText: true,
                                                      controller: newpasswordController,
                                                    ),
                                                  ),
                                                  Text(notinewmessage, style: TextStyle(color: Colors.red)),
                                                  SizedBox(child: Text("ยืนยันรหัสผ่านใหม่")),
                                                  Container(
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(width: 0.25),
                                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                                    ),
                                                    child: TextField(
                                                      decoration: InputDecoration(
                                                        contentPadding: EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 0,
                                                        ),
                                                        border: InputBorder.none,
                                                      ),
                                                      obscureText: true,
                                                      controller: confirmpasswordController,
                                                    ),
                                                  ),
                                                  Text(noticomessage, style: TextStyle(color: Colors.red)),
                                                ],
                                              ),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(contextpass).pop();
                                                passwordController.text = "";
                                                newpasswordController.text = "";
                                                confirmpasswordController.text = "";
                                              },
                                              child: Text("ยกเลิก"),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                setStatePasswordDialog(() {
                                                  notimessage = "";
                                                  notinewmessage = "";
                                                  noticomessage = "";
                                                });
                                                var password = passwordController.text.trim();
                                                var newpassword = newpasswordController.text.trim();
                                                var confirmpassword = confirmpasswordController.text.trim();

                                                if (password == '') {
                                                  setStatePasswordDialog(() {
                                                    notimessage = "โปรดระบุรหัสผ่านปัจจุบัน";
                                                  });
                                                } else if (newpassword != confirmpassword ||
                                                    newpassword == "" ||
                                                    confirmpassword == "") {
                                                  setStatePasswordDialog(() {
                                                    notinewmessage = "รหัสผ่านไม่ตรงกัน";
                                                    noticomessage = "รหัสผ่านไม่ตรงกัน";
                                                  });
                                                } else {
                                                  data['password'] = password;
                                                  final responsecheckuser = await ApiService.checkUser(data);
                                                  if (!responsecheckuser['found']) {
                                                    setStatePasswordDialog(() {
                                                      notimessage = "รหัสผ่านไม่ถูกต้อง";
                                                    });
                                                  } else {
                                                    data['new_password'] = newpassword;
                                                    final rescheckpass = await ApiService.updateHardResetPasswordById(
                                                      data,
                                                    );
                                                    if (rescheckpass['status'] == 'success') {
                                                      Navigator.of(contextpass).pop();
                                                      ScaffoldMessenger.of(contextpass).showSnackBar(
                                                        SnackBar(content: Text("บันทึกรหัสผ่านเรียบร้อยแล้ว")),
                                                      );
                                                    }
                                                  }
                                                }
                                              },
                                              child: Text("บันทึก"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              child: Text("เปลี่ยนรหัสผ่าน", style: TextStyle(color: Colors.deepOrange)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 70,
                  width: maxwidth,
                  child: Column(
                    children: [
                      SizedBox(
                        width: maxwidth,
                        height: 20,
                        child: Text('Email', style: TextStyle(fontSize: 12)),
                      ),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(width: 0.25),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            border: InputBorder.none,
                          ),
                          controller: emailControllers,
                          onChanged: (value) {
                            setState(() {
                              data['email'] = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 70,
                  width: maxwidth,
                  child: Column(
                    children: [
                      SizedBox(
                        width: maxwidth,
                        height: 20,
                        child: Text('phone', style: TextStyle(fontSize: 12)),
                      ),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(width: 0.25),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            border: InputBorder.none,
                          ),
                          controller: phoneControllers,
                          onChanged: (value) {
                            setState(() {
                              data['phone_number'] = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: maxwidth,
                  child: Column(
                    children: [
                      SizedBox(
                        width: maxwidth,
                        height: 20,
                        child: Text('Address', style: TextStyle(fontSize: 12)),
                      ),
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(width: 0.25),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: TextField(
                          minLines: 3,
                          maxLines: 4,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            border: InputBorder.none,
                          ),
                          controller: addressControllers,
                          onChanged: (value) {
                            setState(() {
                              data['address'] = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: maxwidth,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 136, 0),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      final res = await ApiService.updateAccountById(data);
                      if (res['status'] == 'success') {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("บันทึกข้อมูลเรียบร้อยแล้ว")));
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาดในการบันทึกข้อมูล")));
                      }
                    },
                    child: Text(
                      "บันทึก",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
