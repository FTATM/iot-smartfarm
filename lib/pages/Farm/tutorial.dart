import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/session.dart';
import 'package:iot_app/pages/Farm/guidebook.dart';
import 'package:iot_app/pages/Farm/knowledge.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
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
    final fs_large = maxwidth > 500 ? 30.0 : 18.0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(centerTitle: true, title: Text("Tutorials"), backgroundColor: Colors.white),

      body: SafeArea(
        child: Center(
          child: Wrap(
            spacing: maxwidth * 0.1,
            runSpacing: maxwidth * 0.1,
            children: [
              GestureDetector(
                child: Container(
                  color: Color.fromARGB(255, 255, 136, 0),
                  width: maxwidth > 500 ? (maxwidth / 2) * 0.8 : maxwidth * 0.8,
                  height: maxwidth > 500 ? (maxwidth / 2) * 0.8 : maxwidth * 0.5,
                  padding: EdgeInsets.all(10),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          // "ความรู้การเลี้ยงสัตว์",
                          "Livestock Farming Knowledge",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fs_large + 4,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          // "พื้นฐาน • แนวทาง • การจัดการฟาร์ม",
                          "Basic • Approach • Farm Management",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: fs_large - 2, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const KnowledgePage()));
                },
              ),
              GestureDetector(
                child: Container(
                  color: Colors.grey[800],
                  width: maxwidth > 500 ? (maxwidth / 2) * 0.8 : maxwidth * 0.8,
                  height: maxwidth > 500 ? (maxwidth / 2) * 0.8 : maxwidth * 0.5,
                  padding: EdgeInsets.all(10),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          // "คลังเอกสาร & คู่มือ (PDF)",
                          "Document & Manual Archive (PDF)",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: fs_large + 4,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          // "ไฟล์สอนการใช้งาน • ดาวน์โหลดเอกสาร",
                          "Tutorial Files • Download Documents",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: fs_large - 2, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),

                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const GuidebookPage()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
