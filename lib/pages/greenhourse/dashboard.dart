import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/DashboardblogById.dart';
import 'package:iot_app/components/EditDashboardItemDialog.dart';
import 'package:iot_app/components/AddDashboardItemDialog.dart';
import 'package:iot_app/components/appbar.dart';
import 'package:iot_app/components/session.dart';
import 'package:iot_app/components/sidebar.dart';
import 'package:iot_app/functions/function.dart';
import 'package:iot_app/pages/greenhourse/dashboard-Create.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isLoading = true;
  bool isEdit = false;
  String userString = "";
  Timer? _timer;
  Map<String, dynamic> user = {};
  List<dynamic> data = [];
  List<dynamic> icons = [];
  List<dynamic> monitors = [];
  List<dynamic> subDashboard = [];
  List<dynamic> clone = [];

  List<TextEditingController> nameControllers = [];
  List<TextEditingController> sizeControllers = [];

  @override
  void initState() {
    super.initState();
    _prepareData();
    // _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
    // final response = await ApiService.fetchDashboardBybranchId(CurrentUser['branch_id'].toString());
    // if (!mounted) return;
    // print("update");
    // setState(() {
    // data = response['data'] as List;
    // });
    // });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _prepareData() async {
    await _fetchDashboard(CurrentUser['branch_id'].toString());
    await _fetchicons();
    await _fetchMonitors();
    await _fetchDashboardSub();

    setState(() {
      user = CurrentUser;
      isLoading = false;
    });
  }

  Future<void> _fetchicons() async {
    final response = await ApiService.fetchIcons();
    setState(() {
      icons = response['data'] as List;
    });
  }

  Future<void> _fetchDashboardSub() async {
    final response = await ApiService.fetchDashboardSub();
    setState(() {
      subDashboard = response['data'] as List;
    });
  }

  Future<void> _fetchMonitors() async {
    final response = await ApiService.fetchConfigBybranchId(CurrentUser['branch_id'].toString());
    setState(() {
      monitors = response['data'] as List;
    });
  }

  Future<void> _fetchDashboard(String branchId) async {
    final response = await ApiService.fetchDashboardBybranchId(branchId);

    // ✅ อัปเดต state เพื่อให้ UI render ใหม่
    setState(() {
      data = response['data'] as List;
      clone = data.map((e) => Map<String, dynamic>.from(e)).toList();

      nameControllers = data.map((item) => TextEditingController(text: item['item_name']?.toString() ?? '')).toList();
      sizeControllers = data.map((item) => TextEditingController(text: item['size']?.toString() ?? '')).toList();
    });
  }

  String colorToHex(Color color) {
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#${r + g + b}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final maxwidth = MediaQuery.of(context).size.width;
    final maxheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBar: AppbarWidget(txtt: user['b_name'] ?? "Loading..."),
      drawer: const SideBarWidget(),
      floatingActionButton: Visibility(
        visible: int.parse(CurrentUser['role_id']) >= 88,
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              isEdit = !isEdit;
            });
          },
          backgroundColor: Colors.white,
          child: Icon(Icons.edit),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 233, 233, 233),
                  Color.fromARGB(255, 105, 105, 105),
                  Color.fromARGB(255, 255, 255, 255),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Visibility(
                  visible: isEdit,
                  child: Container(
                    width: maxwidth,
                    height: 100,
                    padding: EdgeInsets.all(4),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        color: Colors.white,
                      ),
                      child: GestureDetector(
                        child: Center(child: Icon(Icons.add)),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardCreatePage()));
                        },
                      ),
                    ),
                  ),
                ),
                Wrap(
                  direction: Axis.horizontal,
                  children: data.asMap().entries.map((entry) {
                    int index = entry.key;
                    var item = entry.value;
                    // print('${index} ${item}');
                    final bg = hexToColor(item['sub_bg_color_code'] ?? '#999999');
                    return Stack(
                      children: [
                        DashboardBlogByIdWidget(
                          type: item['item_type_id'],
                          size: item['size'],
                          title: item['item_name'],
                          value: item['m_value'] ?? "0",
                          isDialog: false,
                          pathImage: item['i_path'] ?? "img/icons/default.png",
                          color: bg,
                          labelJson: jsonEncode(item['labels']),
                          valueJson: jsonEncode(item['values']),
                          onValueChanged: (keyVal, newVal) {
                            setState(() {
                              item[keyVal] = newVal; // อัปเดตค่าจริงใน parent !!
                            });
                            print(item);
                          },
                        ),
                        SizedBox(
                          width: maxwidth / double.parse(item['size']),
                          child: Visibility(
                            visible: isEdit,
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setStateDialog) {
                                        var filtered = subDashboard.where((element) {
                                          return element['dashboard_item_id'].toString() == item['id'];
                                        }).toList();
                                        return AlertDialog(
                                          title: SizedBox(height: 20),
                                          backgroundColor: Colors.white,
                                          titlePadding: EdgeInsets.all(0),
                                          contentPadding: EdgeInsets.all(0),
                                          content: SizedBox(
                                            width: maxwidth,
                                            height: maxheight > 500 ? 500 : maxheight,
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Center(
                                                    child: DashboardBlogByIdWidget(
                                                      type: item['item_type_id'],
                                                      size: item['size'],
                                                      title: item['item_name'],
                                                      value: item['m_value'] ?? "0",
                                                      isDialog: false,
                                                      pathImage: item['i_path'] ?? "img/icons/default.png",
                                                      color: bg,
                                                      labelJson: jsonEncode(item['labels']),
                                                      valueJson: jsonEncode(item['values']),
                                                      onValueChanged: (keyVal, newVal) {
                                                        setState(() {});
                                                      },
                                                    ),
                                                  ),
                                                  const Divider(),
                                                  Container(
                                                    padding: EdgeInsets.all(12),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            SizedBox(width: maxwidth * 0.15, child: Text("Name :")),
                                                            Expanded(
                                                              child: TextField(
                                                                controller: nameControllers[index],
                                                                onChanged: (value) {
                                                                  clone[index]['item_name'] = value;
                                                                  item['item_name'] = value;
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 10),
                                                        Row(
                                                          children: [
                                                            SizedBox(width: maxwidth * 0.15, child: Text("Size :")),
                                                            Expanded(
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                children: [
                                                                  Column(
                                                                    children: [
                                                                      Checkbox(
                                                                        value: sizeControllers[index].text == "1",
                                                                        onChanged: (v) {
                                                                          // setState(() {
                                                                          //   data[index]['size'] =
                                                                          //       "1";
                                                                          // });
                                                                          setStateDialog(() {
                                                                            sizeControllers[index].text = '1';
                                                                            clone[index]['size'] = '1';
                                                                            item['size'] = '1';
                                                                          });
                                                                        },
                                                                      ),
                                                                      Text("Large"),
                                                                    ],
                                                                  ),
                                                                  Column(
                                                                    children: [
                                                                      Checkbox(
                                                                        value: sizeControllers[index].text == "2",
                                                                        onChanged: (v) {
                                                                          // setState(() {
                                                                          //   data[index]['size'] =
                                                                          //       "2";
                                                                          // });
                                                                          setStateDialog(() {
                                                                            sizeControllers[index].text = '2';
                                                                            clone[index]['size'] = '2';
                                                                            item['size'] = '2';
                                                                          });
                                                                        },
                                                                      ),
                                                                      Text("Medium"),
                                                                    ],
                                                                  ),
                                                                  Column(
                                                                    children: [
                                                                      Checkbox(
                                                                        value: sizeControllers[index].text == "3",
                                                                        onChanged: (v) {
                                                                          // setState(() {
                                                                          //   data[index]['size'] =
                                                                          //       "3";
                                                                          // });
                                                                          setStateDialog(() {
                                                                            sizeControllers[index].text = '3';
                                                                            clone[index]['size'] = '3';
                                                                            item['size'] = '3';
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
                                                        Container(
                                                          width: maxwidth * 0.8,
                                                          height: 60,
                                                          child: Row(
                                                            children: [
                                                              SizedBox(width: maxwidth * 0.15, child: Text("Icon :")),
                                                              SizedBox(
                                                                width: maxwidth * 0.5,
                                                                child: DropdownButton<String>(
                                                                  value: item['icon_id'].toString(),
                                                                  items: icons.map<DropdownMenuItem<String>>((icons) {
                                                                    return DropdownMenuItem<String>(
                                                                      value: icons['id']?.toString(),
                                                                      child: Text(icons['name'] ?? ''),
                                                                    );
                                                                  }).toList(),
                                                                  isExpanded: true,
                                                                  onChanged: (valuex) {
                                                                    setStateDialog(() {
                                                                      item['icon_id'] = valuex;
                                                                    });
                                                                    // setState(() {
                                                                    //   item['icon_id'] =
                                                                    //       valuex;
                                                                    // });
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          width: maxwidth,
                                                          height: 30,
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text("Data :", textAlign: TextAlign.left),
                                                              Container(
                                                                padding: EdgeInsets.only(right: 10),
                                                                child: GestureDetector(
                                                                  child: Icon(Icons.add),
                                                                  onTap: () async {
                                                                    Map<String, dynamic> data = {};
                                                                    final result = await showDialog(
                                                                      context: context,
                                                                      builder: (context) =>
                                                                          AddDashboardItemDialog(monitors: monitors),
                                                                    );

                                                                    if (result != null) {
                                                                      setStateDialog(() {
                                                                        data['dashboard_id'] = item['id'];
                                                                        data['data'] = [result['monitor_id']];
                                                                        data['name'] = result['monitor_name'];
                                                                        data['label_color_code'] =
                                                                            result['label_color_code'];
                                                                      });

                                                                      print(data);
                                                                      var response =
                                                                          await ApiService.createSubDashboard(data);
                                                                      if (response['status'] == 'success') {
                                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                                          SnackBar(content: Text("เพิ่มข้อมูลสำเร็จ")),
                                                                        );
                                                                        _prepareData();
                                                                      } else {
                                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                                          SnackBar(
                                                                            content: Text(
                                                                              "การบันทึกข้อมูล เกิดข้อผิดพลาด โปรดลองอีกครั้งในภายหลัง.",
                                                                            ),
                                                                          ),
                                                                        );
                                                                      }
                                                                    }
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          child: Column(
                                                            children: filtered.asMap().entries.map((entry2) {
                                                              // int index2 = entry2.key;
                                                              var item2 = entry2.value;
                                                              return Container(
                                                                margin: const EdgeInsets.only(bottom: 8),
                                                                padding: const EdgeInsets.all(12),
                                                                decoration: BoxDecoration(
                                                                  color: const Color.fromARGB(255, 231, 231, 231),
                                                                  borderRadius: BorderRadius.circular(8),
                                                                ),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Text("ID : "),
                                                                        Text(
                                                                          "${item2["monitor_id"]}",
                                                                          style: TextStyle(fontSize: 16),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Text(
                                                                      item2["label_name"],
                                                                      style: TextStyle(
                                                                        fontSize: 16,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width: 30,
                                                                      height: 30,
                                                                      decoration: BoxDecoration(
                                                                        border: Border.all(),
                                                                        color: hexToColor(
                                                                          item2['label_color_code'] ?? "",
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    GestureDetector(
                                                                      onTap: () async {
                                                                        final result = await showDialog(
                                                                          context: context,
                                                                          builder: (context) => EditDashboardItemDialog(
                                                                            subItem: item2,
                                                                            monitors: monitors,
                                                                          ),
                                                                        );

                                                                        if (result != null) {
                                                                          print(result);
                                                                          if (result['delete']) {
                                                                            var response =
                                                                                await ApiService.deleteSubDashboardById(
                                                                                  item2,
                                                                                );
                                                                            if (response['status'] == 'success') {
                                                                              ScaffoldMessenger.of(
                                                                                context,
                                                                              ).showSnackBar(
                                                                                SnackBar(
                                                                                  content: Text("ลบข้อมูลสำเร็จ"),
                                                                                ),
                                                                              );
                                                                            }
                                                                          } else {
                                                                            setStateDialog(() {
                                                                              item2['monitor_id'] =
                                                                                  result['monitor_id'];
                                                                              item2['label_color_code'] =
                                                                                  result['label_color_code'];
                                                                            });

                                                                            var response =
                                                                                await ApiService.updateSubDashboardById(
                                                                                  item2,
                                                                                );
                                                                            if (response['status'] == 'success') {
                                                                              ScaffoldMessenger.of(
                                                                                context,
                                                                              ).showSnackBar(
                                                                                SnackBar(
                                                                                  content: Text("แก้ไขข้อมูลสำเร็จ"),
                                                                                ),
                                                                              );
                                                                            } else {
                                                                              ScaffoldMessenger.of(
                                                                                context,
                                                                              ).showSnackBar(
                                                                                SnackBar(
                                                                                  content: Text(
                                                                                    "บันทึกข้อมูล เกิดข้อผิดพลาด โปรดลองอีกครั้งในภายหลัง.",
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            }
                                                                          }
                                                                          Navigator.of(context).pop();
                                                                          _prepareData();
                                                                        }
                                                                      },
                                                                      child: Icon(Icons.edit),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            }).toList(),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          actions: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                TextButton(
                                                  style: ButtonStyle(
                                                    backgroundColor: WidgetStatePropertyAll(Colors.red),
                                                  ),
                                                  onPressed: () async {
                                                    final response = await ApiService.deleteDashboardById(item);
                                                    if (response['status'] == 'success') {
                                                      _fetchDashboard(CurrentUser['branch_id']);
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(SnackBar(content: Text("ลบสำเร็จ")));
                                                      Navigator.of(context).pop();
                                                    }
                                                  },
                                                  child: const Text('ลบ', style: TextStyle(color: Colors.white)),
                                                ),
                                                Row(
                                                  children: [
                                                    TextButton(
                                                      onPressed: () async {
                                                        Navigator.of(context).pop(); // ปิด popup
                                                        setState(() {
                                                          clone[index] = Map<String, dynamic>.from(data[index]);
                                                        });
                                                      },
                                                      child: const Text('ยกเลิก'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        Navigator.of(context).pop(); // ปิด popup

                                                        setState(() {
                                                          data[index] = clone[index];
                                                          // Map<String, dynamic>.from(
                                                          //   clone[index],
                                                          // );
                                                        });

                                                        var res = await ApiService.updateDashboardById(item);

                                                        print(res);
                                                        final responsedata = await ApiService.fetchDashboardBybranchId(
                                                          CurrentUser['branch_id'].toString(),
                                                        );
                                                        setState(() {
                                                          data = responsedata['data'] as List;
                                                        });
                                                      },
                                                      child: const Text('บันทึก'),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              child: Align(
                                alignment: AlignmentGeometry.centerRight,
                                child: Padding(padding: EdgeInsets.all(6), child: Icon(Icons.edit, size: 16)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
