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
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final maxwidth = MediaQuery.of(context).size.width;
    final maxheight = MediaQuery.of(context).size.height - kTextTabBarHeight;

    final fs_small = maxwidth < 400 ? 12.0 : 14.0;
    // ดึง item ลำดับที่ 6 - 12 (index 6 ถึง 12)
    final selected1_6 = data.sublist(1, 6);
    final selected6_15 = data.sublist(6, 15);
    final selected15_19 = data.sublist(15, 19);
    return Scaffold(
      backgroundColor: Colors.white,
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
      body: Container(
        width: maxwidth,
        // height: maxheight,
        decoration: BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: maxwidth * 0.45 - 12,
                        height: maxheight * 0.3,
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
                        width: maxwidth * 0.5 - 12,
                        height: maxheight * 0.3,
                        // color: Colors.amber,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/bg-icon-large.png"),
                            fit: BoxFit.cover,
                            // colorFilter: ColorFilter.mode(Colors.white54, BlendMode.screen),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          // boxShadow: [BoxShadow(
                          //   color: Colors.black12,
                          //   blurRadius: 5,
                          //   spreadRadius: 2
                          // )]
                        ),
                        padding: EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 8,
                          children: selected1_6.map((item) {
                            return Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    width: ((maxwidth * 0.5) - 12) * 0.45 - 8,
                                    // height: maxheight * 0.05,
                                    decoration: BoxDecoration(
                                      // gradient: LinearGradient(
                                      //   colors: colorlist,
                                      //   begin: Alignment.topCenter,
                                      //   end: Alignment.bottomCenter,
                                      // ),
                                      color: Colors.black12,
                                      // border: Border.all(width: 0.5),
                                      borderRadius: BorderRadius.all(Radius.circular(6)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        item['label_text'].length > 11
                                            ? item['label_text'].substring(0, 8) + '...'
                                            : item['label_text'],
                                        style: TextStyle(color: Colors.black, fontSize: fs_small),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: ((maxwidth * 0.5) - 12) * 0.45 - 8,
                                    // height: maxheight * 0.05,
                                    decoration: BoxDecoration(
                                      // gradient: LinearGradient(
                                      //   colors: colorlist,
                                      //   begin: Alignment.topCenter,
                                      //   end: Alignment.bottomCenter,
                                      // ),
                                      color: Colors.black12,
                                      // border: Border.all(width: 0.5),
                                      borderRadius: BorderRadius.all(Radius.circular(6)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        item['value'].length > 11
                                            ? item['value'].substring(0, 8) + '...'
                                            : item['value'],
                                        style: TextStyle(color: Colors.black, fontSize: fs_small),
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
                  child: Center(
                    child: Wrap(
                      children: selected6_15.map((item) {
                        return Container(
                          width: (maxwidth / 3) - 4,
                          padding: EdgeInsets.all(8),
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/images/bg-icon-small.png"),
                                fit: BoxFit.fill,
                                // colorFilter: ColorFilter.mode(Colors.white54, BlendMode.screen),
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Column(
                              children: [
                                Container(
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
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
                                    color: Colors.black12,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(item['label_text'], style: TextStyle(color: Colors.black)),
                                      Text("${item['value']} ${item['unitofvalue'] == '' ? "x" : item['unitofvalue']}"),
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
                  width: maxwidth,
                  padding: EdgeInsets.all(12),
                  child: Center(
                    child: Container(
                      // width: maxwidth * 0.9,
                      child: Column(
                        spacing: 12,
                        children: selected15_19.map((item) {
                          return Container(
                            width: maxwidth,
                            height: maxheight * 0.06,
                            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: maxheight * 0.05,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(8),
                                      right: Radius.circular(20),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        offset: Offset(0, 3),
                                        color: Colors.black12,
                                        blurRadius: 3,
                                        spreadRadius: 1,
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
                                      SizedBox(width: maxwidth * 0.4, child: Text(item['label_text'])),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: maxwidth * 0.25,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: maxwidth * 0.1,
                                        child: Center(child: Text(item['value'])),
                                      ),
                                      Container(child: Text(item['unitofvalue'] ?? "x", textAlign: TextAlign.end)),
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
