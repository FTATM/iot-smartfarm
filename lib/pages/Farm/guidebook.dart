import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/ViewPDF.dart';
import 'package:iot_app/components/session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

class GuidebookPage extends StatefulWidget {
  const GuidebookPage({super.key});

  @override
  State<GuidebookPage> createState() => _GuidebookPageState();
}

class _GuidebookPageState extends State<GuidebookPage> {
  bool isLoading = true;
  bool isEditing = false;
  String? pdfPath;
  List<dynamic> pdfs = [];
  List<dynamic> branchs = [];

  @override
  void initState() {
    super.initState();
    prepare();
  }

  Future<void> prepare() async {
    final res = await ApiService.fetchPDFsById(CurrentUser['branch_id']);
    final bres = await ApiService.fetchBranchAll();
    setState(() {
      pdfs = res['data'] ?? [];
      branchs = bres['data'] ?? [];
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
    return Scaffold(
      floatingActionButton: Visibility(
        visible: int.parse(CurrentUser['role_id']) >= 88,
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              isEditing = !isEditing;
            });
          },
          backgroundColor: Colors.white,
          child: Icon(Icons.edit),
        ),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(centerTitle: true, title: Text("คู่มือการใช้งาน Application"), backgroundColor: Colors.white),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: maxwidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Visibility(
                  visible: isEditing,
                  child: GestureDetector(
                    onTap: () {
                      TextEditingController input = TextEditingController();
                      Uint8List? fileBytes; // ข้อมูลไฟล์
                      String originalName = ""; // ชื่อไฟล์ต้นฉบับ
                      String? selectedBranchId; // ชื่อไฟล์ต้นฉบับ
                      String notifyDropdown = "";
                      String notifybranch = "";
                      showDialog(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setStateDialog) => AlertDialog(
                              backgroundColor: Colors.white,
                              title: Text("เพิ่มไฟล์"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 10,
                                children: [
                                  Text(originalName),
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 255, 136, 0)),
                                    ),
                                    onPressed: () async {
                                      // ---------------- Web ----------------
                                      if (kIsWeb) {
                                        final uploadInput = html.FileUploadInputElement();
                                        uploadInput.accept = 'application/pdf'; // 🔥 PDF เท่านั้น
                                        uploadInput.click();

                                        uploadInput.onChange.listen((event) async {
                                          final file = uploadInput.files?.first;
                                          if (file == null) return;

                                          // 🔒 ตรวจซ้ำเพื่อความชัวร์
                                          if (!file.name.toLowerCase().endsWith('.pdf')) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('กรุณาเลือกไฟล์ PDF เท่านั้น')),
                                            );
                                            return;
                                          }

                                          originalName = file.name;

                                          final reader = html.FileReader();
                                          reader.readAsArrayBuffer(file);
                                          await reader.onLoad.first;

                                          final bytes = reader.result as Uint8List;
                                          fileBytes = bytes;

                                          // เก็บ temp ชั่วคราว (Base64)
                                          final base64Data = base64Encode(bytes);
                                          html.window.localStorage[file.name] = base64Data;

                                          setStateDialog(() {
                                            originalName = file.name;
                                          });
                                        });
                                      }
                                      // ---------------- Mobile ----------------
                                      else {
                                        final result = await FilePicker.platform.pickFiles(
                                          type: FileType.custom,
                                          allowedExtensions: ['pdf'], // 🔥 PDF เท่านั้น
                                          withData: true,
                                        );

                                        if (result == null) return;

                                        final pickedFile = result.files.first;

                                        // 🔒 ตรวจซ้ำ
                                        if (!pickedFile.name.toLowerCase().endsWith('.pdf')) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(const SnackBar(content: Text('กรุณาเลือกไฟล์ PDF เท่านั้น')));
                                          return;
                                        }

                                        fileBytes = pickedFile.bytes!;
                                        originalName = pickedFile.name;

                                        final prefs = await SharedPreferences.getInstance();
                                        await prefs.setString(pickedFile.name, base64Encode(fileBytes!));

                                        setStateDialog(() {
                                          originalName = pickedFile.name;
                                        });
                                      }
                                    },
                                    child: const Text("เลือกไฟล์ PDF", style: TextStyle(color: Colors.white)),
                                  ),
                                  Text(notifyDropdown, style: TextStyle(color: Colors.red)),
                                  TextField(
                                    controller: input,
                                    decoration: InputDecoration(hintText: "ตั้งชื่อไฟล์ (ไม่ใส่จะใช้ชื่อไฟล์ต้นฉบับ)"),
                                  ),

                                  DropdownButton<String>(
                                    hint: Text('เลือกโรงเรือน'),
                                    value: selectedBranchId,
                                    isExpanded: true,
                                    items: branchs.map<DropdownMenuItem<String>>((e) {
                                      return DropdownMenuItem<String>(
                                        value: e['branch_id'].toString(), // value ที่ส่งกลับ
                                        child: Text(e['branch_name']), // ข้อความที่แสดง
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setStateDialog(() {
                                        selectedBranchId = value ?? '1';
                                      });
                                    },
                                  ),
                                  Text(notifybranch, style: TextStyle(color: Colors.red)),
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
                                  style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.orange)),
                                  onPressed: () async {
                                    if (fileBytes != null) {
                                      String saveName = (input.text.trim().isEmpty || input.text.trim() == "")
                                          ? originalName
                                          : "${input.text.trim()}.pdf";

                                      bool success = await ApiService.uploadpdfFile(
                                        saveName,
                                        selectedBranchId ?? '1',
                                        fileBytes!,
                                      );
                                      if (success) {
                                        if (kIsWeb)
                                          html.window.localStorage.remove(originalName);
                                        else {
                                          final prefs = await SharedPreferences.getInstance();
                                          prefs.remove(originalName);
                                        }
                                        prepare();

                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(SnackBar(content: Text("อัปโหลดสำเร็จ")));
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(SnackBar(content: Text("อัปโหลดไม่สำเร็จ")));
                                      }
                                    } else {
                                      setStateDialog(() {
                                        notifyDropdown = "ยังไม่มีไฟล์ที่ถูกเลือก";
                                      });
                                    }
                                  },
                                  child: Text("บันทึก", style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 75,
                      width: maxwidth * 0.8,
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 240, 240, 240),
                            Color.fromARGB(255, 240, 240, 240),
                            Color.fromARGB(255, 240, 240, 240),
                            Color.fromARGB(255, 224, 224, 224),
                          ],
                          // radius: 3
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Icon(Icons.add),
                    ),
                  ),
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: pdfs.map((pdf) {
                    return Container(
                      height: 60,
                      width: maxwidth * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 240, 240, 240),
                            Color.fromARGB(255, 240, 240, 240),
                            Color.fromARGB(255, 240, 240, 240),
                            Color.fromARGB(255, 224, 224, 224),
                          ],
                          // radius: 3
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Stack(
                        children: [
                          GestureDetector(
                            child: Container(
                              width: maxwidth * 0.8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 240, 240, 240),
                                    Color.fromARGB(255, 240, 240, 240),
                                    Color.fromARGB(255, 240, 240, 240),
                                    Color.fromARGB(255, 224, 224, 224),
                                  ],
                                  // radius: 3
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Padding(padding: EdgeInsetsGeometry.all(10), child: Icon(Icons.file_copy_rounded)),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      SizedBox(
                                        width: maxwidth * 0.7 - 20,
                                        child: Text(
                                          pdf['name'].length > 15 ? pdf['name'].substring(0, 15) + '...' : pdf['name'],
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        width: maxwidth * 0.7 - 20,
                                        child: Text(pdf['create_at'], style: TextStyle(color: Colors.grey)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ViewPDFPage(filepdf: pdf)));
                            },
                          ),
                          Visibility(
                            visible: isEditing,
                            child: GestureDetector(
                              child: Align(
                                alignment: AlignmentGeometry.topRight,
                                child: Container(
                                  child: Padding(padding: EdgeInsetsGeometry.all(10), child: Icon(Icons.delete)),
                                ),
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setStateDialog) => AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: Text("แจ้งเตือน!!"),
                                        content: Container(
                                          height: 50,
                                          child: Center(child: Text("คุณต้องการลบไฟล์ ${pdf['name']} ใช่หรือไม่?")),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                            },
                                            child: Text("ยกเลิก"),
                                          ),
                                          ElevatedButton(
                                            style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red)),
                                            onPressed: () async {},
                                            child: Text("ลบ", style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
