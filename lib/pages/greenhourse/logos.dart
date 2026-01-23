import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/appbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:iot_app/components/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:universal_html/html.dart' as html;

const Color brandOrange = Color(0xFFFF8021);
const Color brandOrangeLight = Color(0xFFFF9D52);

class LogosPage extends StatefulWidget {
  const LogosPage({super.key});

  @override
  State<LogosPage> createState() => _LogosPageState();
}

class _LogosPageState extends State<LogosPage> {
  bool isLoading = true;
  List<dynamic> logos = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    final response = await ApiService.fetchLogos();
    if (!mounted) return;

    setState(() {
      logos = response['data'] as List;
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
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppbarWidget(txtt: 'Logos Management'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddIconDialog(context),
        backgroundColor: brandOrange,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: logos.map((item) {

                return Container(
                  width: (maxwidth - 24) / 2,
                  child: Card(
                    elevation: 3,
                    shadowColor: const Color.fromARGB(66, 0, 0, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Image Container with Gradient
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFFF8F0),
                                Color(0xFFFFE4CC),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          width: double.infinity,
                          height: (maxwidth - 24) / 2 * 0.7,
                          padding: const EdgeInsets.all(20),
                          child: Image.network(
                            "${CurrentUser['baseURL']}../${item['path']}",
                            fit: BoxFit.contain,
                          ),
                        ),

                        // Name and Delete Button Container
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                              color: Colors.white, // กำหนดสีพื้นหลังเป็นสีขาว
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12), // โค้งมุมด้านล่างซ้าย
                                bottomRight: Radius.circular(12), // โค้งมุมด้านล่างขวา
                              ),
                            ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  item['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _showDeleteDialog(context, item),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: Colors.grey[700],
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
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  // ================= Premium Add Icon Dialog =================
  void _showAddIconDialog(BuildContext context) {
    TextEditingController input = TextEditingController();
    Uint8List? fileBytes;
    String originalName = "";

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) => Stack(
            children: [
              // iOS blur background
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),

              Center(
                child: Dialog(
                  insetPadding: const EdgeInsets.all(16),
                  backgroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Container(
                    width: 360,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.6)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.12),
                          blurRadius: 40,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -24,
                          right: -24,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: brandOrange.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFF5ED),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.image,
                                    color: brandOrange,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "เพิ่มโลโก้ใหม่",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Image Preview
                            if (fileBytes != null)
                              Center(
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFF8F0),
                                        Color(0xFFFFE4CC),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    border: Border.all(
                                        color: Colors.grey[300]!),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Image.memory(fileBytes!,
                                      fit: BoxFit.contain),
                                ),
                              ),

                            if (fileBytes != null)
                              const SizedBox(height: 24),

                            // File Name Input
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Text(
                                "ชื่อไฟล์",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff464646),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: input,
                              decoration: InputDecoration(
                                hintText:
                                    "ตั้งชื่อไฟล์ (ไม่ใส่จะใช้ชื่อไฟล์ต้นฉบับ)",
                                filled: true,
                                fillColor: const Color(0xFFF9FAFB),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE5E7EB)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: brandOrange),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Upload Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  if (kIsWeb) {
                                    html.FileUploadInputElement uploadInput =
                                        html.FileUploadInputElement();
                                    uploadInput.accept = 'image/*';
                                    uploadInput.click();

                                    uploadInput.onChange
                                        .listen((event) async {
                                      final file = uploadInput.files?.first;
                                      if (file == null) return;
                                      originalName = file.name;

                                      final reader = html.FileReader();
                                      reader.readAsArrayBuffer(file);
                                      await reader.onLoad.first;

                                      final bytes =
                                          reader.result as Uint8List;
                                      fileBytes = bytes;

                                      final base64Data = base64Encode(bytes);
                                      html.window.localStorage[file.name] =
                                          base64Data;

                                      setStateDialog(() {});
                                    });
                                  } else {
                                    final result = await FilePicker.platform
                                        .pickFiles(
                                            type: FileType.image,
                                            withData: true);
                                    if (result == null) return;

                                    final pickedFile = result.files.first;
                                    fileBytes = pickedFile.bytes!;
                                    originalName = pickedFile.name;

                                    final prefs = await SharedPreferences
                                        .getInstance();
                                    await prefs.setString(pickedFile.name,
                                        base64Encode(fileBytes!));

                                    setStateDialog(() {});
                                  }
                                },
                                icon: const Icon(Icons.upload_file,
                                    size: 20),
                                label: const Text("เลือกไฟล์"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: brandOrange,
                                  side: const BorderSide(
                                      color: brandOrange, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Save Button
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () async {
                                  if (fileBytes != null) {
                                    String saveName = (input.text
                                                    .trim()
                                                    .isEmpty ||
                                                input.text.trim() == "")
                                        ? originalName
                                        : "${input.text.trim()}.png";

                                    bool success =
                                        await ApiService.createLogo(
                                            saveName, fileBytes!);
                                    if (success) {
                                      if (kIsWeb)
                                        html.window.localStorage
                                            .remove(originalName);
                                      else {
                                        final prefs = await SharedPreferences
                                            .getInstance();
                                        prefs.remove(originalName);
                                      }
                                      final newlogos =
                                          await ApiService.fetchLogos();
                                      setState(() {
                                        logos = newlogos['data'] as List;
                                      });

                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content:
                                                  Text("อัปโหลดสำเร็จ")));
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "อัปโหลดไม่สำเร็จ")));
                                    }
                                  }
                                },
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        brandOrange,
                                        brandOrangeLight,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color.fromRGBO(
                                            255, 128, 33, 0.35),
                                        blurRadius: 14,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  
                                  child: const Center(
                                    child: Text(
                                      "บันทึก",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: TextButton(
                                onPressed: () async {
                                  if (kIsWeb)
                                    html.window.localStorage
                                        .remove(originalName);
                                  else {
                                    final prefs = await SharedPreferences
                                        .getInstance();
                                    prefs.remove(originalName);
                                  }
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "ยกเลิก",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= Premium Delete Dialog =================
  void _showDeleteDialog(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (context) {
        return Stack(
          children: [
            // iOS blur background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),

            Center(
              child: Dialog(
                insetPadding: const EdgeInsets.all(20),
                backgroundColor: const Color(0xFFF6F1F4),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Container(
                  width: 340,
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.18),
                        blurRadius: 30,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Text(
                        "แจ้งเตือน",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Message
                      Text(
                        "คุณต้องการลบ '${item['name']}' ใช่หรือไม่?",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFFE53935),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "หากลบแล้วไม่สามารถกู้คืนได้",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFFE53935),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Cancel
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "ยกเลิก",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Delete
                          SizedBox(
                            height: 42,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: () async {
                                Navigator.pop(context);
                                var response =
                                    await ApiService.deleteIconById(item);
                                if (response['status'] == 'success') {
                                  final newlogos =
                                      await ApiService.fetchLogos();
                                  setState(() {
                                    logos = newlogos['data'] as List;
                                  });
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                          content: Text("ลบสำเร็จ")));
                                }
                              },
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF44336),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromRGBO(
                                          244, 67, 54, 0.35),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 8,
                                ),
                                child: const Text(
                                  "ลบ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}