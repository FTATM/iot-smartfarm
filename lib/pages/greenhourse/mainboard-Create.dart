import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/appbar.dart';
import 'package:iot_app/components/session.dart';

class MainboardCreatePage extends StatefulWidget {
  const MainboardCreatePage({super.key});

  @override
  State<MainboardCreatePage> createState() => _MainboardCreatePageState();
}

class _MainboardCreatePageState extends State<MainboardCreatePage> {
  bool isLoading = true;
  bool isEdit = false;
  String userString = "";
  Map<String, dynamic> user = {};
  List<dynamic> data = [];
  List<dynamic> icons = [];
  Map<String, dynamic> typeofValues = {"1": "Manaul", "2": "Time", "3": "Time custom"};

  List<TextEditingController> namesControllers = [];
  List<TextEditingController> manualController = [];

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  Future<void> _prepareData() async {
    await _fetchicons();
    await _fetchmainBoard();
    setState(() {
      user = CurrentUser;
      isLoading = false;

      namesControllers = data.map((item) => TextEditingController(text: item['name']?.toString() ?? '')).toList();
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
              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(const Color.fromARGB(255, 54, 148, 0))),
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

      default:
        return Text("โปรดเลือกประเภท", style: TextStyle(color: Colors.grey));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final maxwidth = MediaQuery.of(context).size.width;
    final maxheight = MediaQuery.of(context).size.height - kToolbarHeight;
    return Scaffold(
      appBar: AppbarWidget(txtt: 'Edit mainboard'),
      // drawer: const SideBarWidget(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: data.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;
              return Container(
                width: maxwidth,
                // height: maxheight * 0.35,
                padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    spacing: 8,
                    children: [
                      Container(
                        color: Colors.green[800],
                        width: maxwidth - 16,
                        padding: EdgeInsets.all(4),
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

                      const Divider(height: 1),

                      Container(
                        width: (maxwidth - 16),
                        padding: EdgeInsets.only(left: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(width: maxwidth * 0.15, child: Text("Label :")),
                            Container(
                              // color: Colors.cyan,
                              width: (maxwidth - 16) * 0.4,
                              child: TextField(
                                controller: namesControllers[index],
                                decoration: InputDecoration(labelText: "Label", border: OutlineInputBorder()),
                                onChanged: (value) {
                                  setState(() {
                                    data[index]['label_text'] = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: maxwidth * 0.15, child: Text("Status :")),
                            Container(
                              width: (maxwidth - 16) * 0.2,
                              child: Switch(
                                value: item['is_active'] == 't',
                                activeThumbColor: Colors.green[600],
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
                                    value: item['icon_id'] == '0' ? '1' : item['icon_id'],
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
                                          (i) => i['id'] == data[0]['icon_id'],
                                          orElse: () => {"path": "img/icons/ph.png"},
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

                      SizedBox(
                        width: maxwidth * 0.9,
                        child: TextButton(
                          style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.green[700])),
                          onPressed: () async {
                            var response = await ApiService.updateMainboardById(item);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'])));
                          },
                          child: Text("Save", style: TextStyle(color: Colors.white)),
                        ),
                      ),

                      SizedBox(height: 5),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
