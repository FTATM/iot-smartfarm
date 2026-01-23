import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/session.dart';
import 'package:iot_app/functions/function.dart';
import 'package:iot_app/pages/Farm/settings.dart';

class ScheduleCreatePage extends StatefulWidget {
  const ScheduleCreatePage({super.key});

  @override
  State<ScheduleCreatePage> createState() => _ScheduleCreatePageState();
}

class _ScheduleCreatePageState extends State<ScheduleCreatePage> {
  bool isLoading = true;
  bool isEdit = false;

  double fsSmall = 14;
  double fsLarge = 14;

  double maxwidth = 400;
  double maxheight = 600;

  List<dynamic> parents = [];
  List<dynamic> childs = [];

  List<Map<String, dynamic>> temps = [
    {
      'id': "Table_new",
      'name': "new Table",
      'label': "new Table",
      'branch_id': CurrentUser['branch_id'],
      'child_of_table_id': null,
      'is_deleted': '0',
      'rows': [
        {
          'd_id': helper().tempId(),
          'd_name_table_id': 'Table_new',
          'd_start_day': '0',
          'd_end_day': '0',
          'd_value': '',
          'd_row_parent_id': null,
          'd_second_label': null,
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    prepare();
  }

  Future<void> prepare() async {
    setState(() {
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

    parents = temps.where((e) => e['child_of_table_id'] == null).toList();
    childs = temps.where((e) => e['child_of_table_id'] != null).toList();

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
          "เพิ่มตารางข้อมูล",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsetsGeometry.all(16),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: EdgeInsetsGeometry.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...parents.map((parent) {
                    final childList = temps
                        .where((c) => c['child_of_table_id']?.toString() == parent['id'].toString())
                        .toList();

                    return Column(
                      children: [
                        const Text("ชื่อตาราง", style: TextStyle(fontSize: 14, color: Colors.black87)),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: parent['name'],
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
                          onChanged: (v) => parent['name'] = v,
                          onTapOutside: (_) => setState(() {}),
                        ),

                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Table(
                            border: TableBorder(horizontalInside: BorderSide(color: Colors.grey.shade200, width: 1)),
                            columnWidths: {
                              0: FlexColumnWidth(1),
                              for (int i = 0; i < childList.length + 1; i++) i + 1: const FlexColumnWidth(1),
                              childList.length + 2: FixedColumnWidth(isEdit ? 40 : 0),
                            },
                            children: [
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
                                      textAlign: TextAlign.center,
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
                                    child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Center(child: Text("")),
                                    ),
                                  ),
                                ],
                              ),

                              ...parent['rows'].asMap().entries.map((e) {
                                final index = e.key;
                                final row = e.value;

                                return TableRow(
                                  children: [
                                    //start - end
                                    Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          //start_day
                                          Container(
                                            width: (maxwidth / ((childs.isEmpty ? 1 : childs.length + 1) * 6)),
                                            child: TextFormField(
                                              initialValue: row['d_start_day'] ?? "",
                                              style: TextStyle(fontSize: fsSmall),
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                              ),
                                              textAlign: TextAlign.center,
                                              onChanged: (v) {
                                                row['d_start_day'] = v;
                                                for (final c in childList) {
                                                  c['rows'][index]['d_start_day'] = v;
                                                }
                                              },
                                              onTapOutside: (_) => setState(() {}),
                                            ),
                                          ),

                                          //end_day
                                          Container(
                                            width: (maxwidth / ((childs.isEmpty ? 1 : childs.length + 1) * 6)),
                                            child: TextFormField(
                                              initialValue: row['d_end_day'] ?? "",
                                              style: TextStyle(fontSize: fsSmall),
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                              ),
                                              textAlign: TextAlign.center,
                                              onChanged: (v) {
                                                row['d_end_day'] = v;
                                                for (final c in childList) {
                                                  c['rows'][index]['d_end_day'] = v;
                                                }
                                              },
                                              onTapOutside: (_) => setState(() {}),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    //value
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
                                        textAlign: TextAlign.center,
                                        onChanged: (v) => row['d_value'] = v,
                                        onTapOutside: (_) => setState(() {}),
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
                                                (r) => r['d_row_parent_id'] == row['d_id'],
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
                                        },
                                        icon: Icon(Icons.delete, color: Colors.red),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

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
                                helper().addRowToParentAndChildren(parent, childList);
                                setState(() {});
                              },
                              icon: const Icon(Icons.add, color: Colors.orange),
                              label: Text(
                                "เพิ่มแถวใหม่",
                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                              ),
                            ),

                            Visibility(
                              visible: childList.length < 2,
                              child:
                                  /// Add Column
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.orange, width: 2),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    ),
                                    onPressed: () {
                                      helper().addColumn(parent, temps);
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
                    );
                  }),

                  const SizedBox(height: 32),

                  // Save Button
                  Container(
                    width: maxwidth,
                    margin: EdgeInsets.symmetric(horizontal: 24),
                    height: 56,
                    decoration: BoxDecoration(
                      color: Color(0xFFFF8800),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Color(0xFFFF8800).withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4)),
                      ],
                    ),
                    child: TextButton(
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
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("เพิ่มตารางสำเร็จ.")));
                        }

                        if (context.mounted) {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_outlined, color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Text(
                            "บันทึก",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
