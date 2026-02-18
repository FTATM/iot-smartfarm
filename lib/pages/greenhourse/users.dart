import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/appbar.dart';
import 'package:iot_app/components/session.dart';
import 'package:iot_app/pages/greenhourse/user_create.dart';

class UserAdminPage extends StatefulWidget {
  const UserAdminPage({super.key});

  @override
  State<UserAdminPage> createState() => _UserAdminPageState();
}

class _UserAdminPageState extends State<UserAdminPage> {
  bool isLoading = true;
  int currentRoleId = int.parse(CurrentUser['role_id'].toString());
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
      users = response['data'].where((u) => int.parse(u['role_id'].toString()) < currentRoleId).toList();
      roles = rres['data'].where((r) => int.parse(r['role_num'].toString()) < currentRoleId).toList();

      isLoading = false;
    });

    filterUsersFunction();
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
    return Scaffold(
      backgroundColor: Color(0xFFE8E8E8),
      appBar: AppbarWidget(txtt: 'Users Management'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateUserPage())).then((_) {
            _fetchData();
          });
        },
        backgroundColor: Color(0xFFFF8C42),
        child: Icon(Icons.add, color: Colors.white, size: 32),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter tabs section
            Container(
              width: maxwidth,
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(color: Colors.white),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    GestureDetector(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: 'all' == selectrole ? Color(0xFFFF8C42) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: 'all' == selectrole ? Color(0xFFFF8C42) : Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          "All",
                          style: TextStyle(
                            color: 'all' == selectrole ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectrole = 'all';
                        });
                        filterUsersFunction();
                      },
                    ),
                    SizedBox(width: 8),
                    ...roles.map((r) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              color: r['role_num'] == selectrole ? Color(0xFFFF8C42) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: r['role_num'] == selectrole ? Color(0xFFFF8C42) : Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              r['rule_name'],
                              style: TextStyle(
                                color: r['role_num'] == selectrole ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              selectrole = r['role_num'];
                            });
                            filterUsersFunction();
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            // Users list section
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: filterUsers.length,
                itemBuilder: (context, index) {
                  var item = filterUsers[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          _showEditDialog(context, item, index, maxwidth);
                        },
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(color: Color(0xFFFFE5D3), shape: BoxShape.circle),
                                child: Icon(Icons.person, color: Color(0xFFFF8C42), size: 32),
                              ),
                              SizedBox(width: 16),
                              // User info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'] ?? item['username'] ?? "",
                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    SizedBox(height: 4),
                                    Text(item['email'] ?? "", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                  ],
                                ),
                              ),
                              // Status badge
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: item['status'] == '1' ? Color(0xFFE8F5E9) : Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  item['status'] == '1' ? "เปิดใช้งาน" : "ปิดใช้งาน",
                                  style: TextStyle(
                                    color: item['status'] == '1' ? Color(0xFF4CAF50) : Color(0xFFE57373),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, dynamic item, int index, double maxwidth) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: maxwidth * 0.9,
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with back button
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.black87),
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {
                                nameControllers[index].text = item['name'] ?? '';
                                emailControllers[index].text = item['email'] ?? '';
                                phoneControllers[index].text = item['phone_number'] ?? '';
                                addressControllers[index].text = item['address'] ?? '';
                                temp = filterUsers.map((e) => Map<String, dynamic>.from(e)).toList();
                              });
                            },
                          ),
                          Expanded(
                            child: Text(
                              'แก้ไขโปรไฟล์',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ),
                          SizedBox(width: 40), // Balance the back button
                        ],
                      ),
                    ),

                    // Scrollable content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 10),

                            // Profile Avatar
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(color: Color(0xFFFFE5D3), shape: BoxShape.circle),
                              child: Icon(Icons.person, color: Color.fromARGB(255, 255, 131, 0), size: 50),
                            ),

                            SizedBox(height: 16),

                            // Profile Details Title
                            Text(
                              'Profile Details',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
                            ),

                            SizedBox(height: 32),

                            // Full Name Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'FULL NAME',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFB0B8C1),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: TextField(
                                    controller: nameControllers[index],
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.badge_outlined, color: Colors.grey[400]),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        temp[index]['name'] = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 24),

                            // Security / Change Password
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SECURITY',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFB0B8C1),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      _showPasswordDialog(context, item);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      child: Row(
                                        children: [
                                          Icon(Icons.lock_outline, color: Colors.grey[400]),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Change Password',
                                              style: TextStyle(fontSize: 16, color: Colors.black87),
                                            ),
                                          ),
                                          Icon(Icons.chevron_right, color: Colors.grey[400]),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 24),

                            // Email Address Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'EMAIL ADDRESS',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFB0B8C1),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: TextField(
                                    controller: emailControllers[index],
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[400]),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        temp[index]['email'] = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 24),

                            // Phone Number Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PHONE NUMBER',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFB0B8C1),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: TextField(
                                    controller: phoneControllers[index],
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.phone_outlined, color: Colors.grey[400]),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        temp[index]['phone_number'] = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 24),

                            // Address Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ADDRESS',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFB0B8C1),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: TextField(
                                    controller: addressControllers[index],
                                    minLines: 3,
                                    maxLines: 4,
                                    decoration: InputDecoration(
                                      prefixIcon: Padding(
                                        padding: EdgeInsets.only(bottom: 50),
                                        child: Icon(Icons.location_on_outlined, color: Colors.grey[400]),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        temp[index]['address'] = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 24),

                            // Role Selection
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ROLE',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFB0B8C1),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Visibility(
                                        visible: int.parse(CurrentUser['role_id'].toString()) >= 55,
                                        child: Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              setStateDialog(() {
                                                temp[index]['role_id'] = '1';
                                              });
                                            },
                                            child: Column(
                                              children: [
                                                Radio<String>(
                                                  value: '1',
                                                  groupValue: temp[index]['role_id'],
                                                  onChanged: (value) {
                                                    setStateDialog(() {
                                                      temp[index]['role_id'] = value;
                                                    });
                                                  },
                                                  activeColor: Color(0xFFFF8300),
                                                ),
                                                Text("User", style: TextStyle(fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: int.parse(CurrentUser['role_id'].toString()) >= 88,
                                        child: Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              setStateDialog(() {
                                                temp[index]['role_id'] = '55';
                                              });
                                            },
                                            child: Column(
                                              children: [
                                                Radio<String>(
                                                  value: '55',
                                                  groupValue: temp[index]['role_id'],
                                                  onChanged: (value) {
                                                    setStateDialog(() {
                                                      temp[index]['role_id'] = value;
                                                    });
                                                  },
                                                  activeColor: Color(0xFFFF8300),
                                                ),
                                                Text("Admin", style: TextStyle(fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: int.parse(CurrentUser['role_id'].toString()) >= 99,
                                        child: Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              setStateDialog(() {
                                                temp[index]['role_id'] = '88';
                                              });
                                            },
                                            child: Column(
                                              children: [
                                                Radio<String>(
                                                  value: '88',
                                                  groupValue: temp[index]['role_id'],
                                                  onChanged: (value) {
                                                    setStateDialog(() {
                                                      temp[index]['role_id'] = value;
                                                    });
                                                  },
                                                  activeColor: Color(0xFFFF8300),
                                                ),
                                                Text("Super Admin", style: TextStyle(fontSize: 11)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 24),
                            SizedBox(
                              height: 50,
                              width: maxwidth,
                              child: TextButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[600],
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                onPressed: () async {
                                  await confirmDelete(item);
                                  Navigator.pop(context);
                                  _fetchData();
                                },
                                child: Text(
                                  'ลบผู้ใช้นี้',
                                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),

                    // Action Buttons
                    Container(
                      padding: EdgeInsets.all(24),
                      child: Row(
                        spacing: 8,
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  nameControllers[index].text = item['name'] ?? '';
                                  emailControllers[index].text = item['email'] ?? '';
                                  phoneControllers[index].text = item['phone_number'] ?? '';
                                  addressControllers[index].text = item['address'] ?? '';
                                  temp = filterUsers.map((e) => Map<String, dynamic>.from(e)).toList();
                                });
                              },
                              style: TextButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14)),
                              child: Text(
                                'ยกเลิก',
                                style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  filterUsers = temp.map((e) => Map<String, dynamic>.from(e)).toList();
                                });
                                var response = await ApiService.updateAccountById(filterUsers[index]);
                                if (response['status'] == 'success') {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("บันทึกสำเร็จ"), backgroundColor: Colors.orange),
                                  );
                                  _fetchData();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 255, 131, 0),
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: Text(
                                'บันทึก',
                                style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPasswordDialog(BuildContext context, dynamic item) {
    TextEditingController newpasswordController = TextEditingController();
    TextEditingController confirmpasswordController = TextEditingController();
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
                      SizedBox(child: Text("รหัสผ่านใหม่")),
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
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
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
                    newpasswordController.text = "";
                    confirmpasswordController.text = "";
                  },
                  child: Text("ยกเลิก"),
                ),
                TextButton(
                  onPressed: () async {
                    setStatePasswordDialog(() {
                      notinewmessage = "";
                      noticomessage = "";
                    });
                    var newpassword = newpasswordController.text.trim();
                    var confirmpassword = confirmpasswordController.text.trim();

                    if (newpassword != confirmpassword || newpassword == "" || confirmpassword == "") {
                      setStatePasswordDialog(() {
                        notinewmessage = "รหัสผ่านไม่ตรงกัน";
                        noticomessage = "รหัสผ่านไม่ตรงกัน";
                      });
                    } else {
                      item['new_password'] = newpassword;
                      final rescheckpass = await ApiService.updateHardResetPasswordById(item);
                      if (rescheckpass['status'] == 'success') {
                        Navigator.of(contextpass).pop();
                        _fetchData();
                        ScaffoldMessenger.of(
                          contextpass,
                        ).showSnackBar(SnackBar(content: Text("บันทึกรหัสผ่านเรียบร้อยแล้ว")));
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

  Future<void> confirmDelete(Map<String, dynamic> user) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // กันเผลอกดข้างนอก
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text("ยืนยันการลบ"),
            ],
          ),
          backgroundColor: Colors.white,
          content: Text("คุณแน่ใจหรือไม่ว่าต้องการลบผู้ใช้\n\n${user['username']} ?", style: TextStyle(fontSize: 14)),
          actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("ยกเลิก", style: TextStyle(color: Colors.grey[700])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(context);
                // 🔹 เรียก API ลบ
                try {
                  final res = await ApiService.deleteUserById(user); // <<==== ทำ API ต่อ
                  if (res['status'] == 'success') {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("ลบผู้ใช้สำเร็จ"), backgroundColor: Colors.green));
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("ลบผู้ใช้ไม่สำเร็จ"), backgroundColor: Colors.red));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาดในการลบ"), backgroundColor: Colors.red));
                }
              },
              child: Text(
                "ลบ",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
