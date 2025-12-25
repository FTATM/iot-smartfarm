import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/session.dart';

class ViewPDFPage extends StatefulWidget {
  final Map<String, dynamic> filepdf;

  const ViewPDFPage({super.key, required this.filepdf});

  @override
  State<ViewPDFPage> createState() => _ViewPDFPageState();
}

class _ViewPDFPageState extends State<ViewPDFPage> {
  bool isLoading = true;
  late Map<String, dynamic> pdf;
  File? pdfFile;

  @override
  void initState() {
    super.initState();
    setState(() {
      pdf = widget.filepdf;
    });
    _initPdf();
  }

  Future<void> _initPdf() async {
    print("---------------init-------------------");
    if (pdf.isEmpty || pdf['path'].isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    try {
      final file = await ApiService.loadPdfFromServer(pdf['id'], CurrentUser['branch_id']);
      print("-------------------------------------");
      print("File exists: ${await file.exists()}");
      print("File size: ${await file.length()} bytes");
      setState(() {
        pdfFile = file;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        pdfFile = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pdf['name'] + '.pdf'), backgroundColor: Colors.white),
      body: kIsWeb
          ? Center(child: Text('ไฟล์ PDF ไม่รองรับการเปิดในเว็บไซต์\nโปรดลองอีกครั้งในอุปกรณ์พกพา.'))
          : isLoading
          ? Center(child: CircularProgressIndicator())
          : pdfFile == null
          ? Center(child: Text('ไม่พบไฟล์ PDF นี้ โปรดติดต่อผู้ดูแลระบบ.'))
          : Column(
              children: [
                Expanded(
                  child: PDFView(
                    filePath: pdfFile!.path,
                    enableSwipe: true,
                    swipeHorizontal: false,
                    autoSpacing: true,
                    pageSnap: true,
                    onError: (e) => print('PDF error: $e'),
                    onPageError: (p, e) => print('PDF page error: $p $e'),
                  ),
                ),
              ],
            ),
    );
  }
}
