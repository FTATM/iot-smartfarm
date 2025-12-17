import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/appbar.dart';
// import 'package:iot_app/components/session.dart';
import 'package:iot_app/components/sidebar.dart';
// import 'package:iot_app/pages/config-Create.dart';
import 'package:file_picker/file_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:universal_html/html.dart' as html;

class IconsPage extends StatefulWidget {
  const IconsPage({super.key});

  @override
  State<IconsPage> createState() => _IconsPageState();
}

class _IconsPageState extends State<IconsPage> {
  bool isLoading = true;
  List<dynamic> icons = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    final response = await ApiService.fetchIcons();
    if (!mounted) return;

    // ✅ อัปเดต state เพื่อให้ UI render ใหม่
    setState(() {
      icons = response['data'] as List;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(backgroundColor: Colors.white,body: Center(child: CircularProgressIndicator()));
    }
    final maxwidth = MediaQuery.of(context).size.width;
    // final maxheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppbarWidget(txtt: 'Icons Management'),
      // drawer: const SideBarWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TextEditingController input = TextEditingController();
          Uint8List? fileBytes; // ข้อมูลไฟล์
          String originalName = ""; // ชื่อไฟล์ต้นฉบับ

          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setStateDialog) => AlertDialog(
                  title: Text("เพิ่มไฟล์"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (fileBytes != null) Image.memory(fileBytes!, height: 100),
                      SizedBox(height: 10),
                      TextField(
                        controller: input,
                        decoration: InputDecoration(hintText: "ตั้งชื่อไฟล์ (ไม่ใส่จะใช้ชื่อไฟล์ต้นฉบับ)"),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          // ---------------- Web ----------------
                          if (kIsWeb) {
                            html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
                            uploadInput.accept = 'image/*';
                            uploadInput.click();

                            uploadInput.onChange.listen((event) async {
                              final file = uploadInput.files?.first;
                              if (file == null) return;
                              originalName = file.name;

                              final reader = html.FileReader();
                              reader.readAsArrayBuffer(file);
                              await reader.onLoad.first;

                              final bytes = reader.result as Uint8List;
                              fileBytes = bytes;

                              // เก็บ temp ชั่วคราวใน localStorage (Base64)
                              final base64Data = base64Encode(bytes);
                              html.window.localStorage[file.name] = base64Data;

                              setStateDialog(() {});
                            });
                          }
                          // ---------------- Mobile ----------------
                          else {
                            final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
                            if (result == null) return;

                            final pickedFile = result.files.first;
                            fileBytes = pickedFile.bytes!;
                            originalName = pickedFile.name;

                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString(pickedFile.name, base64Encode(fileBytes!));

                            setState(() {});
                          }
                        },
                        child: Text("เลือกไฟล์"),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        if (kIsWeb)
                          html.window.localStorage.remove(originalName);
                        else {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.remove(originalName);
                        }
                        Navigator.pop(context);
                      },
                      child: Text("ยกเลิก"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (fileBytes != null) {
                          String saveName = (input.text.trim().isEmpty || input.text.trim() == "")
                              ? originalName
                              : "${input.text.trim()}.png";

                          bool success = await ApiService.uploadFile(saveName, fileBytes!);
                          if (success) {
                            if (kIsWeb)
                              html.window.localStorage.remove(originalName);
                            else {
                              final prefs = await SharedPreferences.getInstance();
                              prefs.remove(originalName);
                            }
                            final newIcons = await ApiService.fetchIcons();
                            print(newIcons['data']);
                            setState(() {
                              icons = newIcons['data'] as List;
                            });

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("อัปโหลดสำเร็จ")));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("อัปโหลดไม่สำเร็จ")));
                          }
                        }
                      },
                      child: Text("บันทึก"),
                    ),
                  ],
                ),
              );
            },
          );
        },
        backgroundColor: Colors.white,
        child: Icon(Icons.add),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Wrap(
            children: icons.asMap().entries.map((entry) {
              // int index = entry.key;
              var item = entry.value;
              return Container(
                width: maxwidth / 2,
                height: maxwidth / 2,
                padding: EdgeInsets.all(12),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromARGB(255, 255, 255, 255), // 💙 สีเริ่มต้น
                              const Color.fromARGB(255, 184, 229, 255), // 💜 สีปลายทาง
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                        // color: Colors.purpleAccent,
                        width: (maxwidth / 2 - 24),
                        height: (maxwidth / 2 - 24) * 0.8,
                        child: Image.network("http://49.0.69.152/iotsf/${item['path']}"),
                      ),

                      Container(
                        // color: Colors.amber,
                        width: (maxwidth / 2 - 24),
                        height: (maxwidth / 2 - 24) * 0.2,
                        padding: EdgeInsets.only(left: 8, right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              child: Text(item['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(
                              width: 20,
                              child: GestureDetector(
                                onTap: () {
                                  print("Delete clicked");
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("แจ้งเตือน"),
                                      content: Text("ต้องการที่จะลบ   '${item['name']}'   ใช่หรือไม่ ?"),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context), child: Text("ยกเลิก")),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            var response = await ApiService.deleteIconById(item);
                                            if (response['status'] == 'success') {
                                              final newIcons = await ApiService.fetchIcons();
                                              print(newIcons['data']);
                                              setState(() {
                                                icons = newIcons['data'] as List;
                                              });
                                            }
                                          },
                                          child: Text("ยืนยัน", style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: SizedBox(width: 20, child: Icon(Icons.delete)),
                              ),
                            ),
                          ],
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
    );
  }
}
