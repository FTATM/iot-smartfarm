import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/appbar.dart';
import 'package:iot_app/components/session.dart';
import 'package:iot_app/pages/greenhourse/dashboard.dart';

class DashboardCreatePage extends StatefulWidget {
  const DashboardCreatePage({super.key});

  @override
  State<DashboardCreatePage> createState() => _DashboardCreatePageState();
}

class _DashboardCreatePageState extends State<DashboardCreatePage> {
  bool isLoading = true;

  Map<String, dynamic> data = {'branch_id': CurrentUser['branch_id']};
  List<dynamic> listvalues = [0, 0];
  List<dynamic> monitors = [];
  List<dynamic> icons = [];
  List<dynamic> groups = [];
  List<dynamic> devices = [];
  List<dynamic> dataxs = [];
  List<dynamic> types = [];
  List<dynamic> typeDashboards = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchicons();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _fetchData() async {
    final mres = await ApiService.fetchConfigBybranchId(CurrentUser['branch_id']);
    final gres = await ApiService.fetchGroupsBybranchId(CurrentUser['branch_id']);
    final dres = await ApiService.fetchDevicesBybranchId(CurrentUser['branch_id']);
    final tres = await ApiService.fetchTypesBybranchId();
    final xres = await ApiService.fetchDataxBybranchId(CurrentUser['branch_id']);
    final tdres = await ApiService.fetchDashboardType();

    if (!mounted) return;

    setState(() {
      monitors = mres['data'] as List;
      groups = gres['data'] as List;
      devices = dres['data'] as List;
      types = tres['data'] as List;
      dataxs = xres['data'] as List;
      typeDashboards = tdres['data'] as List;

      isLoading = false;
    });
  }

  Future<void> _fetchicons() async {
    final response = await ApiService.fetchIcons();
    setState(() {
      icons = response['data'] as List;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(backgroundColor: Colors.white,body: Center(child: CircularProgressIndicator()));
    }
    final maxwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 250, 250, 250),
      appBar: AppbarWidget(txtt: 'Create Dashboard'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(12),
          child: Center(
            child: Column(
              spacing: 4,
              children: [
                Container(
                  width: maxwidth,
                  child: Row(
                    children: [
                      Container(width: maxwidth * 0.15, child: Text("Name : ")),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "ใส่ชื่อ Dashboard",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onChanged: (value) {
                            setState(() {
                              data['name'] = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: maxwidth,
                  child: Row(
                    children: [
                      Container(width: maxwidth * 0.15, child: Text("Type : ")),
                      Expanded(
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          initialValue: data['type_dashboard_id'],
                          isExpanded: true,
                          hint: Text("เลือกประเภท Dashboard"),
                          items: typeDashboards.map<DropdownMenuItem<String>>((type) {
                            return DropdownMenuItem(value: type['id'], child: Text(type['type_name']));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              data['type_dashboard_id'] = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: maxwidth,
                  child: Row(
                    children: [
                      SizedBox(width: maxwidth * 0.15, child: Text("size :")),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Checkbox(
                                  value: data['size'] == "1",
                                  onChanged: (v) {
                                    setState(() {
                                      data['size'] = '1';
                                    });
                                  },
                                ),
                                Text("Large"),
                              ],
                            ),
                            Column(
                              children: [
                                Checkbox(
                                  value: data['size'] == "2",
                                  onChanged: (v) {
                                    setState(() {
                                      data['size'] = '2';
                                    });
                                  },
                                ),
                                Text("Medium"),
                              ],
                            ),
                            Column(
                              children: [
                                Checkbox(
                                  value: data['size'] == "3",
                                  onChanged: (v) {
                                    setState(() {
                                      data['size'] = '3';
                                    });
                                  },
                                ),
                                Text("Small"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: maxwidth,
                  child: Row(
                    children: [
                      SizedBox(width: maxwidth * 0.15, child: Text("Icon :")),
                      Expanded(
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          initialValue: data['icon_id'],
                          isExpanded: true,
                          hint: Text("เลือกไอคอน"),
                          items: icons.map<DropdownMenuItem<String>>((icons) {
                            return DropdownMenuItem<String>(
                              value: icons['id']?.toString(),
                              child: Text(icons['name'] ?? ''),
                            );
                          }).toList(),
                          onChanged: (valuex) {
                            setState(() {
                              data['icon_id'] = valuex;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: maxwidth * 0.15,
                        child: data['icon_id'] != null
                            ? Image.network(
                                // ignore: prefer_interpolation_to_compose_strings
                                "${CurrentUser['baseURL']}../" +
                                    icons.firstWhere(
                                      (i) => i['id'] == data['icon_id'],
                                      orElse: () => {"path": "img/icons/default.png"},
                                    )['path'],
                              )
                            : Text("  "),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: maxwidth,
                  child: Row(
                    children: [
                      SizedBox(width: maxwidth * 0.15, child: Text("data :")),
                      Expanded(
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          isExpanded: true,
                          hint: Text("เลือกข้อมูล"),
                          items: monitors.map<DropdownMenuItem<String>>((monitor) {
                            return DropdownMenuItem<String>(
                              value: monitor['monitor_id'],
                              child: Text('[${monitor['monitor_id']}] ${monitor['monitor_name'] ?? ""}'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              listvalues[0] = value;
                              data['data'] = listvalues;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: maxwidth,
                  child: Visibility(
                    visible: ['2', '5', '6', '12'].contains(data['type_dashboard_id']),
                    child: Row(
                      children: [
                        SizedBox(width: maxwidth * 0.15, child: Text("Monitor :")),
                        Expanded(
                          child: DropdownButtonFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                            isExpanded: true,
                            hint: Text("เลือกข้อมูล"),
                            items: monitors.map<DropdownMenuItem<String>>((monitor) {
                              return DropdownMenuItem<String>(
                                value: monitor['monitor_id'],
                                child: Text('[${monitor['monitor_id']}] ${monitor['monitor_name'] ?? ""}'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                listvalues[1] = value;
                                data['data'] = listvalues;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: maxwidth,
                  child: Visibility(
                    visible:
                        !listEquals(listvalues, [0, 0]) &&
                        data['icon_id'] != null &&
                        data['type_dashboard_id'] != null &&
                        data['name'] != null,

                    child: SizedBox(
                      child: TextButton(
                        style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.green)),
                        onPressed: () async {
                          var response = await ApiService.createDashboard(data);
                          if (response['status'] == 'success') {
                            data['dashboard_id'] = response['id'];
                            var res = await ApiService.createSubDashboard(data);
                            if (res['status'] == 'success') {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardPage()));
                            }
                          }
                        },
                        child: Text("Save", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
