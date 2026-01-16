import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/session.dart';
import 'package:iot_app/pages/greenhourse/Home-update.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  List<dynamic> data = [];
  List<dynamic> icons = [];
  late Map<String, dynamic> user;
  final Color textColor = Color.fromARGB(255, 48, 25, 0);

  List<Color> colorlist = [
    Color.fromARGB(255, 255, 255, 255),
    Color.fromARGB(255, 255, 255, 255),
    Color.fromARGB(255, 255, 255, 255),
    Color.fromARGB(255, 204, 204, 204),
  ];

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    await _fetchmainBoard();
    await _fetchicons();
    setState(() {
      user = CurrentUser;
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> _fetchmainBoard() async {
    final response = await ApiService.fetchMainboard();
    setState(() {
      data = response['data'] as List;
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
    final maxheight = MediaQuery.of(context).size.height;

    // final selected1_6 = data.sublist(1, 6);
    final selected6_12 = data.sublist(6, 12);
    // final selected12_16 = data.sublist(12, 16);

    return Scaffold(
      floatingActionButton: Visibility(
        visible: int.parse(CurrentUser['role_id']) >= 88,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomeUpdatePage())).then((_) {
              _prepare();
            });
          },
          backgroundColor: Colors.white,
          child: Icon(Icons.edit),
        ),
      ),
      body: SafeArea(
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  height: 50,
                  child: Row(
                    spacing: 12,
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                        child: Image.asset('assets/images/pinmap.png', width: 30),
                      ),
                      Text(data[0]['value'], style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
                Container(
                  // color: Colors.green,
                  color: Colors.white,
                  width: maxwidth,
                  height: maxheight * 0.25,
                  child: Center(
                    child: Container(
                      width: maxwidth * 0.8,
                      height: 200 * 0.7,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/photorealistic-scene-poultry-far.png"),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Colors.white12, BlendMode.screen),
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: maxwidth,
                              child: Text(
                                "Tempurature",
                                style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              height: 60,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    child: Column(
                                      children: [
                                        Text("Humidity", style: TextStyle(color: textColor)),
                                        Container(
                                          width: maxwidth / 5,
                                          padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(211, 255, 255, 255),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Center(child: Text("${data[3]['value']}%")),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Column(
                                      children: [
                                        Text("Greenhourse", style: TextStyle(color: textColor)),
                                        Container(
                                          width: maxwidth / 5,
                                          padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(211, 255, 255, 255),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Center(child: Text("${data[4]['value']}°C")),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Column(
                                      children: [
                                        Text("Outdoors", style: TextStyle(color: textColor)),
                                        Container(
                                          width: maxwidth / 5,
                                          padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(211, 255, 255, 255),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Center(child: Text("${data[5]['value']}°C")),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  width: maxwidth,
                  height: maxheight < 600 ? maxheight * 0.75 : maxheight * 0.6,
                  child: Align(
                    alignment: AlignmentGeometry.bottomCenter,
                    child: Container(
                      width: maxwidth,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 248, 242, 233),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(48)),
                      ),
                      height: maxheight * 0.5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: maxheight * 0.1,
                            child: Text("Overview", style: TextStyle(color: Colors.brown[900], fontSize: 28)),
                          ),
                          Container(
                            width: maxwidth * 0.9,
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: selected6_12.map((item) {
                                return Container(
                                  width: maxwidth / 3.5,
                                  // color: Colors.amber,
                                  padding: EdgeInsets.all(4),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(16)),
                                    ),
                                    padding: EdgeInsets.all(12),
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
                                        Text(
                                          item['label_text'].length > 9
                                              ? item['label_text'].substring(0, 9) + '...'
                                              : item['label_text'],
                                        ),
                                        Text("${item['value']} ${item['unitofvalue'] ?? ''}"),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
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
