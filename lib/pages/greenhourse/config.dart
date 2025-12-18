import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/appbar.dart';
import 'package:iot_app/components/session.dart';
import 'package:iot_app/pages/greenhourse/config-Create.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  bool isLoading = true;
  String txtPath = "";
  Timer? _timer;

  List<String> daysList = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  List<TextEditingController> minControllers = [];
  List<TextEditingController> maxControllers = [];
  List<TextEditingController> linesControllers = [];
  List<TextEditingController> emailsControllers = [];

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
    for (var c in minControllers) {
      c.dispose();
    }
    for (var c in maxControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _fetchData() async {
    final response = await ApiService.fetchConfigBybranchId(CurrentUser['branch_id']);
    final gres = await ApiService.fetchGroupsBybranchId(CurrentUser['branch_id']);
    final dres = await ApiService.fetchDevicesBybranchId(CurrentUser['branch_id']);
    final tres = await ApiService.fetchTypesBybranchId();
    final xres = await ApiService.fetchDataxBybranchId(CurrentUser['branch_id']);

    if (!mounted) return;

    // ✅ อัปเดต state เพื่อให้ UI render ใหม่
    setState(() {
      data = response['data'] as List;
      groups = gres['data'] as List;
      devices = dres['data'] as List;
      types = tres['data'] as List;
      dataxs = xres['data'] as List;

      // ✅ สร้าง controller สำหรับแต่ละ item
      minControllers = data.map((item) => TextEditingController(text: item['min_value']?.toString() ?? '')).toList();

      maxControllers = data.map((item) => TextEditingController(text: item['max_value']?.toString() ?? '')).toList();

      linesControllers = data.map((item) => TextEditingController(text: item['input_line']?.toString() ?? '')).toList();

      emailsControllers = data
          .map((item) => TextEditingController(text: item['input_email']?.toString() ?? ''))
          .toList();

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
      appBar: AppbarWidget(txtt: 'Configuration'),
      // drawer: const SideBarWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ConfigCreatePage()));
        },
        backgroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: data.asMap().entries.map((entry) {
                int index = entry.key;
                var item = entry.value;

                List<int> listTime = [];

                var raw = item['list_time_of_work'];

                if (raw != null && raw is String && raw.isNotEmpty) {
                  listTime = raw.split(',').map((e) => int.parse(e)).toList();
                }

                txtPath = "";
                txtPath +=
                    groups.where((g) => g['group_id'] == item['group_id']).map((g) => g['group_name']).first + "/";
                txtPath +=
                    devices.where((g) => g['device_id'] == item['device_id']).map((g) => g['divice_name']).first + "/";

                String name = item["monitor_name"] ?? "-";
                String nameshort = item["monitor_name"] ?? "-";
                if (name.length > 20) {
                  name = "${name.substring(0, 20)}...";
                  nameshort = "${nameshort.substring(0, 15)}...";
                }
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        width: maxwidth,
                        // padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                    image: const DecorationImage(
                                      image: AssetImage('assets/images/default.jpg'),
                                      fit: BoxFit.cover,
                                      colorFilter: ColorFilter.mode(
                                        Color.fromARGB(33, 7, 7, 7),
                                        BlendMode.lighten, // หรือใช้ BlendMode.srcATop, overlay ฯลฯ
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(top: 20),
                                              child: Text(
                                                'ID: ${item["monitor_id"] ?? "0"}',
                                                style: TextStyle(fontSize: 12, color: Colors.black87),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(right: 24),
                                          child: Text(
                                            item['datax_value'],
                                            style: const TextStyle(fontSize: 26, color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Body
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (context, setStateDialog) {
                                    return AlertDialog(
                                      title: Stack(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(12),
                                                topRight: Radius.circular(12),
                                              ),
                                              image: const DecorationImage(
                                                image: AssetImage('assets/images/default.jpg'),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Positioned.fill(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    nameshort,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    'ID: ${item["monitor_id"] ?? "0"}',
                                                    style: const TextStyle(fontSize: 20, color: Colors.black87),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      titlePadding: EdgeInsets.all(0),
                                      contentPadding: EdgeInsets.all(14),
                                      content: SizedBox(
                                        width: 480,
                                        height: 500,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              //ข้อมูลจากมิเตอร์
                                              Text(
                                                'Value',
                                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                              Container(
                                                alignment: Alignment.center,
                                                padding: EdgeInsets.only(top: 8, bottom: 8),
                                                child: Text(
                                                  item['datax_value'],
                                                  style: const TextStyle(fontSize: 34, color: Colors.black),
                                                ),
                                              ),
                                              Divider(thickness: 2), // เส้นคั่นใต้หัวข้อ
                                              // Configuration
                                              Text(
                                                'Configuration',
                                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                              Row(
                                                spacing: 20,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(width: maxwidth * 0.15, child: Text('Group :')),
                                                  SizedBox(
                                                    width: maxwidth * 0.5,
                                                    child: DropdownButton<String>(
                                                      value: item['group_id'],
                                                      items: groups.map<DropdownMenuItem<String>>((group) {
                                                        return DropdownMenuItem<String>(
                                                          value: group['group_id']?.toString(),
                                                          child: Text(group['group_name'] ?? ''),
                                                        );
                                                      }).toList(),
                                                      isExpanded: true,
                                                      onChanged: (valueg) {
                                                        setStateDialog(() {
                                                          // selectedGroups[index] = valueg;
                                                          item['group_id'] = valueg;
                                                        });
                                                        setState(() {
                                                          item['group_id'] = valueg;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                spacing: 20,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(width: maxwidth * 0.15, child: Text('Device :')),
                                                  SizedBox(
                                                    width: maxwidth * 0.5,
                                                    child: DropdownButton<String>(
                                                      value: item['device_id'],
                                                      items: devices.map<DropdownMenuItem<String>>((device) {
                                                        return DropdownMenuItem<String>(
                                                          value: device['device_id']?.toString(),
                                                          child: Text(
                                                            device['divice_name'] ?? '',
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        );
                                                      }).toList(),
                                                      isExpanded: true,
                                                      onChanged: (valued) {
                                                        setStateDialog(() {
                                                          // selectedDevices[index] = valued;
                                                          item['device_id'] = valued;
                                                        });
                                                        setState(() {
                                                          item['device_id'] = valued;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                spacing: 20,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(width: maxwidth * 0.15, child: Text('Type :')),
                                                  SizedBox(
                                                    width: maxwidth * 0.5,
                                                    child: DropdownButton<String>(
                                                      value: item['type_id'],
                                                      items: types.map<DropdownMenuItem<String>>((type) {
                                                        return DropdownMenuItem<String>(
                                                          value: type['type_id'],
                                                          child: Text('[${type['type_id']}] ${type['type_name']}'),
                                                        );
                                                      }).toList(),
                                                      isExpanded: true,
                                                      onChanged: (value) {
                                                        setStateDialog(() {
                                                          // selectedTypes[index] = value;
                                                          item['type_id'] = value;
                                                        });
                                                        setState(() {
                                                          item['type_id'] = value;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                spacing: 20,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(width: maxwidth * 0.15, child: Text('Data :')),
                                                  SizedBox(
                                                    width: maxwidth * 0.5,
                                                    child: DropdownButton<String>(
                                                      value: item['datax_id'],
                                                      items: dataxs.map<DropdownMenuItem<String>>((datax) {
                                                        return DropdownMenuItem<String>(
                                                          value: datax['datax_id']?.toString(),
                                                          child: Text(datax['datax_name'] ?? ''),
                                                        );
                                                      }).toList(),
                                                      isExpanded: true,
                                                      onChanged: (valuex) {
                                                        setStateDialog(() {
                                                          // selectedDataxs[index] = valuex;
                                                          // ถ้าต้องการอัปเดตค่าใน data ด้วย (เช่นในฐานข้อมูล)
                                                          item['datax_id'] = valuex;
                                                        });
                                                        setState(() {
                                                          item['datax_id'] = valuex;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Divider(thickness: 2), // เส้นคั่นใต้หัวข้อ
                                              // Notify
                                              Text(
                                                'Notify and Time',
                                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                              Container(
                                                height: 550,
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Switch(
                                                          padding: EdgeInsets.only(right: 18),
                                                          value: item['is_min'] == '1',
                                                          onChanged: (value) {
                                                            setStateDialog(() {
                                                              item['is_min'] = value ? '1' : '0';
                                                            });
                                                            setState(() {
                                                              data[index]['is_min'] = value ? '1' : '0';
                                                            });
                                                          },
                                                          activeThumbColor: Colors.green,
                                                          inactiveThumbColor: Colors.grey,
                                                        ),
                                                        SizedBox(width: 50, child: Text("min :")),
                                                        Expanded(
                                                          child: TextField(
                                                            controller: minControllers[index],
                                                            onChanged: (value) {
                                                              setState(() {
                                                                data[index]['min_value'] = value;
                                                              });
                                                              setStateDialog(() {
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
                                                            setStateDialog(() {
                                                              item['is_max'] = value ? '1' : '0';
                                                            });
                                                            setState(() {
                                                              data[index]['is_max'] = value ? '1' : '0';
                                                            });
                                                          },
                                                          activeThumbColor: Colors.green,
                                                          inactiveThumbColor: Colors.grey,
                                                        ),
                                                        SizedBox(width: 50, child: Text("max :")),
                                                        Expanded(
                                                          child: TextField(
                                                            controller: maxControllers[index],
                                                            onChanged: (value) {
                                                              setState(() {
                                                                data[index]['max_value'] = value;
                                                              });
                                                              setStateDialog(() {
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
                                                            controller: linesControllers[index],
                                                            onChanged: (value) {
                                                              setState(() {
                                                                data[index]['input_line'] = value;
                                                              });
                                                              setStateDialog(() {
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
                                                            controller: emailsControllers[index],
                                                            onChanged: (value) {
                                                              setState(() {
                                                                data[index]['input_email'] = value;
                                                              });
                                                              setStateDialog(() {
                                                                item['input_email'] = value;
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Expanded(
                                                      child: ListView(
                                                        children: daysList.asMap().entries.map((entry) {
                                                          final index = entry.key; // 0,1,2,3,...
                                                          final day = entry.value; // 'Mon', 'Tue', ...

                                                          return CheckboxListTile(
                                                            title: Text(day),
                                                            value: listTime.contains(index),
                                                            onChanged: (bool? value) {
                                                              setStateDialog(() {
                                                                if (value == true) {
                                                                  listTime.add(index);
                                                                } else {
                                                                  listTime.remove(index);
                                                                }
                                                              });
                                                              setState(() {
                                                                item['list_time_of_work'] = listTime.join(',');
                                                              });
                                                            },
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Divider(thickness: 2), // เส้นคั่นใต้หัวข้อ
                                            ],
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop(); // ปิด popup
                                          },
                                          child: const Text('ยกเลิก'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop(); // ปิด popup

                                            setState(() {
                                              data[index] = Map<String, dynamic>.from(item);
                                              data[index] = item;
                                            });

                                            await ApiService.updateMonitorById(item);
                                          },
                                          child: const Text('บันทึก'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(txtPath, style: TextStyle(fontSize: 12)),
                                const Text('แก้ไข'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
