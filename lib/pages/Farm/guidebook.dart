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
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final maxwidth = MediaQuery.of(context).size.width;
    final maxheight = MediaQuery.of(context).size.height - kTextTabBarHeight;
    return Scaffold(
      floatingActionButton: Visibility(
        visible: int.parse(CurrentUser['role_id']) >= 88,
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              isEditing = !isEditing;
            });
          },
          backgroundColor: Color(0xFFFF8C00),
          child: Icon(
            isEditing ? Icons.close : Icons.edit,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "คู่มือการใช้งานแอปพลิเคชัน",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Visibility(
                visible: isEditing,
                child: GestureDetector(
                  onTap: () {
                    TextEditingController input = TextEditingController();
                    Uint8List? fileBytes;
                    String originalName = "";
                    String? selectedBranchId;
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
                                    if (kIsWeb) {
                                      final uploadInput = html.FileUploadInputElement();
                                      uploadInput.accept = 'application/pdf';
                                      uploadInput.click();

                                      uploadInput.onChange.listen((event) async {
                                        final file = uploadInput.files?.first;
                                        if (file == null) return;

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

                                        final base64Data = base64Encode(bytes);
                                        html.window.localStorage[file.name] = base64Data;

                                        setStateDialog(() {
                                          originalName = file.name;
                                        });
                                      });
                                    } else {
                                      final result = await FilePicker.platform.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: ['pdf'],
                                        withData: true,
                                      );

                                      if (result == null) return;

                                      final pickedFile = result.files.first;

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
                                      value: e['branch_id'].toString(),
                                      child: Text(e['branch_name']),
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
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Color(0xFFFFF4E6),
                      border: Border.all(
                        color: Color(0xFFFF8C00),
                        width: 2,
                      ),
                    ),
                    child: Icon(Icons.add, size: 32, color: Color(0xFFFF8C00)),
                  ),
                ),
              ),
              Column(
                children: pdfs.map((pdf) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ViewPDFPage(filepdf: pdf)));
                            },
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFF4E6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.description_outlined,
                                      color: Color(0xFFFF8C00),
                                      size: 28,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pdf['name'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              size: 14,
                                              color: Colors.grey[500],
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              pdf['create_at'],
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isEditing)
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey[400],
                                      size: 28,
                                    ),
                                  if (isEditing)
                                    GestureDetector(
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
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.grey[600],
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
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
    );
  }
}