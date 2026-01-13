import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/appbar.dart';
import 'package:iot_app/pages/greenhourse/users_admin.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  bool isLoading = true;
  bool _obscurePassword = true;

  late Map<String, FocusNode> focusNodes;
  TextEditingController nameControllers = TextEditingController();
  TextEditingController usernameControllers = TextEditingController();
  TextEditingController emailControllers = TextEditingController();
  TextEditingController passwordControllers = TextEditingController();
  TextEditingController phoneControllers = TextEditingController();
  TextEditingController addressControllers = TextEditingController();
  TextEditingController idCardControllers = TextEditingController();

  Map<String, dynamic> data = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
    focusNodes = {
      'name': FocusNode(),
      'username': FocusNode(),
      'email': FocusNode(),
      'password': FocusNode(),
      'phone': FocusNode(),
      'address': FocusNode(),
    };

    focusNodes.forEach((key, node) {
      node.addListener(() => setState(() {}));
    });
  }

  @override
  void dispose() {
    focusNodes.forEach((key, node) {
      node.dispose();
    });
    nameControllers.dispose();
    usernameControllers.dispose();
    emailControllers.dispose();
    passwordControllers.dispose();
    phoneControllers.dispose();
    addressControllers.dispose();
    idCardControllers.dispose();
    super.dispose();
  }

  void _fetchData() async {
    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: CircularProgressIndicator()));
    }
    final maxwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppbarWidget(txtt: ''),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Center(
                child: Text(
                  "Create Account",
                  style: TextStyle(
                    color: Color(0xFFFF9F43),
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 40),
              _buildInputField(
                label: 'Name',
                controller: nameControllers,
                focusNode: focusNodes['name']!,
                hintText: 'Enter your full name',
                onChanged: (value) {
                  setState(() {
                    data['name'] = value;
                  });
                },
              ),
              SizedBox(height: 24),
              _buildInputField(
                label: 'Username',
                controller: usernameControllers,
                focusNode: focusNodes['username']!,
                hintText: 'Choose a username',
                onChanged: (value) {
                  setState(() {
                    data['username'] = value;
                  });
                },
              ),
              SizedBox(height: 24),
              _buildInputField(
                label: 'Email',
                controller: emailControllers,
                focusNode: focusNodes['email']!,
                hintText: 'example@mail.com',
                onChanged: (value) {
                  setState(() {
                    data['email'] = value;
                  });
                },
              ),
              SizedBox(height: 24),
              _buildPasswordField(
                label: 'Password',
                controller: passwordControllers,
                focusNode: focusNodes['password']!,
                hintText: '••••••••',
                onChanged: (value) {
                  setState(() {
                    data['password'] = value;
                  });
                },
              ),
              SizedBox(height: 60),
              Container(
                width: maxwidth,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF9F43), Color(0xFFFF8833)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFF9F43).withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.transparent),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    if (data['name'] != null &&
                        data['username'] != null &&
                        data['email'] != null &&
                        data['password'] != null) {
                      var response = await ApiService.createUserAccount(data);
                      if (response['status'] == 'success') {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(
                            content:
                                Text("สร้าง ${data['name']} เรียบร้อยแล้ว")));
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => UserAdminPage()));
                      }
                    } else {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(
                          content: Text("ข้อมูลไม่ครบ กรุณาป้อนข้อมูลอีกครั้ง")));
                    }
                  },
                  child: Text(
                    "บันทึก",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFFFF5EC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: focusNode.hasFocus
                  ? Color(0xFFFF9F43)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: TextField(
            focusNode: focusNode,
            controller: controller,
            onChanged: onChanged,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF2D3748),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Color(0xFFFFB976),
                fontSize: 16,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFFFF5EC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: focusNode.hasFocus
                  ? Color(0xFFFF9F43)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: TextField(
            focusNode: focusNode,
            controller: controller,
            onChanged: onChanged,
            obscureText: _obscurePassword,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF2D3748),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Color(0xFFFFB976),
                fontSize: 16,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Color(0xFFFF9F43),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}