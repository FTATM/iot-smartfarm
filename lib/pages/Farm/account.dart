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
    
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFE0E0E0),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section with Logo
              Container(
                width: maxwidth,
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/Logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      CurrentUser['name'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "@${CurrentUser['username']}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Form Container
              Container(
                width: maxwidth,
                margin: EdgeInsets.symmetric(horizontal: 24),
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Field
                    _buildInputField(
                      label: 'ชื่อ',
                      controller: nameControllers,
                      icon: Icons.person_outline,
                      onChanged: (value) {
                        setState(() {
                          data['name'] = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    
                    // Password Field
                    _buildPasswordField(context),
                    SizedBox(height: 20),
                    
                    // Email Field
                    _buildInputField(
                      label: 'อีเมล',
                      controller: emailControllers,
                      icon: Icons.email_outlined,
                      onChanged: (value) {
                        setState(() {
                          data['email'] = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    
                    // Phone Field
                    _buildInputField(
                      label: 'เบอร์โทรศัพท์',
                      controller: phoneControllers,
                      icon: Icons.phone_outlined,
                      onChanged: (value) {
                        setState(() {
                          data['phone_number'] = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    
                    // Address Field
                    _buildAddressField(),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Save Button
              Container(
                width: maxwidth,
                margin: EdgeInsets.symmetric(horizontal: 24),
                height: 56,
                decoration: BoxDecoration(
                  color: Color(0xFFFF8800),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFF8800).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () async {
                    final res = await ApiService.updateAccountById(data);
                    if (res['status'] == 'success') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("บันทึกข้อมูลเรียบร้อยแล้ว")),
                      );
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("เกิดข้อผิดพลาดในการบันทึกข้อมูล")),
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_outlined, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        "บันทึก",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: Colors.grey[600], size: 24),
            ),
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'รหัสผ่าน',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFFF8800), width: 1.5),
          ),
          child: TextButton(
            onPressed: () => _showPasswordDialog(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.refresh, color: Color(0xFFFF8800), size: 24),
                SizedBox(width: 12),
                Text(
                  'เปลี่ยนรหัสผ่าน',
                  style: TextStyle(
                    color: Color(0xFFFF8800),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ที่อยู่',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: TextField(
            controller: addressControllers,
            minLines: 3,
            maxLines: 4,
            onChanged: (value) {
              setState(() {
                data['address'] = value;
              });
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(16),
              border: InputBorder.none,
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 16, right: 12, top: 16),
                child: Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 24),
              ),
            ),
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  void _showPasswordDialog(BuildContext context) {
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                "แก้ไขรหัสผ่าน",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.white,
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "รหัสผ่านปัจจุบัน",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            border: InputBorder.none,
                          ),
                          obscureText: true,
                          controller: passwordController,
                        ),
                      ),
                      if (notimessage.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(notimessage, style: TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                      SizedBox(height: 16),
                      
                      Text(
                        "รหัสผ่านใหม่",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            border: InputBorder.none,
                          ),
                          obscureText: true,
                          controller: newpasswordController,
                        ),
                      ),
                      if (notinewmessage.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(notinewmessage, style: TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                      SizedBox(height: 16),
                      
                      Text(
                        "ยืนยันรหัสผ่านใหม่",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            border: InputBorder.none,
                          ),
                          obscureText: true,
                          controller: confirmpasswordController,
                        ),
                      ),
                      if (noticomessage.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(noticomessage, style: TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(contextpass).pop();
                  },
                  child: Text(
                    "ยกเลิก",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
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
                    } else if (newpassword != confirmpassword || newpassword == "" || confirmpassword == "") {
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
                        final rescheckpass = await ApiService.updateHardResetPasswordById(data);
                        if (rescheckpass['status'] == 'success') {
                          Navigator.of(contextpass).pop();
                          ScaffoldMessenger.of(contextpass).showSnackBar(
                            SnackBar(content: Text("บันทึกรหัสผ่านเรียบร้อยแล้ว")),
                          );
                        }
                      }
                    }
                  },
                  child: Text(
                    "บันทึก",
                    style: TextStyle(color: Color(0xFFFF8800), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}