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
      return const Scaffold(backgroundColor: Colors.white,body: Center(child: CircularProgressIndicator()));
    }
    final maxwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 250, 250, 250),
      appBar: AppbarWidget(txtt: ''),
      body: Container(
        padding: EdgeInsets.all(16),
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 100,
                child: Center(
                  child: Text("Create Account", style: TextStyle(color: Colors.blue[900], fontSize: 36)),
                ),
              ),
              SizedBox(
                height: 20,
                child: Text('Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  border: Border.all(
                    color: focusNodes['name']!.hasFocus
                        ? const Color.fromARGB(255, 13, 71, 161)
                        : const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                child: TextField(
                  focusNode: focusNodes['name'],
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
              SizedBox(height: 20),
              SizedBox(
                height: 20,
                child: Text('Username', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: Colors.blue[50],
                  border: Border.all(
                    color: focusNodes['username']!.hasFocus
                        ? const Color.fromARGB(255, 13, 71, 161)
                        : const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                child: TextField(
                  focusNode: focusNodes['username'],
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    border: InputBorder.none,
                  ),
                  controller: usernameControllers,
                  onChanged: (value) {
                    setState(() {
                      data['username'] = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 20,
                child: Text('Email', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: Colors.blue[50],
                  border: Border.all(
                    color: focusNodes['email']!.hasFocus
                        ? const Color.fromARGB(255, 13, 71, 161)
                        : const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                child: TextField(
                  focusNode: focusNodes['email'],
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
              SizedBox(height: 20),
              SizedBox(
                height: 20,
                child: Text('Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: Colors.blue[50],
                  border: Border.all(
                    color: focusNodes['password']!.hasFocus
                        ? const Color.fromARGB(255, 13, 71, 161)
                        : const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                child: TextField(
                  focusNode: focusNodes['password'],
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    border: InputBorder.none,
                  ),
                  controller: passwordControllers,
                  onChanged: (value) {
                    setState(() {
                      data['password'] = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 20),
              // SizedBox(
              //   height: 20,
              //   child: Text('phone', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              // ),
              // Container(
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.all(Radius.circular(8)),
              //     color: Colors.blue[50],
              //     border: Border.all(
              //       color: focusNodes['phone']!.hasFocus ? const Color.fromARGB(255, 13, 71, 161): const Color.fromARGB(255, 255, 255, 255),
              //     ),
              //   ),
              //   child: TextField(
              //     focusNode: focusNodes['phone'],
              //     decoration: InputDecoration(
              //       contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              //       border: InputBorder.none,
              //     ),
              //     controller: phoneControllers,
              //     onChanged: (value) {
              //       setState(() {
              //         data['phone_number'] = value;
              //       });
              //     },
              //   ),
              // ),
              // SizedBox(height: 20),
              // SizedBox(
              //   height: 20,
              //   child: Text('Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              // ),
              // Container(
              //   height: 100,
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.all(Radius.circular(8)),
              //     color: Colors.blue[50],
              //     border: Border.all(
              //       color: focusNodes['address']!.hasFocus ? const Color.fromARGB(255, 13, 71, 161) : const Color.fromARGB(255, 255, 255, 255),
              //     ),
              //   ),
              //   child: TextField(
              //     minLines: 3,
              //     maxLines: 4,
              //     focusNode: focusNodes['address'],
              //     decoration: InputDecoration(
              //       contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              //       border: InputBorder.none,
              //     ),
              //     controller: addressControllers,
              //     onChanged: (value) {
              //       setState(() {
              //         data['address'] = value;
              //       });
              //     },
              //   ),
              // ),
              SizedBox(height: 20),
              Container(
                width: maxwidth,
                height: 40,
                child: TextButton(
                  style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.blue[900])),
                  onPressed: () async {
                    if (data['name'] != null &&
                        data['username'] != null &&
                        data['email'] != null &&
                        data['password'] != null) {
                      var response = await ApiService.createUserAccount(data);
                      if (response['status'] == 'success') {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("สร้าง ${data['name']} เรียบร้อยแล้ว")));
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => UserAdminPage()));
                      }
                    } else {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("ข้อมูลไม่ครบ กรุณาป้อนข้อมูลอีกครั้ง")));
                    }
                  },
                  child: Text("บันทึก", style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
