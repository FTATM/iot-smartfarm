import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/session.dart';

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
              //   Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeOldPage()));
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
            const Text("ชื่อตาราง", style: TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 8),

            /// ===== Table Label =====
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
              onChanged: (v) => item['label'] = v,
              onTapOutside: (_) => setState(() {}),
            ),

            const SizedBox(height: 16),

            /// ===== Table =====
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                columnWidths: {0: FlexColumnWidth(1), 1: FlexColumnWidth(1), 2: FixedColumnWidth(isEdit ? 40 : 0)},
                children: [
                  /// Header
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade100),
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Center(child: Text("ช่วงเวลา")),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: TextFormField(
                          initialValue: item['label'] ?? "",
                          style: TextStyle(fontSize: fsSmall),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          onChanged: (v) => item['label'] = v,
                          onTapOutside: (_) => setState(() {}),
                        ),
                      ),
                      Visibility(
                        visible: isEdit,
                        child: IconButton(
                          onPressed: () async {
                            // debugPrint(item.toString());
                            var res = await ApiService.deleteColumnById(item);
                            if (res['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ลบตารางสำเร็จ.")));
                            } else {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text("ลบตารางไม่สำเร็จ กรุณาลองอีกครั้ง.")));
                            }
                            await prepare();
                          },
                          icon: Icon(Icons.delete, color: Colors.red),
                        ),
                      ),
                    ],
                  ),

                  /// Rows
                  ...item['rows'].asMap().entries.map((e) {
                    final row = e.value;

                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                width: maxwidth / 8,
                                child: TextFormField(
                                  initialValue: row['d_start_day'] ?? "",
                                  style: TextStyle(fontSize: fsSmall),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  ),
                                  onChanged: (v) => row['d_start_day'] = v,
                                  onTapOutside: (_) => setState(() {}),
                                ),
                              ),
                              Container(
                                width: maxwidth / 8,
                                child: TextFormField(
                                  initialValue: row['d_end_day'] ?? "",
                                  style: TextStyle(fontSize: fsSmall),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  ),
                                  onChanged: (v) => row['d_end_day'] = v,
                                  onTapOutside: (_) => setState(() {}),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: TextFormField(
                            initialValue: row['d_value'] ?? "",
                            style: TextStyle(fontSize: fsSmall),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                            onChanged: (v) => row['d_value'] = v,
                            onTapOutside: (_) => setState(() {}),
                          ),
                        ),

                        Visibility(
                          visible: isEdit,
                          child: Container(child: Text("")),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// ===== Action Buttons =====
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: maxwidth / 30,
              children: [
                /// Add Row
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onPressed: () {
                    item['rows'].add({
                      'd_id': 'new',
                      'd_name_table_id': item['id'],
                      'd_start_day': '0',
                      'd_end_day': '0',
                      'd_value': '',
                      'd_second_label': null,
                    });
                    setState(() {});
                  },
                  icon: const Icon(Icons.add, color: Colors.orange),
                  label: const Text(
                    "เพิ่มแถวใหม่",
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                  ),
                ),

                /// Add Column
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
    final listColumn = tempChildTables.where((t) => t['child_of_table_id'] == parent['id']).toList();

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
            const Text("ชื่อตาราง", style: TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 8),

            /// ===== Table Label =====
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
              onChanged: (v) => parent['label'] = v,
              onTapOutside: (_) => setState(() {}),
            ),

            const SizedBox(height: 16),

            /// ===== Table =====
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                columnWidths: {
                  0: FlexColumnWidth(1),
                  for (int i = 0; i < childList.length + 1; i++) i + 1: const FlexColumnWidth(1),
                  childList.length + 2: FixedColumnWidth(isEdit ? 40 : 0),
                },
                children: [
                  /// Header
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade100),
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Center(child: Text("ช่วงเวลา")),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: TextFormField(
                          initialValue: parent['label'] ?? "",
                          style: TextStyle(fontSize: fsSmall),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          onChanged: (v) => parent['label'] = v,
                          onTapOutside: (_) => setState(() {}),
                        ),
                      ),

                      for (final c in childList)
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: TextFormField(
                            initialValue: c['label'] ?? "",
                            style: TextStyle(fontSize: fsSmall),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                            onChanged: (v) => c['label'] = v,
                            onTapOutside: (_) => setState(() {}),
                          ),
                        ),

                      Visibility(
                        visible: isEdit,
                        child: IconButton(
                          onPressed: () async {
                            var res = await ApiService.deleteTableById(parent);
                            if (res['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ลบตารางสำเร็จ.")));
                            } else {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text("ลบตารางไม่สำเร็จ กรุณาลองอีกครั้ง.")));
                            }
                            // debugPrint(parent.toString());
                            await prepare();
                          },
                          icon: Icon(Icons.delete, color: Colors.red),
                        ),
                      ),
                    ],
                  ),

                  // ───── Data Rows ─────
                  ...rows.asMap().entries.map<TableRow>((e) {
                    final index = e.key;
                    final row = e.value;
                    final start = row['d_start_day'];
                    final end = row['d_end_day'];
                    final endView = row['d_end_day'] == '99' ? "เป็นต้นไป" : row['d_end_day'];

                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                width: maxwidth * 0.07 > 30 ? 30 : maxwidth * 0.07,
                                child: TextFormField(
                                  initialValue: row['d_start_day'] ?? "",
                                  style: TextStyle(fontSize: fsSmall),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                                  ),
                                  onChanged: (v) {
                                    row['d_start_day'] = v;
                                    for (final c in childList) {
                                      c['rows'][index]['d_start_day'] = v;
                                    }
                                  },
                                  onTapOutside: (event) => setState(() {}),
                                ),
                              ),

                              Container(
                                width: maxwidth * 0.07 > 30 ? 30 : maxwidth * 0.07,
                                child: TextFormField(
                                  initialValue: row['d_end_day'] ?? "",
                                  style: TextStyle(fontSize: fsSmall),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                                  ),
                                  onChanged: (v) {
                                    row['d_end_day'] = v;
                                    for (final c in childList) {
                                      c['rows'][index]['d_end_day'] = v;
                                    }
                                  },
                                  onTapOutside: (event) => setState(() {}),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Center(
                            child: TextFormField(
                              initialValue: row['d_value'] ?? "",
                              style: TextStyle(fontSize: fsSmall),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              ),
                              onChanged: (v) {
                                row['d_value'] = v;
                              },
                              onTapOutside: (event) => setState(() {}),
                            ),
                          ),
                        ),

                        // ค่า child
                        for (var c in childList)
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Center(
                              child: Builder(
                                builder: (_) {
                                  final rowsChild = c['rows'] ?? [];
                                  final match = rowsChild.firstWhere(
                                    (r) => r['d_start_day'] == start && r['d_end_day'] == end,
                                    orElse: () => null,
                                  );

                                  if (match == null) return const Text("-");

                                  return TextFormField(
                                    initialValue: match['d_value'] ?? "",
                                    style: TextStyle(fontSize: fsSmall),
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    ),
                                    onChanged: (v) {
                                      match['d_value'] = v;
                                    },
                                    onTapOutside: (event) => setState(() {}),
                                  );
                                },
                              ),
                            ),
                          ),

                        Visibility(
                          visible: isEdit,
                          child: IconButton(
                            onPressed: () async {
                              var res = await ApiService.deleteRowById(row);
                              if (res['status'] == 'success') {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ลบแถวสำเร็จ.")));
                              } else {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text("ลบแถวไม่สำเร็จ กรุณาลองอีกครั้ง.")));
                              }
                            },
                            icon: Icon(Icons.delete, color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  }).toList(),

                  TableRow(
                    children: [
                      Visibility(
                        visible: isEdit,
                        child: Container(child: Text("")),
                      ),
                      Visibility(
                        visible: isEdit,
                        child: IconButton(
                          onPressed: () async {
                            var res = await ApiService.deleteColumnById(parent);
                            if (res['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ลบคอลัมสำเร็จ.")));
                            } else {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text("ลบคอลัมไม่สำเร็จ กรุณาลองอีกครั้ง.")));
                            }
                          },
                          icon: Icon(Icons.delete, color: Colors.red),
                        ),
                      ),
                      for (var l in listColumn)
                        Visibility(
                          visible: isEdit,
                          child: IconButton(
                            onPressed: () async {
                              var res = await ApiService.deleteColumnById(l);
                              if (res['status'] == 'success') {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ลบคอลัมสำเร็จ.")));
                              } else {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text("ลบคอลัมไม่สำเร็จ กรุณาลองอีกครั้ง.")));
                              }
                            },
                            icon: Icon(Icons.delete, color: Colors.red),
                          ),
                        ),
                      Visibility(
                        visible: isEdit,
                        child: Container(child: Text("")),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// ===== Action Buttons =====
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: maxwidth / 30,
              children: [
                /// Add Row
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
                    setState(() {});
                  },
                  icon: const Icon(Icons.add, color: Colors.orange),
                  label: Text(
                    "เพิ่มแถวใหม่",
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                  ),
                ),

                Visibility(
                  visible: lengthColumn < 3,
                  child:
                      /// Add Column
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.orange, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onPressed: () {
                          Map<String, dynamic> newTable = {
                            'id': "Table_${parent['id']}_1",
                            'name': "new column",
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
