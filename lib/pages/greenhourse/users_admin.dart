import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/appbar.dart';
import 'package:iot_app/components/sidebar.dart';
import 'package:iot_app/pages/greenhourse/user_create.dart';

class UserAdminPage extends StatefulWidget {
  const UserAdminPage({super.key});

  @override
  State<UserAdminPage> createState() => _UserAdminPageState();
}

class _UserAdminPageState extends State<UserAdminPage> {
  bool isLoading = true;
  String selectrole = 'all';
  Map<String, dynamic> newname = {'newname': ''};
  List<dynamic> branchs = [];
  List<dynamic> roles = [];
  List<dynamic> users = [];
  List<dynamic> filterUsers = [];
  List<dynamic> temp = [];

  List<TextEditingController> nameControllers = [];
  List<TextEditingController> usernameControllers = [];
  List<TextEditingController> emailControllers = [];
  List<TextEditingController> phoneControllers = [];
  List<TextEditingController> addressControllers = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    final bres = await ApiService.fetchBranchAll();
    final response = await ApiService.fetchUsersAll();
    final rres = await ApiService.fetchRolesAll();
    if (!mounted) return;

    setState(() {
      branchs = bres['data'] as List;
      users = response['data'] as List;
      roles = rres['data'] as List;

      isLoading = false;
    });

    filterUsersFunction();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(backgroundColor: Colors.white,body: Center(child: CircularProgressIndicator()));
    }
    final maxwidth = MediaQuery.of(context).size.width;
    final maxheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppbarWidget(txtt: 'Users Management'),
      // drawer: const SideBarWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateUserPage())).then((_) {
            _fetchData();
          });
        },
        backgroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: Container(
          width: maxwidth,
          height: maxheight - kToolbarHeight,
          decoration: BoxDecoration(color: Colors.white),
          child: SingleChildScrollView(
            child: Column(
              spacing: 4,
              children: [
                Container(
                  width: maxwidth,
                  height: 50,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                            decoration: BoxDecoration(
                              color: 'all' == selectrole ? const Color.fromARGB(255, 30, 31, 79) : Colors.white,
                              boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 1)],
                            ),
                            child: Text(
                              "All",
                              style: TextStyle(color: 'all' == selectrole ? Colors.white : Colors.black),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              selectrole = 'all';
                            });
                            filterUsersFunction();
                          },
                        ),
                        ...roles.map((r) {
                          return GestureDetector(
                            child: Container(
                              padding: EdgeInsets.fromLTRB(7, 10, 7, 10),
                              decoration: BoxDecoration(
                                color: r['role_num'] == selectrole
                                    ? const Color.fromARGB(255, 30, 31, 79)
                                    : Colors.white,
                                boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 1)],
                              ),
                              child: Text(
                                r['rule_name'],
                                style: TextStyle(color: r['role_num'] == selectrole ? Colors.white : Colors.black),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                selectrole = r['role_num'];
                              });
                              filterUsersFunction();
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                ...filterUsers.asMap().entries.map((entry) {
                  int index = entry.key;
                  var item = entry.value;
                  return Container(
                    width: maxwidth,
                    height: maxheight * 0.1,
                    padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
                    child: GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: const Color.fromARGB(31, 63, 58, 58), spreadRadius: 1, blurRadius: 1),
                          ],
                        ),
                        padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['username'] ?? "",
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                  Text(item['email'] ?? "", style: TextStyle(color: Colors.grey, fontSize: 10)),
                                ],
                              ),
                            ),
                            Container(
                              width: maxwidth * 0.2,
                              child: Text(item['status'] == '1' ? "เปิดใช้งาน" : "ปิดใช้งาน", textAlign: TextAlign.end),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setStateDialog) {
                                return AlertDialog(
                                  titlePadding: EdgeInsets.all(12),
                                  contentPadding: EdgeInsets.all(12),
                                  actionsPadding: EdgeInsets.all(12),
                                  backgroundColor: Colors.white,
                                  title: Container(height: 40, child: Center(child: Text("Edit Profile"))),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Divider(height: 0.5),
                                        SizedBox(height: 20, child: Text('Name', style: TextStyle(fontSize: 12))),
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
                                            controller: nameControllers[index],
                                            onChanged: (value) {
                                              setState(() {
                                                temp[index]['name'] = value;
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        SizedBox(height: 20, child: Text('Password', style: TextStyle(fontSize: 12))),
                                        Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            border: Border.all(width: 0.25, color: Colors.deepOrange),
                                            borderRadius: BorderRadius.all(Radius.circular(8)),
                                          ),
                                          child: TextButton(
                                            onPressed: () {
                                              // TextEditingController passwordController = TextEditingController();
                                              TextEditingController newpasswordController = TextEditingController();
                                              TextEditingController confirmpasswordController = TextEditingController();
                                              // String notimessage = "";
                                              String notinewmessage = "";
                                              String noticomessage = "";
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return StatefulBuilder(
                                                    builder: (contextpass, setStatePasswordDialog) {
                                                      return AlertDialog(
                                                        title: Text("แก้ไขรหัสผ่าน"),
                                                        content: Container(
                                                          height: 300,
                                                          child: SingleChildScrollView(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                // SizedBox(child: Text("รหัสผ่านปัจจุบัน")),
                                                                // Container(
                                                                //   height: 50,
                                                                //   decoration: BoxDecoration(
                                                                //     border: Border.all(width: 0.25),
                                                                //     borderRadius: BorderRadius.all(Radius.circular(8)),
                                                                //   ),
                                                                //   child: TextField(
                                                                //     decoration: InputDecoration(
                                                                //       contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                                                //       border: InputBorder.none,
                                                                //     ),
                                                                //     obscureText: true,
                                                                //     controller: passwordController,
                                                                //   ),
                                                                // ),
                                                                // Text(notimessage, style: TextStyle(color: Colors.red)),
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
                                                                Text(
                                                                  notinewmessage,
                                                                  style: TextStyle(color: Colors.red),
                                                                ),
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
                                                                Text(
                                                                  noticomessage,
                                                                  style: TextStyle(color: Colors.red),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(contextpass).pop();
                                                              // passwordController.text = "";
                                                              newpasswordController.text = "";
                                                              confirmpasswordController.text = "";
                                                            },
                                                            child: Text("ยกเลิก"),
                                                          ),
                                                          TextButton(
                                                            onPressed: () async {
                                                              setStatePasswordDialog(() {
                                                                // notimessage = "";
                                                                notinewmessage = "";
                                                                noticomessage = "";
                                                              });
                                                              // var password = passwordController.text.trim();
                                                              var newpassword = newpasswordController.text.trim();
                                                              var confirmpassword = confirmpasswordController.text
                                                                  .trim();

                                                              // if (password == '') {
                                                              //   setStatePasswordDialog(() {
                                                              //     notimessage = "โปรดระบุรหัสผ่านปัจจุบัน";
                                                              //   });
                                                              // }
                                                              if (newpassword != confirmpassword ||
                                                                  newpassword == "" ||
                                                                  confirmpassword == "") {
                                                                setStatePasswordDialog(() {
                                                                  notinewmessage = "รหัสผ่านไม่ตรงกัน";
                                                                  noticomessage = "รหัสผ่านไม่ตรงกัน";
                                                                });
                                                              } else {
                                                                item['new_password'] = newpassword;
                                                                final rescheckpass =
                                                                    await ApiService.updateHardResetPasswordById(item);
                                                                if (rescheckpass['status'] == 'success') {
                                                                  Navigator.of(contextpass).pop();
                                                                  _fetchData();
                                                                  ScaffoldMessenger.of(contextpass).showSnackBar(
                                                                    SnackBar(
                                                                      content: Text("บันทึกรหัสผ่านเรียบร้อยแล้ว"),
                                                                    ),
                                                                  );
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
                                        SizedBox(height: 20),
                                        SizedBox(height: 20, child: Text('Email', style: TextStyle(fontSize: 12))),
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
                                            controller: emailControllers[index],
                                            onChanged: (value) {
                                              setState(() {
                                                temp[index]['email'] = value;
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        SizedBox(height: 20, child: Text('phone', style: TextStyle(fontSize: 12))),
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
                                            controller: phoneControllers[index],
                                            onChanged: (value) {
                                              setState(() {
                                                temp[index]['phone_number'] = value;
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        SizedBox(height: 20, child: Text('Address', style: TextStyle(fontSize: 12))),
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
                                            controller: addressControllers[index],
                                            onChanged: (value) {
                                              setState(() {
                                                temp[index]['address'] = value;
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 20, child: Text('Role', style: TextStyle(fontSize: 12))),
                                        Container(
                                          width: maxwidth,
                                          height: 60,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  child: Column(
                                                    children: [
                                                      Checkbox(
                                                        value: temp[index]['role_id'] == '1',
                                                        onChanged: (value) {
                                                          setStateDialog(() {
                                                            temp[index]['role_id'] = '1';
                                                          });
                                                        },
                                                      ),
                                                      Text("User"),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  child: Column(
                                                    children: [
                                                      Checkbox(
                                                        value: temp[index]['role_id'] == '55',
                                                        onChanged: (value) {
                                                          setStateDialog(() {
                                                            temp[index]['role_id'] = '55';
                                                          });
                                                        },
                                                      ),
                                                      Text("Admin"),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  child: Column(
                                                    children: [
                                                      Checkbox(
                                                        value: temp[index]['role_id'] == '88',
                                                        onChanged: (value) {
                                                          setStateDialog(() {
                                                            temp[index]['role_id'] = '88';
                                                          });
                                                        },
                                                      ),
                                                      Text("Super Admin"),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        setState(() {
                                          nameControllers[index].text = item['name'];
                                          emailControllers[index].text = item['email'];
                                          phoneControllers[index].text = item['phone_number'];
                                          addressControllers[index].text = item['address'];
                                          temp = filterUsers.map((e) => Map<String, dynamic>.from(e)).toList();
                                        });
                                      },
                                      child: Text("ยกเลิก"),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        setState(() {
                                          filterUsers = temp.map((e) => Map<String, dynamic>.from(e)).toList();
                                        });
                                        var response = await ApiService.updateAccountById(filterUsers[index]);
                                        // print(response);
                                        if (response['status'] == 'success') {
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(SnackBar(content: Text("บันทึกสำเร็จ")));
                                          _fetchData();
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
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void filterUsersFunction() {
    setState(() {
      if (selectrole == 'all') {
        filterUsers = users.map((e) => Map<String, dynamic>.from(e)).toList();
        temp = users.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        filterUsers = users.where((u) => u['role_id'].toString() == selectrole).toList();
        temp = users.where((u) => u['role_id'].toString() == selectrole).toList();
      }
      nameControllers = filterUsers.map((item) => TextEditingController(text: item['name']?.toString() ?? '')).toList();
      usernameControllers = filterUsers
          .map((item) => TextEditingController(text: item['username']?.toString() ?? ''))
          .toList();
      emailControllers = filterUsers
          .map((item) => TextEditingController(text: item['email']?.toString() ?? ''))
          .toList();
      phoneControllers = filterUsers
          .map((item) => TextEditingController(text: item['phone_number']?.toString() ?? ''))
          .toList();
      addressControllers = filterUsers
          .map((item) => TextEditingController(text: item['address']?.toString() ?? ''))
          .toList();
    });
  }
}
