import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/appbar.dart';
import 'package:iot_app/components/session.dart';
import 'dart:ui';

class KnowledgePage extends StatefulWidget {
  const KnowledgePage({super.key});

  @override
  State<KnowledgePage> createState() => _KnowledgePageState();
}

class _KnowledgePageState extends State<KnowledgePage> {
  bool isLoading = true;
  int diffDay = 0;
  List<dynamic> tables = [];
  List<dynamic> mainboard = [];
  List<dynamic> filterDates = [];

  Color primaryColor = Color.fromARGB(255, 255, 131, 0);
  Color blackColor = Colors.black;
  Color whiteColor = Colors.white;

  @override
  void initState() {
    super.initState();
    prepare();
  }


  Future<void> prepare() async {
    final responsetable = await ApiService.fetchTablesknowledgeById(CurrentUser['branch_id']);

    final resBoardMain = await ApiService.fetchMainboard();

    setState(() {
      tables = responsetable['data'];
      mainboard = resBoardMain['data'];
      isLoading = false;
    });

    filterDates = mainboard.where((element) {
      return element['name'].toString().startsWith('date');
    }).toList();

    calculateDay(filterDates[1]['value'], filterDates[0]['value']);

    debugPrint(tables.toString());
    debugPrint(mainboard.toString());
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor), strokeWidth: 3),
              SizedBox(height: 16),
              Text('กำลังโหลดข้อมูล...', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            ],
          ),
        ),
      );
    }

    final parentTables = tables.where((e) => e['child_of_table_id'] == null).toList();
    final childTables = tables.where((e) => e['child_of_table_id'] != null).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppbarWidget(txtt: "ข้อมูลพื้นฐานฟาร์ม"),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Single Tables
          for (var item in parentTables.where((e) => !childTables.any((c) => c['child_of_table_id'] == e['id'])))
            _buildSingleTable(item),

          // Parent + Child Tables
          for (var parent in parentTables.where((e) => childTables.any((c) => c['child_of_table_id'] == e['id'])))
            _buildParentChildTable(parent, childTables),
        ],
      ),
    );
  }

  Widget _buildSingleTable(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: whiteColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Icon(_getIconForTable(item['name']), color: whiteColor, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "${item['name']}",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: whiteColor),
                  ),
                ),
              ],
            ),
          ),

          // Table content - responsive
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 400;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Table(
                  border: TableBorder(horizontalInside: BorderSide(color: Colors.grey.shade200, width: 1)),
                  columnWidths: {0: FlexColumnWidth(isNarrow ? 0.8 : 1), 1: FlexColumnWidth(isNarrow ? 1 : 1.2)},
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: isNarrow ? 8 : 12, vertical: 12),
                          child: Text(
                            "ช่วงวัน",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isNarrow ? 13 : 14,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: isNarrow ? 8 : 12, vertical: 12),
                          child: Text(
                            item['label'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isNarrow ? 13 : 14,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    ...item['rows'].map<TableRow>((row) {
                      final endView = row['d_end_day'] == '99' ? "เป็นต้นไป" : row['d_end_day'];
                      final start = int.parse(row['d_start_day'].toString());
                      final end = row['d_end_day'].toString() == '99' ? 99999 : int.parse(row['d_end_day'].toString());

                      final isThisDay = start <= diffDay && end >= diffDay;
                      return TableRow(
                        decoration: BoxDecoration(
                          color: isThisDay ? const Color.fromARGB(255, 255, 228, 203) : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: isNarrow ? 8 : 12, vertical: 14),
                            child: Text(
                              "$start - $endView",
                              style: TextStyle(fontSize: isNarrow ? 13 : 14, color: Colors.grey.shade800),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: isNarrow ? 8 : 12, vertical: 14),
                            child: Text(
                              row['d_value'] ?? "-",
                              style: TextStyle(
                                fontSize: isNarrow ? 13 : 14,
                                fontWeight: FontWeight.w600,
                                color: blackColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildParentChildTable(dynamic parent, List<dynamic> children) {
    final childList = children.where((c) => c['child_of_table_id']?.toString() == parent['id'].toString()).toList();
    final List rows = parent['rows'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: whiteColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Icon(_getIconForTable(parent['name']), color: whiteColor, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    parent['name'],
                    style: TextStyle(color: whiteColor, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Table content with horizontal scroll - responsive
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = MediaQuery.of(context).size.width;
              final totalColumns = childList.length + 2;

              // Dynamic column width based on screen size and number of columns
              final baseColWidth = screenWidth < 400 ? 100.0 : 140.0;
              final dayColWidth = screenWidth < 400 ? 90.0 : 110.0;
              final minWidth = (totalColumns - 1) * baseColWidth + dayColWidth;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth > constraints.maxWidth ? minWidth : constraints.maxWidth - 32,
                  ),
                  child: Table(
                    border: TableBorder(horizontalInside: BorderSide(color: Colors.grey.shade200, width: 1)),
                    columnWidths: {
                      0: FixedColumnWidth(dayColWidth),
                      for (int i = 0; i < childList.length + 1; i++) i + 1: FixedColumnWidth(baseColWidth),
                    },
                    defaultColumnWidth: FixedColumnWidth(baseColWidth),
                    children: [
                      // Header row
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                            child: Text(
                              "ช่วงวัน",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth < 400 ? 12 : 13,
                                color: Colors.grey.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                            child: Text(
                              parent['label'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth < 400 ? 12 : 13,
                                color: Colors.grey.shade700,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          for (var c in childList)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                              child: Text(
                                c['label'] ?? "",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth < 400 ? 12 : 13,
                                  color: Colors.grey.shade700,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),

                      // Data rows
                      ...rows.map<TableRow>((row) {
                        final endView = row['d_end_day'] == '99' ? "เป็นต้นไป" : row['d_end_day'];
                        final start = int.parse(row['d_start_day'].toString());
                        final end = row['d_end_day'].toString() == '99'
                            ? 99999
                            : int.parse(row['d_end_day'].toString());

                        final isThisDay = start <= diffDay && end >= diffDay;

                        return TableRow(
                          decoration: BoxDecoration(
                            color: isThisDay ? const Color.fromARGB(255, 255, 228, 203) : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 14),
                              child: Text(
                                "$start - $endView",
                                style: TextStyle(fontSize: screenWidth < 400 ? 12 : 13, color: Colors.grey.shade800),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 14),
                              child: Text(
                                row['d_value'] ?? "-",
                                style: TextStyle(
                                  fontSize: screenWidth < 400 ? 12 : 13,
                                  fontWeight: FontWeight.w600,
                                  color: blackColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            for (var c in childList)
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 14),
                                child: Center(
                                  child: Builder(
                                    builder: (_) {
                                      final rowsChild = c['rows'] ?? [];
                                      final match = rowsChild.firstWhere(
                                        (r) => r['d_row_parent_id'] == row['d_id'],
                                        orElse: () => null,
                                      );

                                      return Text(
                                        match['d_value'],
                                        style: TextStyle(
                                          fontSize: screenWidth < 400 ? 12 : 13,
                                          fontWeight: FontWeight.w600,
                                          color: blackColor,
                                        ),
                                        textAlign: TextAlign.center,
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getIconForTable(String? label) {
    if (label == null) return Icons.table_chart;

    if (label.contains('แสง')) return Icons.wb_sunny;
    if (label.contains('ความชื้น')) return Icons.water_drop;
    if (label.contains('อุณหภูมิ')) return Icons.thermostat;
    if (label.contains('อาหาร')) return Icons.restaurant;

    return Icons.table_chart;
  }

  void calculateDay(String start, String end) {
    final startDate = DateTime.parse(start);
    final endDate = DateTime.parse(end);

    setState(() {
      diffDay = endDate.difference(startDate).inDays;
    });
    print(diffDay);
  }
}
