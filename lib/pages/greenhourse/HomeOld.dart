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
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final maxwidth = screenWidth;
    final maxheight = screenHeight - kTextTabBarHeight;

    // Responsive font sizes
    final fs_small = screenWidth < 360 ? 10.0 : screenWidth < 400 ? 12.0 : isLandscape ? 16.0 : 14.0;
    final fs_medium = screenWidth < 360 ? 11.0 : screenWidth < 400 ? 13.0 : isLandscape ? 17.0 : 15.0;
    
    // Responsive spacing
    final spacing = screenWidth < 360 ? 8.0 : isLandscape ? 16.0 : 12.0;
    final padding = screenWidth < 360 ? 8.0 : isLandscape ? 16.0 : 12.0;
    
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
        decoration: BoxDecoration(color: Colors.grey[400]),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Section 1: Top card with image and data
                Container(
                  padding: EdgeInsets.all(padding),
                  margin: EdgeInsets.fromLTRB(padding, padding, padding, padding / 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    boxShadow: [BoxShadow(offset: Offset(0, 5), color: Colors.black12, blurRadius: 2)],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final containerWidth = constraints.maxWidth;
                      final leftWidth = (containerWidth - spacing) / 2;
                      final rightWidth = (containerWidth - spacing) / 2;
                      // ปรับขนาดรูปให้ขยายตามหน้าจอและแนวการจัดวาง
                      final imageHeight = isLandscape 
                          ? maxheight * 0.55  // แนวนอนให้ใหญ่ขึ้นเพื่อใช้พื้นที่ความสูงที่มี
                          : screenWidth < 360 
                              ? maxheight * 0.25 
                              : screenWidth < 600 
                                  ? maxheight * 0.30 
                                  : screenWidth < 900
                                      ? maxheight * 0.35
                                      : maxheight * 0.40;
                      
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left section with image
                          SizedBox(
                            width: leftWidth,
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.water_drop_outlined, color: blackColor, size: isLandscape ? 24 : screenWidth < 360 ? 18 : 20),
                                          SizedBox(width: 4),
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
                                          Icon(Icons.thermostat_outlined, color: blackColor, size: isLandscape ? 24 : screenWidth < 360 ? 18 : 20),
                                          SizedBox(width: 4),
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
                                  // width: leftWidth,
                                  height: isLandscape ? maxheight * 0.8 : imageHeight,
                                  alignment: Alignment.center,
                                  child: Image.network(
                                    "${user['baseURL']}../" +
                                        icons.firstWhere(
                                          (i) => i['id'] == data[0]['icon_id'],
                                          orElse: () => {"path": "img/icons/ph.png"},
                                        )['path'],
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: spacing),
                          // Right section with data rows
                          SizedBox(
                            width: rightWidth,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: selected1_6.map((item) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: spacing),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: gradientColorsSet,
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            border: Border(bottom: BorderSide(width: 2.5, color: primaryColor)),
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
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: spacing),
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: gradientColorsSet,
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            border: Border(bottom: BorderSide(width: 2.5, color: primaryColor)),
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
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
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
                      );
                    },
                  ),
                ),

                // Section 2: Grid of items
                Container(
                  width: maxwidth,
                  margin: EdgeInsets.fromLTRB(padding, padding / 2, padding, padding / 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    boxShadow: [BoxShadow(offset: Offset(0, 5), color: Colors.black12, blurRadius: 2)],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth = (constraints.maxWidth - (spacing * 2)) / 3;
                      // ปรับขนาดไอคอนในแนวนอนให้ใหญ่ขึ้น
                      final iconSize = isLandscape 
                          ? 60.0 
                          : screenWidth < 360 
                              ? 25.0 
                              : screenWidth < 600 
                                  ? 35.0 
                                  : screenWidth < 900 
                                      ? 45.0 
                                      : 55.0;
                      
                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: selected6_15.map((item) {
                          return Container(
                            width: itemWidth,
                            padding: EdgeInsets.all(isLandscape ? 12 : screenWidth < 360 ? 14 : 18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: gradientColorsSet,
                              ),
                              border: Border(bottom: BorderSide(width: 2.5, color: primaryColor)),
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              boxShadow: [BoxShadow(offset: Offset(0, 5), color: Colors.black12, blurRadius: 2)],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: iconSize,
                                  width: iconSize,
                                  child: Image.network(
                                    "${user['baseURL']}../" +
                                        icons.firstWhere(
                                          (i) => i['id'] == item['icon_id'],
                                          orElse: () => {"path": "img/icons/ph.png"},
                                        )['path'],
                                    fit: BoxFit.contain,
                                    color: Color.fromARGB(255, 255, 131, 0),
                                    colorBlendMode: BlendMode.srcATop,
                                  ),
                                ),
                                SizedBox(height: isLandscape ? 8 : 4),
                                Container(
                                  constraints: BoxConstraints(minHeight: isLandscape ? 50 : 40),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item['label_text'],
                                        style: TextStyle(
                                          color: const Color.fromARGB(151, 0, 0, 0),
                                          fontSize: screenWidth < 360 ? 8 : 10,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 1),
                                      Text(
                                        "${item['value']} ${item['unitofvalue'] == '' ? "x" : item['unitofvalue']}",
                                        style: TextStyle(
                                          fontSize: screenWidth < 360 ? 18 : 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),

                // Section 3: List items
                Container(
                  width: maxwidth,
                  margin: EdgeInsets.fromLTRB(padding, padding / 2, padding, padding),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    boxShadow: [BoxShadow(offset: Offset(0, 1), color: const Color.fromARGB(31, 136, 136, 136), blurRadius: 0.2)],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final containerWidth = constraints.maxWidth;
                      final leftWidth = (containerWidth * 2 / 3) - (spacing / 2);
                      final rightWidth = (containerWidth / 3) - (spacing / 2);
                      // ปรับขนาดไอคอนในลิสต์แนวนอน
                      final listIconSize = isLandscape 
                          ? 48.0 
                          : screenWidth < 360 
                              ? 20.0 
                              : screenWidth < 600 
                                  ? 28.0 
                                  : screenWidth < 900 
                                      ? 36.0 
                                      : 44.0;
                      
                      return Column(
                        children: selected15_19.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          
                          return Container(
                            margin: EdgeInsets.only(bottom: index < selected15_19.length - 1 ? spacing : 0),
                            child: Row(
                              children: [
                                Container(
                                  width: leftWidth,
                                  height: listIconSize + (isLandscape ? 32 : 24),
                                  padding: EdgeInsets.symmetric(
                                    vertical: isLandscape ? 16 : 12, 
                                    horizontal: isLandscape ? 12 : 8
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: gradientColorsSet,
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    border: Border(bottom: BorderSide(width: 2.5, color: primaryColor)),
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
                                    children: [
                                      Container(
                                        width: listIconSize,
                                        height: listIconSize,
                                        child: Image.network(
                                          "${user['baseURL']}../" +
                                              icons.firstWhere(
                                                (i) => i['id'] == item['icon_id'],
                                                orElse: () => {"path": "img/icons/ph.png"},
                                              )['path'],
                                          fit: BoxFit.contain,
                                          color: Color.fromARGB(255, 255, 131, 0),
                                          colorBlendMode: BlendMode.srcATop,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item['label_text'],
                                          style: TextStyle(fontSize: fs_small),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: spacing),
                                Container(
                                  width: rightWidth,
                                  height: listIconSize + (isLandscape ? 32 : 24),
                                  padding: EdgeInsets.symmetric(
                                    vertical: isLandscape ? 16 : 12, 
                                    horizontal: 4
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: gradientColorsSet,
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    border: Border(bottom: BorderSide(width: 2.5, color: primaryColor)),
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
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['value'],
                                          style: TextStyle(fontSize: fs_small),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "${item['unitofvalue'] == '' ? "unit" : item['unitofvalue']}",
                                          style: TextStyle(fontSize: fs_small),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
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