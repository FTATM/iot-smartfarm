import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/session.dart';

class KnowledgePage extends StatefulWidget {
  const KnowledgePage({super.key});

  @override
  State<KnowledgePage> createState() => _KnowledgePageState();
}

class _KnowledgePageState extends State<KnowledgePage> {
  bool isLoading = true;
  List<dynamic> tables = [];

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
    setState(() {
      tables = responsetable['data'];
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

    // แยก parent / child
    final parentTables = tables.where((e) => e['child_of_table_id'] == null).toList();
    final childTables = tables.where((e) => e['child_of_table_id'] != null).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, title: const Text("Farm Standards")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ───────── Single Tables ─────────
          for (var item in parentTables.where((e) => !childTables.any((c) => c['child_of_table_id'] == e['id'])))
            _buildSingleTable(item),

          const SizedBox(height: 24),

          // ───────── Parent + Child Tables ─────────
          for (var parent in parentTables.where((e) => childTables.any((c) => c['child_of_table_id'] == e['id'])))
            _buildParentChildTable(parent, childTables),
        ],
      ),
    );
  }

  // ───────────────── Single Table ─────────────────
  Widget _buildSingleTable(dynamic item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(top: 10),
          color: primaryColor,
          child: Text("${item['label']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Table(
            border: TableBorder.all(color: Colors.grey.shade300),
            columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)},
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade100),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(child: Text("Day")),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(child: Text("Value")),
                  ),
                ],
              ),
              ...item['rows'].map<TableRow>((row) {
                final start = row['d_start_day'];
                final endView = row['d_end_day'] == '99' ? "เป็นต้นไป" : row['d_end_day'];
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Center(child: Text("$start - $endView")),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Center(child: Text(row['d_value'] ?? "")),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildParentChildTable(dynamic parent, List<dynamic> children) {
    final childList = children.where((c) => c['child_of_table_id']?.toString() == parent['id'].toString()).toList();

    final List rows = parent['rows'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 500,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Text(parent['label'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Table(
            border: TableBorder.all(color: Colors.grey.shade300),

            columnWidths: {
              0: const FlexColumnWidth(0.75),
              for (int i = 0; i < childList.length + 1; i++) i + 1: const FlexColumnWidth(1),
            },
            children: [
              // ───── Header ─────
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade100),
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(child: Text("Day")),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Center(child: Text(parent['label'] ?? "")),
                  ),
                  for (var c in childList)
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Center(child: Text(c['label'] ?? "")),
                    ),
                ],
              ),

              // ───── Data Rows ─────
              ...rows.map<TableRow>((row) {
                final start = row['d_start_day'];
                final end = row['d_end_day'];
                final endView = row['d_end_day'] == '99' ? "เป็นต้นไป" : row['d_end_day'];

                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Center(child: Text("$start - $endView")),
                    ),

                    // ค่า parent
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Center(child: Text(row['d_value'] ?? "")),
                    ),

                    // ค่า child
                    for (var c in childList)
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Center(child: Text(_matchChildValue(c['rows'] ?? [], start, end))),
                      ),
                  ],
                );
              }).toList(),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  // ───────────────── Map child row by day range ─────────────────
  String _matchChildValue(List rows, String s, String e) {
    final match = rows.firstWhere((r) => r['d_start_day'] == s && r['d_end_day'] == e, orElse: () => null);
    return match != null ? (match['d_value'] ?? "") : "-";
  }
}
