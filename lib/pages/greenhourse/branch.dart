import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/appbar.dart';
import 'package:iot_app/components/sidebar.dart';

class BranchPage extends StatefulWidget {
  const BranchPage({super.key});

  @override
  State<BranchPage> createState() => _BranchPageState();
}

class _BranchPageState extends State<BranchPage> {
  bool isLoading = true;
  Map<String, dynamic> newname = {'newname': ''};
  List<dynamic> branchs = [];
  List<dynamic> temp = [];

  List<TextEditingController> nameControllers = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    final response = await ApiService.fetchBranchAll();
    if (!mounted) return;

    setState(() {
      branchs = response['data'] as List;

      temp = branchs.map((e) => Map<String, dynamic>.from(e)).toList();
      nameControllers = branchs
          .map((item) => TextEditingController(text: item['branch_name']?.toString() ?? ''))
          .toList();

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(backgroundColor: Colors.white,body: Center(child: CircularProgressIndicator()));
    }
    final maxwidth = MediaQuery.of(context).size.width;
    final maxheight = MediaQuery.of(context).size.height;
    final minheight = maxheight / 5 < 100 ? 100.00 : maxheight / 5;
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppbarWidget(txtt: 'Branch Management'),
      // drawer: const SideBarWidget(),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setStateDialog) {
                  return AlertDialog(
                    title: SizedBox(height: 40, child: Text("สร้าง Branch ใหม่")),
                    content: Container(
                      width: maxwidth,
                      height: minheight,
                      child: Column(
                        children: [
                          SizedBox(width: maxwidth, child: Text("ชื่อBranch")),
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  newname['newname'] = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          newname['newname'] = '';
                          Navigator.of(context).pop();
                        },
                        child: Text('ยกเลิก'),
                      ),
                      TextButton(
                        style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                        onPressed: () async {
                          if (newname['newname'] != '') {
                            final response = await ApiService.createBranch(newname);
                            if (response['status'] == 'success') {
                              _fetchData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Branch ใหม่ ${newname['newname']} ถูกสร้างแล้ว! ")),
                              );
                            } else {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาดในการสร้าง")));
                            }
                          } else {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text("Branch ใหม่ จำเป็นต้องมีชื่อ! ")));
                          }
                          newname['newname'] = '';
                          Navigator.of(context).pop();
                        },
                        child: Text('สร้าง', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        backgroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: Container(
          height: maxheight - kToolbarHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 196, 196, 196),
                Color.fromARGB(255, 116, 116, 116),
                // Color.fromARGB(255, 252, 255, 207),
                // Color.fromARGB(255, 255, 206, 206),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: branchs.asMap().entries.map((entry) {
                int index = entry.key;
                var item = entry.value;
                return Container(
                  width: maxwidth,
                  height: maxheight * 0.08,
                  padding: EdgeInsets.all(4),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 255, 255, 255),
                          Color.fromARGB(255, 255, 255, 255),
                          Color.fromARGB(255, 255, 255, 255),
                          Color.fromARGB(255, 226, 255, 225),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      boxShadow: [
                        BoxShadow(blurRadius: 4, spreadRadius: 1, color: Colors.black26, offset: Offset(0, 3)),
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: maxwidth * 0.1,
                          child: Center(
                            child: Text(item['branch_id'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (context, setStateDialog) {
                                      return AlertDialog(
                                        title: SizedBox(height: 20),
                                        backgroundColor: Colors.white,
                                        titlePadding: EdgeInsets.all(0),
                                        contentPadding: EdgeInsets.all(0),
                                        content: Container(
                                          padding: EdgeInsets.all(12),
                                          width: maxwidth,
                                          height: 200,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                width: maxwidth,
                                                child: Center(
                                                  child: Text(
                                                    "เปลี่ยนชื่อ branch",
                                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                              const Divider(),
                                              Row(
                                                children: [
                                                  SizedBox(width: maxwidth * 0.2, child: Text("ชื่อเดิม : ")),
                                                  Expanded(
                                                    child: Text(item['branch_name'], style: TextStyle(fontSize: 16)),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 20),
                                              Row(
                                                children: [
                                                  SizedBox(width: maxwidth * 0.2, child: Text("ชื่อใหม่ : ")),
                                                  Expanded(
                                                    child: TextField(
                                                      controller: nameControllers[index],
                                                      onChanged: (value) {
                                                        temp[index]['branch_name'] = value;
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.of(context).pop(); // ปิด popup
                                              setState(() {
                                                nameControllers[index].text = item['branch_name'];
                                                temp = branchs.map((e) => Map<String, dynamic>.from(e)).toList();
                                              });
                                            },
                                            child: const Text('ยกเลิก'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              setState(() {
                                                branchs = temp.map((e) => Map<String, dynamic>.from(e)).toList();
                                              });

                                              final response = await ApiService.updateBranchById(branchs[index]);
                                              if (response['status'] == 'success') {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "ทำการเปลี่ยนชื่อเป็น ${branchs[index]['branch_name']} เรียบร้อยแล้ว.",
                                                    ),
                                                  ),
                                                );
                                                Navigator.of(context).pop();
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text("เกิดข้อผิดพลาดในการแก้ไขชื่อ โปรดลองอีกครั้ง."),
                                                  ),
                                                );
                                              }
                                            },
                                            child: const Text('บันทึก'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            child: Text(
                              item['branch_name'],
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: maxwidth * 0.1,
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (context, setStateDialog) {
                                      return AlertDialog(
                                        title: SizedBox(height: 40, child: Text("แจ้งเตือน!!")),
                                        content: SizedBox(
                                          width: maxwidth,
                                          height: 120,
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Text('คุณต้องการลบ ${item['branch_name']} ใช่หรือไม่?'),
                                                SizedBox(height: 20),
                                                Text(
                                                  "**หากลบแล้วจะไม่สามารถกู้คืนได้ ทำให้ผู้ใช้บางส่วนที่เกี่ยวข้องกับ ${item['branch_name']} จะไม่สามารถเข้าสู่ระบบได้!",
                                                  style: TextStyle(color: Colors.red),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('ยกเลิก'),
                                          ),
                                          TextButton(
                                            style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red)),
                                            onPressed: () async {
                                              final response = await ApiService.deleteBranchById(branchs[index]);
                                              if (response['status'] == 'success') {
                                                _fetchData();
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text("ลบ ${item['branch_name']} แล้ว")),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text("เกิดข้อผิดพลาดในการลบ โปรดลองอีกครั้ง.")),
                                                );
                                              }
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('ลบ', style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            child: Icon(Icons.delete),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
