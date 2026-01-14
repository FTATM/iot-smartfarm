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
    Color.fromARGB(255, 240, 240, 240),
    Color.fromARGB(255, 240, 240, 240),
    Color.fromARGB(255, 240, 240, 240),
    Color.fromARGB(255, 189, 189, 189),
  ];

  List<Color> gradientColorsSet = [Colors.white, Color.fromRGBO(255, 242, 230, 1)];

  Color primaryColor = Color.fromARGB(255, 255, 131, 0);
  Color blackColor = Colors.black;
  Color whiteColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  Future<void> _prepareData() async {
    setState(() {
      user = CurrentUser;
    });
    await _fetchicons();
    await _fetchmainBoard();
    setState(() {
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
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final maxwidth = MediaQuery.of(context).size.width;
    final maxheight = MediaQuery.of(context).size.height - kTextTabBarHeight;

    final fs_small = maxwidth < 400 ? 10.0 : 14.0;
    // ดึง item ลำดับที่ 6 - 12 (index 6 ถึง 12)
    final selected1_6 = data.sublist(1, 6);
    final selected6_15 = data.sublist(6, 15);
    final selected15_19 = data.sublist(15, 19);
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Visibility(
        visible: int.parse(CurrentUser['role_id']) >= 88,
        child: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MainboardCreatePage())).then((_) {
              _prepareData();
            });
          },
          shape: const CircleBorder(),
          child: const Icon(Icons.edit, color: Colors.white, size: 20),
        ),
      ),
      body: Container(
        width: maxwidth,
        // height: maxheight,
        decoration: BoxDecoration(color: Colors.grey[400]),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.fromLTRB(12, 12, 12, 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    boxShadow: [BoxShadow(offset: Offset(0, 5), color: Colors.black12, blurRadius: 2)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 12,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: maxwidth * 0.5 - 30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.water_drop_outlined, color: blackColor),
                                    Text(
                                      '68%',
                                      style: TextStyle(
                                        color: blackColor,
                                        fontSize: fs_small,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.thermostat_outlined, color: blackColor),
                                    Text(
                                      '32.5°C',
                                      style: TextStyle(
                                        color: blackColor,
                                        fontSize: fs_small,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: maxwidth * 0.5 - 30,
                            height: maxheight * 0.34,
                            child: Image.network(
                              // ignore: prefer_interpolation_to_compose_strings
                              "${user['baseURL']}../" +
                                  icons.firstWhere(
                                    (i) => i['id'] == data[0]['icon_id'],
                                    orElse: () => {"path": "img/icons/ph.png"},
                                  )['path'],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: maxwidth * 0.5 - 30,
                        height: maxheight * 0.35,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 12,
                          children: selected1_6.map((item) {
                            return Flexible(
                              child: Row(
                                spacing: 12,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    // width: ((maxwidth * 0.5) - 12) * 0.45 - 8,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: gradientColorsSet,
                                          begin: AlignmentGeometry.topCenter,
                                          end: AlignmentGeometry.bottomCenter,
                                        ),
                                        border: Border.all(width: 1, color: primaryColor),
                                        borderRadius: BorderRadius.all(Radius.circular(8)),
                                        boxShadow: [
                                          BoxShadow(
                                            offset: Offset(0, 2),
                                            color: Colors.black12,
                                            spreadRadius: 1,
                                            blurRadius: 3,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          item['label_text'].length > 15
                                              ? item['label_text'].substring(0, 12) + '...'
                                              : item['label_text'],
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: fs_small,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      // width: ((maxwidth * 0.5) - 12) * 0.45 - 8,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: gradientColorsSet,
                                          begin: AlignmentGeometry.topCenter,
                                          end: AlignmentGeometry.bottomCenter,
                                        ),
                                        border: Border.all(width: 1, color: primaryColor),
                                        borderRadius: BorderRadius.all(Radius.circular(8)),
                                        boxShadow: [
                                          BoxShadow(
                                            offset: Offset(0, 2),
                                            color: Colors.black12,
                                            spreadRadius: 1,
                                            blurRadius: 3,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          item['value'].length > 15
                                              ? item['value'].substring(0, 12) + '...'
                                              : item['value'],
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: fs_small,
                                            fontWeight: FontWeight.bold,
                                          ),
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
                    ],
                  ),
                ),

                Container(
                  width: maxheight,
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.fromLTRB(12, 6, 12, 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    boxShadow: [BoxShadow(offset: Offset(0, 5), color: Colors.black12, blurRadius: 2)],
                  ),

                  child: Center(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: selected6_15.map((item) {
                        return Container(
                          width: (maxwidth / 3) - 24,
                          child: Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              // color: Colors.white
                              gradient: LinearGradient(
                                begin: AlignmentGeometry.topCenter,
                                end: AlignmentGeometry.bottomCenter,
                                colors: gradientColorsSet,
                              ),
                              border: Border.all(color: primaryColor),
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              boxShadow: [BoxShadow(offset: Offset(0, 5), color: Colors.black12, blurRadius: 2)],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 30,
                                  width: maxwidth / 9,
                                  child: Image.network(
                                    // ignore: prefer_interpolation_to_compose_strings
                                    "${user['baseURL']}../" +
                                        icons.firstWhere(
                                          (i) => i['id'] == item['icon_id'],
                                          orElse: () => {"path": "img/icons/ph.png"},
                                        )['path'],
                                  ),
                                ),
                                Container(
                                  width: (maxwidth / 3),
                                  height: 40,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(item['label_text'], style: TextStyle(color: Colors.black, fontSize: 12)),
                                      Text(
                                        "${item['value']} ${item['unitofvalue'] == '' ? "x" : item['unitofvalue']}",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                Container(
                  width: maxheight,
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.fromLTRB(12, 6, 12, 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    boxShadow: [BoxShadow(offset: Offset(0, 5), color: Colors.black12, blurRadius: 2)],
                  ),
                  child: Center(
                    child: Container(
                      // width: maxwidth * 0.9,
                      child: Column(
                        spacing: 12,
                        children: selected15_19.map((item) {
                          return Container(
                            width: maxwidth,
                            height: maxheight * 0.06,
                            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: ((maxwidth / 3) - 18) * 2,
                                  height: maxheight * 0.075,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    gradient: LinearGradient(
                                      colors: gradientColorsSet,
                                      begin: AlignmentGeometry.topCenter,
                                      end: AlignmentGeometry.bottomCenter,
                                    ),
                                    border: Border.all(color: primaryColor),
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                    boxShadow: [
                                      BoxShadow(
                                        offset: Offset(0, 5),
                                        color: Colors.black12,
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    spacing: 10,
                                    children: [
                                      SizedBox(width: 5),
                                      Container(
                                        width: maxwidth * 0.06,
                                        child: Image.network(
                                          // ignore: prefer_interpolation_to_compose_strings
                                          "${user['baseURL']}../" +
                                              icons.firstWhere(
                                                (i) => i['id'] == item['icon_id'],
                                                orElse: () => {"path": "img/icons/ph.png"},
                                              )['path'],
                                        ),
                                      ),
                                      SizedBox(child: Text(item['label_text'])),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: (maxwidth / 3) - 24,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    gradient: LinearGradient(
                                      colors: gradientColorsSet,
                                      begin: AlignmentGeometry.topCenter,
                                      end: AlignmentGeometry.bottomCenter,
                                    ),
                                    border: Border.all(color: primaryColor),
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                    boxShadow: [
                                      BoxShadow(
                                        offset: Offset(0, 5),
                                        color: Colors.black12,
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: maxwidth * 0.1,
                                        child: Center(child: Text(item['value'])),
                                      ),
                                      Container(
                                        width: maxwidth * 0.1,
                                        child: Center(
                                          child: Text("${item['unitofvalue'] == '' ? "unit" : item['unitofvalue']}"),
                                        ),
                                      ),
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
