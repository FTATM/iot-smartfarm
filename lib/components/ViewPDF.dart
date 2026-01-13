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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          pdf['name'] + '.pdf',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: kIsWeb
          ? _buildErrorState(
              icon: Icons.description_outlined,
              title: 'ไม่สามารถเปิดเอกสารได้',
              subtitle: 'ไฟล์ PDF นี้ไม่รองรับการแสดงผลในระบบนี้',
            )
          : isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.orange))
              : pdfFile == null
                  ? _buildErrorState(
                      icon: Icons.description_outlined,
                      title: 'ไม่สามารถเปิดเอกสารได้',
                      subtitle: 'ไฟล์ PDF นี้ไม่รองรับการแสดงผลในระบบนี้',
                    )
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

  Widget _buildErrorState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 40),
        padding: EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.orange.withOpacity(0.1),
                    Colors.orange.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 64,
                  color: Colors.orange,
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}