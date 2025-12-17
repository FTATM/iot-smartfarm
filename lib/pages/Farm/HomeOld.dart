import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/session.dart';
import 'package:iot_app/pages/greenhourse/mainboard-Create.dart';

class HomeOldPage extends StatefulWidget {
  const HomeOldPage({super.key});

  @override
  State<HomeOldPage> createState() => _HomeOldPageState();
}

class _HomeOldPageState extends State<HomeOldPage> {
  bool isLoading = true;
  bool isEdit = false;
  String userString = "";
  Map<String, dynamic> user = {};
  List<dynamic> data = [];
  List<dynamic> icons = [];

  List<Color> colorlist = [
    Color.fromARGB(255, 255, 255, 255),
    Color.fromARGB(255, 255, 255, 255),
    Color.fromARGB(255, 255, 255, 255),
    Color.fromARGB(255, 204, 204, 204),
  ];

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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(backgroundColor: Colors.white,body: Center(child: CircularProgressIndicator()));
    }
    final maxwidth = MediaQuery.of(context).size.width;
    final maxheight = MediaQuery.of(context).size.height - kTextTabBarHeight;
    // ดึง item ลำดับที่ 6 - 12 (index 6 ถึง 12)
    final selected1_6 = data.sublist(1, 6);
    final selected6_12 = data.sublist(6, 12);
    final selected12_16 = data.sublist(12, 16);
    return Scaffold(
      floatingActionButton: Visibility(
        visible: int.parse(CurrentUser['role_id']) >= 88,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MainboardCreatePage())).then((_) {
              _prepareData();
            });
          },
          backgroundColor: Colors.white,
          child: Icon(Icons.edit),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: maxwidth,
            height: maxheight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 183, 189, 189),
                  Color.fromARGB(255, 176, 189, 189),
                  Color.fromARGB(255, 140, 158, 158),
                ],
                // radius: 3
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              // color: Colors.white,
            ),
            child: Column(
              children: [
                Container(
                  // color: Colors.green,
                  padding: EdgeInsets.all(8),
                  height: maxheight * 0.3,
                  child: Row(
                    children: [
                      Container(
                        // color: Colors.amber,
                        width: maxwidth * 0.4 - 8,
                        child: Image.network(
                          // ignore: prefer_interpolation_to_compose_strings
                          "${user['baseURL']}../" +
                              icons.firstWhere(
                                (i) => i['id'] == data[0]['icon_id'],
                                orElse: () => {"path": "img/icons/ph.png"},
                              )['path'],
                        ),
                      ),
                      Container(
                        width: maxwidth * 0.6 - 8,
                        height: maxheight * 0.3 - 8,
                        // หรือ Expanded ก็ได้
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 4,
                          children: selected1_6.map((item) {
                            return Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    width: (maxwidth * 0.5) * 0.5 - 6,
                                    // height: maxheight * 0.05,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: colorlist,
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      // border: Border.all(width: 0.5),
                                      borderRadius: BorderRadius.all(Radius.circular(6)),
                                    ),
                                    child: Center(
                                      child: Text(item['label_text'], style: TextStyle(color: Colors.black87)),
                                    ),
                                  ),
                                  Container(
                                    width: (maxwidth * 0.5) * 0.5,
                                    // height: maxheight * 0.05,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: colorlist,
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      // border: Border.all(width: 0.5),
                                      borderRadius: BorderRadius.all(Radius.circular(6)),
                                    ),
                                    child: Center(child: Text(item['value'])),
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

                const Divider(),

                Container(
                  width: maxheight,
                  height: maxheight * 0.32,
                  // padding: EdgeInsets.all(8),
                  child: Center(
                    child: Wrap(
                      children: selected6_12.map((item) {
                        return Container(
                          width: (maxwidth / 3) - 8,
                          // color: Colors.amber,
                          padding: EdgeInsets.all(4),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: colorlist,
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            padding: EdgeInsets.all(4),
                            child: Column(
                              children: [
                                Container(
                                  // color: Colors.lightBlue,
                                  // width: maxwidth / 6,
                                  width: maxwidth / 9,
                                  // padding: EdgeInsets.all(8),
                                  child: Image.network(
                                    // ignore: prefer_interpolation_to_compose_strings
                                    "${user['baseURL']}../" +
                                        icons.firstWhere(
                                          (i) => i['id'] == item['icon_id'],
                                          orElse: () => {"path": "img/icons/ph.png"},
                                        )['path'],
                                  ),
                                ),
                                Text(item['name']),
                                Text(item['value']),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const Divider(),
                Container(
                  width: maxwidth,
                  height: maxheight * 0.3,
                  padding: EdgeInsets.all(8),
                  child: Center(
                    child: Container(
                      width: maxwidth * 0.9,
                      child: Column(
                        spacing: 4,
                        children: selected12_16.map((item) {
                          return Container(
                            width: maxwidth,
                            height: maxheight * 0.05,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: colorlist,
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: maxwidth * 0.1,
                                      child: Image.network(
                                        // ignore: prefer_interpolation_to_compose_strings
                                        "${user['baseURL']}../" +
                                            icons.firstWhere(
                                              (i) => i['id'] == item['icon_id'],
                                              orElse: () => {"path": "img/icons/ph.png"},
                                            )['path'],
                                      ),
                                    ),
                                    SizedBox(width: maxwidth * 0.3, child: Text(item['label_text'])),
                                  ],
                                ),
                                Container(
                                  width: maxwidth * 0.2,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: maxwidth * 0.10,
                                        child: Center(child: Text(item['value'])),
                                      ),
                                      SizedBox(width: maxwidth * 0.10, child: Text(item['unitofvalue'] ?? "")),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
