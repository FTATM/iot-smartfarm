import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/appbar.dart';
import 'package:iot_app/components/session.dart';
// import 'package:iot_app/components/sidebar.dart';

class ConfigCreatePage extends StatefulWidget {
  const ConfigCreatePage({super.key});

  @override
  State<ConfigCreatePage> createState() => _ConfigCreatePageState();
}

class _ConfigCreatePageState extends State<ConfigCreatePage> {
  bool isLoading = true;
  String txtPath = "";
  Timer? _timer;

  List<int> listTime = [];

  List<String> daysList = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  Map<String, dynamic> item = {};

  TextEditingController nameController = TextEditingController();
  TextEditingController minValueController = TextEditingController();
  TextEditingController maxValueController = TextEditingController();
  TextEditingController lineValueController = TextEditingController();
  TextEditingController emailValueController = TextEditingController();

  List<dynamic> data = [];
  List<dynamic> groups = [];
  List<dynamic> devices = [];
  List<dynamic> types = [];
  List<dynamic> dataxs = [];

  List<String?> selectedGroups = [];
  List<String?> selectedDevices = [];
  List<String?> selectedTypes = [];
  List<String?> selectedDataxs = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // _fetchData(); // ดึงซ้ำทุก 5 วิ
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // ยกเลิก timer เมื่อออกจากหน้า
    // for (var c in minControllers) {
    //   c.dispose();
    // }
    // for (var c in maxControllers) {
    //   c.dispose();
    // }
    super.dispose();
  }

  void _fetchData() async {
    // final response = await ApiService.fetchConfigBybranchId(
    // CurrentUser['branch_id'],
    // );
    final gres = await ApiService.fetchGroupsBybranchId(CurrentUser['branch_id']);
    final dres = await ApiService.fetchDevicesBybranchId(CurrentUser['branch_id']);
    final tres = await ApiService.fetchTypesBybranchId();
    final xres = await ApiService.fetchDataxBybranchId(CurrentUser['branch_id']);

    if (!mounted) return;

    // ✅ อัปเดต state เพื่อให้ UI render ใหม่
    setState(() {
      // data = response['data'] as List;
      groups = gres['data'] as List;
      devices = dres['data'] as List;
      types = tres['data'] as List;
      dataxs = xres['data'] as List;

      item['branch_id'] = CurrentUser['branch_id'];

      // ✅ สร้าง controller สำหรับแต่ละ item
      // minControllers = data
      //     .map(
      //       (item) => TextEditingController(
      //         text: item['min_value']?.toString() ?? '',
      //       ),
      //     )
      //     .toList();

      // maxControllers = data
      //     .map(
      //       (item) => TextEditingController(
      //         text: item['max_value']?.toString() ?? '',
      //       ),
      //     )
      //     .toList();

      // linesControllers = data
      //     .map(
      //       (item) => TextEditingController(
      //         text: item['input_line']?.toString() ?? '',
      //       ),
      //     )
      //     .toList();

      // emailsControllers = data
      //     .map(
      //       (item) => TextEditingController(
      //         text: item['input_email']?.toString() ?? '',
      //       ),
      //     )
      //     .toList();

      // selectedGroups = List.generate(
      //   data.length,
      //   (index) => data[index]['group_id']?.toString(),
      // );
      // selectedDevices = List.generate(
      //   data.length,
      //   (index) => data[index]['device_id']?.toString(),
      // );
      // selectedTypes = List.generate(
      //   data.length,
      //   (index) => data[index]['type_id']?.toString() ?? '',
      // );
      // selectedDataxs = List.generate(
      //   data.length,
      //   (index) => data[index]['datax_id']?.toString(),
      // );

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(backgroundColor: Colors.white,body: Center(child: CircularProgressIndicator()));
    }
    final maxwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppbarWidget(txtt: 'Create Configuration'),
      // drawer: const SideBarWidget(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(12),
          child: Center(
            child: SizedBox(
              width: 480,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      image: const DecorationImage(image: AssetImage('assets/images/default.jpg'), fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(
                    width: 480,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: 20,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(width: maxwidth * 0.1, child: Text('Name :')),
                            Expanded(
                              child: TextField(
                                controller: nameController,
                                onChanged: (value) {
                                  setState(() {
                                    item['monitor_name'] = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Divider(thickness: 2), // เส้นคั่นใต้หัวข้อ
                        // Configuration
                        Text('Configuration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Row(
                          spacing: 20,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(width: maxwidth * 0.1, child: Text('Group :')),
                            DropdownButton<String>(
                              value: item['group_id'],
                              items: groups.map<DropdownMenuItem<String>>((group) {
                                return DropdownMenuItem<String>(
                                  value: group['group_id']?.toString(),
                                  child: Text(group['group_name'] ?? ''),
                                );
                              }).toList(),
                              onChanged: (valueg) {
                                setState(() {
                                  item['group_id'] = valueg;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          spacing: 20,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(width: maxwidth * 0.1, child: Text('Device :')),
                            DropdownButton<String>(
                              value: item['device_id'],
                              items: devices.map<DropdownMenuItem<String>>((device) {
                                return DropdownMenuItem<String>(
                                  value: device['device_id']?.toString(),
                                  child: Text(device['divice_name'] ?? ''),
                                );
                              }).toList(),
                              onChanged: (valued) {
                                setState(() {
                                  item['device_id'] = valued;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          spacing: 20,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(width: maxwidth * 0.1, child: Text('Type :')),
                            DropdownButton<String>(
                              value: item['type_id'],
                              items: types.map<DropdownMenuItem<String>>((type) {
                                return DropdownMenuItem<String>(
                                  value: type['type_id'],
                                  child: Text('[${type['type_id']}] ${type['type_name']}'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  item['type_id'] = value;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          spacing: 20,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(width: maxwidth * 0.1, child: Text('Data :')),
                            DropdownButton<String>(
                              value: item['datax_id'],
                              items: dataxs.map<DropdownMenuItem<String>>((datax) {
                                return DropdownMenuItem<String>(
                                  value: datax['datax_id']?.toString(),
                                  child: Text(datax['datax_name'] ?? ''),
                                );
                              }).toList(),
                              onChanged: (valuex) {
                                setState(() {
                                  item['datax_id'] = valuex;
                                });
                              },
                            ),
                          ],
                        ),
                        Divider(thickness: 2), // เส้นคั่นใต้หัวข้อ
                        // Notify
                        Text('Notify and Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Column(
                          children: [
                            Row(
                              children: [
                                Switch(
                                  padding: EdgeInsets.only(right: 18),
                                  value: item['is_min'] == '1',
                                  onChanged: (value) {
                                    setState(() {
                                      item['is_min'] = value ? '1' : '0';
                                    });
                                  },
                                  activeThumbColor: Colors.green,
                                  inactiveThumbColor: Colors.grey,
                                ),
                                SizedBox(width: 50, child: Text("min :")),
                                Expanded(
                                  child: TextField(
                                    controller: minValueController,
                                    onChanged: (value) {
                                      setState(() {
                                        item['min_value'] = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Switch(
                                  padding: EdgeInsets.only(right: 18),
                                  value: item['is_max'] == '1',
                                  onChanged: (value) {
                                    setState(() {
                                      item['is_max'] = value ? '1' : '0';
                                    });
                                  },
                                  activeThumbColor: Colors.green,
                                  inactiveThumbColor: Colors.grey,
                                ),
                                SizedBox(width: 50, child: Text("max :")),
                                Expanded(
                                  child: TextField(
                                    controller: maxValueController,
                                    onChanged: (value) {
                                      setState(() {
                                        item['max_value'] = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(width: 50, child: Text("Line :")),
                                Expanded(
                                  child: TextField(
                                    controller: lineValueController,
                                    onChanged: (value) {
                                      setState(() {
                                        item['input_line'] = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(width: 50, child: Text("Email :")),
                                Expanded(
                                  child: TextField(
                                    controller: emailValueController,
                                    onChanged: (value) {
                                      setState(() {
                                        item['input_email'] = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 380,
                              child: ListView(
                                children: daysList.asMap().entries.map((entry) {
                                  final index = entry.key; // 0,1,2,3,...
                                  final day = entry.value; // 'Mon', 'Tue', ...

                                  return CheckboxListTile(
                                    title: Text(day),
                                    value: listTime.contains(index),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          listTime.add(index);
                                        } else {
                                          listTime.remove(index);
                                        }
                                        item['list_time_of_work'] = listTime.join(',');
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),

                        Divider(thickness: 2), // เส้นคั่นใต้หัวข้อ
                        SizedBox(
                          height: 50,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(context).pop(); // ปิด popup
                                },
                                child: const Text('ยกเลิก', style: TextStyle(color: Colors.white)),
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(Colors.red),
                                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 50, vertical: 16)),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  var res = await ApiService.createMonitorById(item);
                                  if (res['status'] == 'success') {
                                    Navigator.of(context).pop(); // ปิด popup
                                  }
                                },
                                child: Text('บันทึก', style: TextStyle(color: Colors.white)),
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(Colors.green),
                                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 50, vertical: 16)),
                                ),
                                // style: TextButton.styleFrom(
                                //   backgroundColor: Colors.green,
                                //   padding: EdgeInsets.symmetric(),
                                // ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
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
