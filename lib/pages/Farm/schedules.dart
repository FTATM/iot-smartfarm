import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/session.dart';
import 'package:iot_app/pages/greenhourse/HomeOld.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  bool isLoading = true;
  bool isEdit = false;

  double fsSmall = 14;
  double fsLarge = 14;

  double maxwidth = 400;
  double maxheight = 600;

  List<dynamic> tables = [];
  List<dynamic> temps = [];
  List<dynamic> tempParentTables = [];
  List<dynamic> tempChildTables = [];

  @override
  void initState() {
    super.initState();
    prepare();
  }

  Future<void> prepare() async {
    final responsetable = await ApiService.fetchTablesknowledgeById(CurrentUser['branch_id']);
    setState(() {
      tables = jsonDecode(jsonEncode(responsetable['data']));
      temps = jsonDecode(jsonEncode(responsetable['data']));
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

    maxwidth = MediaQuery.of(context).size.width;
    maxheight = MediaQuery.of(context).size.height;

    fsSmall = maxwidth < 400 ? 12.0 : 14.0;

    tempParentTables = temps.where((e) => e['child_of_table_id'] == null).toList();
    tempChildTables = temps.where((e) => e['child_of_table_id'] != null).toList();

    final deepEq = DeepCollectionEquality();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE0E0E0),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "แก้ไขตารางข้อมูล",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isEdit = !isEdit;
              });
            },
            icon: Icon(isEdit ? Icons.close : Icons.edit, color: Colors.black),
          ),
        ],
      ),
      floatingActionButton: Visibility(
        visible: !deepEq.equals(tables, temps),
        child: FloatingActionButton(
          backgroundColor: Colors.orange[700],
          onPressed: () async {
            BuildContext? dialogContext;

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) {
                dialogContext = ctx;
                return const Center(child: CircularProgressIndicator());
              },
            );

            final res = await ApiService.updateScheduleAll(temps);

            if (res['status'] == 'success') {}

            if (dialogContext != null) {
              Navigator.pop(dialogContext!);
            }

            if (context.mounted) {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeOldPage()));
            }
          },
          child: const Icon(Icons.save, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (var item in tempParentTables.where(
            (e) => !tempChildTables.any((c) => c['child_of_table_id'] == e['id']),
          ))
            _buildSingleTable(item),

          const SizedBox(height: 16),

          for (var parent in tempParentTables.where(
            (e) => tempChildTables.any((c) => c['child_of_table_id'] == e['id']),
          ))
            _buildParentChildTable(parent, tempChildTables),
        ],
      ),
    );
  }

  Widget _buildSingleTable(dynamic item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "ชื่อตาราง",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: item['label'],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              onChanged: (v) {
                item['label'] = v;
              },
              onTapOutside: (event) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      "ช่วงวัน",
                      style: TextStyle(fontSize: fsSmall, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      "แสงสว่าง",
                      style: TextStyle(fontSize: fsSmall, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      "ทดสอบ",
                      style: TextStyle(fontSize: fsSmall, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Data Grid
            ...item['rows'].asMap().entries.map((e) {
              final row = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    // Day Range
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildRoundedButton(row['d_start_day'] ?? "0"),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _buildRoundedButton(row['d_end_day'] ?? "0"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Value 1
                    Expanded(
                      flex: 2,
                      child: isEdit
                          ? TextFormField(
                              initialValue: row['d_value'] ?? "",
                              style: TextStyle(fontSize: fsSmall),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              ),
                              onChanged: (v) {
                                row['d_value'] = v;
                              },
                              onTapOutside: (event) => setState(() {}),
                            )
                          : _buildRoundedButton(row['d_value'] ?? ""),
                    ),
                    const SizedBox(width: 8),

                    // Value 2
                    Expanded(
                      flex: 2,
                      child: _buildRoundedButton("123"),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onPressed: () {
                    Map<String, dynamic> newrow = {
                      'd_id': 'new',
                      'd_name_table_id': item['id'],
                      'd_start_day': '0',
                      'd_end_day': '0',
                      'd_value': '',
                      'd_second_label': null,
                    };

                    item['rows'].add(newrow);
                    setState(() {});
                  },
                  icon: const Icon(Icons.add, color: Colors.orange),
                  label: const Text(
                    "เพิ่มแถวใหม่",
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onPressed: () {
                    Map<String, dynamic> newTable = {
                      'id': "Table_${item['id']}_1",
                      'name': "new column",
                      'label': "new Column",
                      'branch_id': item['branch_id'],
                      'child_of_table_id': item['id'],
                      'is_deleted': '0',
                      'rows': [],
                    };

                    for (var i = 0; i < item['rows'].length; i++) {
                      newTable['rows'].add({
                        'd_id': '${item['id']}_$i',
                        'd_name_table_id': newTable['id'],
                        'd_start_day': item['rows'][i]['d_start_day'],
                        'd_end_day': item['rows'][i]['d_end_day'],
                        'd_value': '',
                        'd_second_label': null,
                      });
                    }
                    temps.add(newTable);
                    setState(() {});
                  },
                  icon: const Icon(Icons.view_column, color: Colors.orange),
                  label: const Text(
                    "เพิ่มคอลัมใหม่",
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentChildTable(dynamic parent, List<dynamic> children) {
    final childList = children.where((c) => c['child_of_table_id']?.toString() == parent['id'].toString()).toList();
    final lengthColumn = childList.length + 1;
    final List rows = parent['rows'] ?? [];
    var listColumn = tempChildTables.where((t) => t['child_of_table_id'] == parent['id']);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "ชื่อตาราง",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: parent['label'],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              onChanged: (v) {
                parent['label'] = v;
              },
              onTapOutside: (event) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Header Row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      "ช่วงวัน",
                      style: TextStyle(fontSize: fsSmall, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 2,
                  child: isEdit
                      ? TextFormField(
                          initialValue: parent['label'] ?? "",
                          style: TextStyle(fontSize: fsSmall),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          ),
                          onChanged: (v) {
                            parent['label'] = v;
                            setState(() {});
                          },
                        )
                      : Center(
                          child: Text(
                            parent['label'] ?? "",
                            style: TextStyle(fontSize: fsSmall, fontWeight: FontWeight.w600),
                          ),
                        ),
                ),
                for (var c in childList) ...[
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 2,
                    child: isEdit
                        ? TextFormField(
                            initialValue: c['label'] ?? "",
                            style: TextStyle(fontSize: fsSmall),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                            ),
                            onChanged: (v) {
                              c['label'] = v;
                              setState(() {});
                            },
                          )
                        : Center(
                            child: Text(
                              c['label'] ?? "",
                              style: TextStyle(fontSize: fsSmall, fontWeight: FontWeight.w600),
                            ),
                          ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Data Rows
            ...rows.map<Widget>((row) {
              final start = row['d_start_day'];
              final end = row['d_end_day'];

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    // Day Range
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildRoundedButton(start ?? "0"),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _buildRoundedButton(end ?? "0"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Parent Value
                    Expanded(
                      flex: 2,
                      child: isEdit
                          ? TextFormField(
                              initialValue: row['d_value'] ?? "",
                              style: TextStyle(fontSize: fsSmall),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              ),
                              onChanged: (v) {
                                row['d_value'] = v;
                              },
                              onTapOutside: (event) => setState(() {}),
                            )
                          : _buildRoundedButton(row['d_value'] ?? ""),
                    ),

                    // Child Values
                    for (var c in childList) ...[
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 2,
                        child: Builder(
                          builder: (_) {
                            final rowsChild = c['rows'] ?? [];
                            final match = rowsChild.firstWhere(
                              (r) => r['d_start_day'] == start && r['d_end_day'] == end,
                              orElse: () => null,
                            );

                            if (match == null) return _buildRoundedButton("-");

                            return isEdit
                                ? TextFormField(
                                    initialValue: match['d_value'] ?? "",
                                    style: TextStyle(fontSize: fsSmall),
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    ),
                                    onChanged: (v) {
                                      match['d_value'] = v;
                                    },
                                    onTapOutside: (event) => setState(() {}),
                                  )
                                : _buildRoundedButton(match['d_value'] ?? "");
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onPressed: () {
                    parent['rows'].add({
                      'd_id': 'new',
                      'd_name_table_id': parent['id'],
                      'd_start_day': '0',
                      'd_end_day': '0',
                      'd_value': '',
                      'd_second_label': null,
                    });
                    var list = tempChildTables.where((t) => t['child_of_table_id'] == parent['id']);
                    for (var element in list) {
                      element['rows'].add({
                        'd_id': 'new',
                        'd_name_table_id': element['id'],
                        'd_start_day': '0',
                        'd_end_day': '0',
                        'd_value': '',
                        'd_second_label': null,
                      });
                    }
                    setState(() {});
                  },
                  icon: const Icon(Icons.add, color: Colors.orange),
                  label: const Text(
                    "เพิ่มแถวใหม่",
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                if (lengthColumn < 3)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onPressed: () {
                      Map<String, dynamic> newTable = {
                        'id': "Table_${parent['id']}_1",
                        'name': "${parent['name']}_$lengthColumn",
                        'label': "new Column",
                        'branch_id': parent['branch_id'],
                        'child_of_table_id': parent['id'],
                        'is_deleted': '0',
                        'rows': [],
                      };

                      for (var i = 0; i < parent['rows'].length; i++) {
                        newTable['rows'].add({
                          'd_id': '${parent['id']}_$i',
                          'd_name_table_id': newTable['id'],
                          'd_start_day': parent['rows'][i]['d_start_day'],
                          'd_end_day': parent['rows'][i]['d_end_day'],
                          'd_value': '',
                          'd_second_label': null,
                        });
                      }

                      temps.add(newTable);
                      setState(() {});
                    },
                    icon: const Icon(Icons.view_column, color: Colors.orange),
                    label: const Text(
                      "เพิ่มคอลัมใหม่",
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundedButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: fsSmall),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}