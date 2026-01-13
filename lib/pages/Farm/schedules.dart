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
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    maxwidth = MediaQuery.of(context).size.width;
    maxheight = MediaQuery.of(context).size.height;

    fsSmall = maxwidth < 400 ? 12.0 : 14.0;

    // แยก parent / child
    tempParentTables = temps.where((e) => e['child_of_table_id'] == null).toList();
    tempChildTables = temps.where((e) => e['child_of_table_id'] != null).toList();

    final deepEq = DeepCollectionEquality();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("แก้ไขตารางข้อมูล"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isEdit = !isEdit;
              });
            },
            icon: Icon(isEdit ? Icons.close : Icons.edit),
          ),
        ],
      ),
      floatingActionButton: Visibility(
        visible: !deepEq.equals(tables, temps),
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () async {
            // debugPrint("Save");

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

            // ปิด dialog
            if (dialogContext != null) {
              Navigator.pop(dialogContext!);
            }

            // กลับหน้าก่อนหน้า
            if (context.mounted) {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeOldPage()));
            }
          },
          child: Icon(Icons.save),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ───────── Single Tables ─────────
          for (var item in tempParentTables.where(
            (e) => !tempChildTables.any((c) => c['child_of_table_id'] == e['id']),
          ))
            _buildSingleTable(item),

          const SizedBox(height: 24),

          // ───────── Parent + Child Tables ─────────
          for (var parent in tempParentTables.where(
            (e) => tempChildTables.any((c) => c['child_of_table_id'] == e['id']),
          ))
            _buildParentChildTable(parent, tempChildTables),
        ],
      ),
    );
  }

  // ───────────────── Single Table ─────────────────
  Widget _buildSingleTable(dynamic item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("ชื่อตาราง : "),
        Container(
          child: TextFormField(
            initialValue: item['label'],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            ),
            onChanged: (v) {
              item['label'] = v;
            },
            onTapOutside: (event) => setState(() {}),
          ),
        ),

        const SizedBox(height: 8),

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
              // ...item['rows'].map<TableRow>((row) {
              ...item['rows'].asMap().entries.map((e) {
                final row = e.value;
                // final key = e.key;
                // final start = row['d_start_day'];
                // final endView = row['d_end_day'] == '99' ? "เป็นต้นไป" : row['d_end_day'];
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Text("$start - $endView"),
                          Container(
                            width: 50,
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
                              },
                              onTapOutside: (event) => setState(() {}),
                            ),
                          ),
                          Text('-'),
                          Container(
                            width: 50,
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
                          // onEditingComplete: () {
                          //   final oldValue = temps[key]['d_value'];
                          //   final newValue = row['d_value'];
                          // },
                          onTapOutside: (event) => setState(() {}),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            TextButton(
              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.orange[700])),
              onPressed: () {
                debugPrint(item['rows'].length.toString());
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
              child: Text("เพิ่มแถวใหม่", style: TextStyle(color: Colors.white)),
            ),

            TextButton(
              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blue[700])),
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
              child: Text("เพิ่มคอลัมใหม่", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildParentChildTable(dynamic parent, List<dynamic> children) {
    final childList = children.where((c) => c['child_of_table_id']?.toString() == parent['id'].toString()).toList();
    final lengthColumn = childList.length + 1;

    final List rows = parent['rows'] ?? [];
    var listColumn = tempChildTables.where((t) => t['child_of_table_id'] == parent['id']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("ชื่อตาราง : "),

        Container(
          child: TextFormField(
            initialValue: parent['label'],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            ),
            onChanged: (v) {
              parent['label'] = v;
            },
            onTapOutside: (event) => setState(() {}),
          ),

          // Text(parent['label'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),

        const SizedBox(height: 8),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Table(
            border: TableBorder.all(color: Colors.grey.shade300),
            columnWidths: {
              0: const FlexColumnWidth(0.8),
              for (int i = 0; i < childList.length + 1; i++) i + 1: const FlexColumnWidth(1),
              childList.length + 2: FixedColumnWidth(isEdit ? 40 : 0),
            },
            children: [
              // ───── Header ─────
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade100),
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text("Day", style: TextStyle(fontSize: fsSmall)),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(10),
                    // child: Center(child: Text(parent['label'] ?? "")),
                    child: TextFormField(
                      initialValue: parent['label'] ?? "",
                      style: TextStyle(fontSize: fsSmall),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                      ),
                      onChanged: (v) {
                        parent['label'] = v;
                        setState(() {});
                      },
                    ),
                  ),

                  for (var c in childList)
                    Padding(
                      padding: const EdgeInsets.all(10),
                      // child: Center(child: Text(c['label'] ?? "")),
                      child: TextFormField(
                        initialValue: c['label'] ?? "",
                        style: TextStyle(fontSize: fsSmall),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                        ),
                        onChanged: (v) {
                          c['label'] = v;
                          setState(() {});
                        },
                      ),
                    ),

                  Visibility(
                    visible: isEdit,
                    child: IconButton(
                      onPressed: () {
                        //Delete Table
                      },
                      icon: Container(child: Icon(Icons.delete, color: Colors.red)),
                    ),
                  ),
                ],
              ),

              // ───── Data Rows ─────
              ...rows.map<TableRow>((row) {
                final start = row['d_start_day'];
                final end = row['d_end_day'];
                // final endView = row['d_end_day'] == '99' ? "เป็นต้นไป" : row['d_end_day'];

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
                          // var res = await ApiService.deleteRowById(row);
                          // if (res['status'] == 'success') {
                          //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ลบแถวสำเร็จ.")));
                          // } else {
                          //   ScaffoldMessenger.of(
                          //     context,
                          //   ).showSnackBar(SnackBar(content: Text("ลบแถวไม่สำเร็จ กรุณาลองอีกครั้ง.")));
                          // }
                          debugPrint(row.toString());
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
                          await prepare();
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
                          await prepare();
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

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            TextButton(
              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.orange[700])),
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
              child: Text("เพิ่มแถวใหม่", style: TextStyle(color: Colors.white)),
            ),

            Visibility(
              visible: lengthColumn < 3,
              child: TextButton(
                style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blue[700])),
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
                child: Text("เพิ่มคอลัมใหม่", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
