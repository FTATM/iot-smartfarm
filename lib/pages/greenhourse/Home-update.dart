import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/appbar.dart';
import 'package:iot_app/components/session.dart';

class HomeUpdatePage extends StatefulWidget {
  const HomeUpdatePage({super.key});

  @override
  State<HomeUpdatePage> createState() => _HomeUpdatePageState();
}

class _HomeUpdatePageState extends State<HomeUpdatePage> {
  bool isLoading = true;
  bool isEdit = false;
  String userString = "";
  Map<String, dynamic> user = {};
  List<dynamic> data = [];
  List<dynamic> icons = [];
  List<dynamic> sensors = [];
  Map<String, dynamic> typeofValues = {"1": "Manual Value", "2": "Time Now", "3": "Time manual", "4": "Sensor"};

  List<TextEditingController> labelControllers = [];
  List<TextEditingController> manualController = [];

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  Future<void> _prepareData() async {
    await _fetchicons();
    await _fetchmainBoard();
    await _fetchconfiguration();
    setState(() {
      user = CurrentUser;
      isLoading = false;

      labelControllers = data.map((item) => TextEditingController(text: item['label_text']?.toString() ?? '')).toList();
      manualController = data.map((item) => TextEditingController(text: item['value']?.toString() ?? '')).toList();
    });

  }

  Future<void> _fetchicons() async {
    final response = await ApiService.fetchIcons();
    setState(() {
      icons = response['data'] as List;
    });
  }

  Future<void> _fetchmainBoard() async {
    final response = await ApiService.fetchMainboard();
    setState(() {
      data = response['data'] as List;
    });
  }

  Future<void> _fetchconfiguration() async {
    final response = await ApiService.fetchConfigBybranchId(CurrentUser['branch_id']);
    setState(() {
      sensors = response['data'] as List;
    });
  }

  Widget _buildChildByCase(index, item, maxwidth) {
    switch (item['type_values_id']) {
      case "1":
        return Container(
          // decoration: BoxDecoration(
          //   border: Border.all(),
          //   borderRadius: BorderRadius.all(Radius.circular(16))
          // ),
          child: TextField(
            controller: manualController[index],
            decoration: InputDecoration(labelText: "value", border: OutlineInputBorder()),
            onChanged: (value) {
              setState(() {
                item['value'] = value;
              });
            },
          ),
        );

      /// Case 2 → แสดงเวลา Now
      case "2":
        String now = DateTime.now().toString().substring(0, 10);
        setState(() {
          item['value'] = now;
        });
        return Text(now, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));

      /// Case 3 → เลือกวัน เดือน ปี
      case "3":
        // return Text("3");
        return Wrap(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.orange[700])),
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                if (picked != null) {
                  var pickedDate = "${picked.year}-${picked.month}-${picked.day}";
                  setState(() => item['value'] = pickedDate);
                }
              },
              child: Text("เลือกวันที่", style: TextStyle(color: Colors.white)),
            ),

            Padding(
              padding: EdgeInsets.all(10),
              child: Text(item['value'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      case "4":
        return DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: InputDecoration(
            hintText: "เลือก",
            // filled: true,
            fillColor: const Color(0xFFF9FAFB),
            // contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: brandOrange),
            ),
          ),
          items: sensors.map<DropdownMenuItem<String>>((b) {
            return DropdownMenuItem(
              value: b['monitor_id'],
              child: Text(
                "[${b['monitor_id']}] ${b['monitor_name']}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            );
          }).toList(),
          onChanged: (value) {},
        );
      default:
        return Text("โปรดเลือกประเภท", style: TextStyle(color: Colors.grey));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final maxwidth = MediaQuery.of(context).size.width;
    final maxheight = MediaQuery.of(context).size.height - kToolbarHeight;

    return Scaffold(
      backgroundColor: Colors.grey[400],
      appBar: AppbarWidget(txtt: 'Edit Home'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            spacing: 12,
            children: data.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;
              var foundIcon = icons.where((i) {
                return item['icon_id'] == i['id'];
              });

              return Container(
                width: maxwidth,
                // padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    /// header
                    Container(
                      width: maxwidth - 16,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange[700],
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${item['id']} ${item['name']}",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    ///body
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black12, offset: Offset(0, 5), blurRadius: 2)],
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: (maxwidth - 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(child: Text("Label :",textAlign: TextAlign.center,)),
                                SizedBox(
                                  // color: Colors.cyan,
                                  width: (maxwidth - 24) * 0.34,
                                  child: TextField(
                                    controller: labelControllers[index],
                                    decoration: InputDecoration(labelText: "Label", border: OutlineInputBorder()),
                                    onChanged: (value) {
                                      setState(() {
                                        data[index]['label_text'] = value;
                                      });
                                    },
                                  ),
                                ),
                                Expanded(child: Text("Status :",textAlign: TextAlign.center,)),
                                Container(
                                  width: (maxwidth - 24) * 0.2,
                                  child: Switch(
                                    value: item['is_active'] == 't',
                                    activeThumbColor: Colors.orange[700],
                                    inactiveThumbColor: Colors.grey[600],
                                    onChanged: (value) {
                                      setState(() {
                                        item['is_active'] = value ? 't' : 'f';
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Visibility(
                            visible: item['icon_id'] != '0',
                            child: Container(
                              padding: EdgeInsets.only(left: 8),
                              // color: Colors.greenAccent,
                              // width: (maxwidth - 16),
                              child: Row(
                                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(width: maxwidth * 0.15, child: Text("Icon :")),
                                  SizedBox(
                                    width: maxwidth * 0.5,
                                    child: SizedBox(
                                      width: maxwidth * 0.4,
                                      child: DropdownButton<String>(
                                        hint: Text("เลือก icon"),
                                        value: item['icon_id'] == '0' || foundIcon.isEmpty ? null : item['icon_id'],
                                        items: icons.map<DropdownMenuItem<String>>((icon) {
                                          return DropdownMenuItem(value: icon['id'], child: Text(icon['name']));
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() => item['icon_id'] = value);
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      width: maxwidth * 0.15,
                                      height: maxwidth * 0.15,
                                      child: Image.network(
                                        // ignore: prefer_interpolation_to_compose_strings
                                        "${user['baseURL']}../" +
                                            icons.firstWhere(
                                              (i) => i['id'] == item['icon_id'],
                                              orElse: () => {"path": "img/icons/dafault.png"},
                                            )['path'],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Visibility(
                            visible: item['type_values_id'] != '0',
                            child: Container(
                              width: maxwidth - 16,
                              height: maxheight * 0.15,
                              padding: EdgeInsets.only(left: 8),
                              child: Row(
                                children: [
                                  SizedBox(width: maxwidth * 0.15, child: Text("type :")),
                                  SizedBox(
                                    width: maxwidth * 0.34,
                                    child: DropdownButton<String>(
                                      value: item['type_values_id'] == "0" ? '1' : item['type_values_id'],
                                      hint: Text("เลือกประเภท"),
                                      items: typeofValues.entries.map((entry) {
                                        return DropdownMenuItem<String>(value: entry.key, child: Text(entry.value));
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          item['type_values_id'] = value;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: maxwidth * 0.15, child: Text("value :")),
                                  Expanded(child: _buildChildByCase(index, item, maxwidth)),
                                ],
                              ),
                            ),
                          ),

                          Container(
                            width: maxwidth * 0.3,
                            height: 40,
                            child: TextButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(Colors.orange[700]),
                                shadowColor: WidgetStatePropertyAll(Colors.black12),
                              ),

                              onPressed: () async {
                                var response = await ApiService.updateMainboardById(item);
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text(response['message'])));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 12,
                                children: [
                                  Icon(Icons.save_outlined, color: Colors.white),
                                  Text("Save", style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
