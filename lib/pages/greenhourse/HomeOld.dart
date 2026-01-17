import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/session.dart';
import 'package:iot_app/pages/greenhourse/Home-update.dart';

class HomeOldPage extends StatefulWidget {
  const HomeOldPage({super.key});

  @override
  State<HomeOldPage> createState() => _HomeOldPageState();
}

class ChickenFarmHeader extends StatelessWidget {
  final String title;

  const ChickenFarmHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    // กำหนดความสูงแบบ responsive
    final headerHeight = isSmallScreen
        ? 40.0
        : isLandscape
        ? 50.0
        : screenWidth < 600
        ? 50.0
        : screenHeight * 0.065;

    final Width = isSmallScreen
        ? screenWidth * 0.50
        : isLandscape
        ? screenWidth * 0.50
        : screenWidth < 600
        ? screenWidth * 0.50
        : screenWidth * 0.50;

    return Container(
      height: headerHeight,
      width: Width,
      margin: EdgeInsets.only(left: isSmallScreen ? 16 : 24, right: isSmallScreen ? 16 : 24, top: 1),
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 2 : 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color.fromRGBO(255, 242, 230, 1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(50),
        border: Border(bottom: BorderSide(width: 3.0, color: Color.fromARGB(255, 255, 131, 0))),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
          fontSize: isSmallScreen
              ? 12
              : screenWidth < 600
              ? 16
              : 20,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 255, 131, 0),
          letterSpacing: 2,
          shadows: [
            Shadow(
              color: const Color.fromARGB(30, 0, 0, 0).withOpacity(0.5),
              offset: const Offset(2, 2),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeOldPageState extends State<HomeOldPage> {
  bool isLoading = true;
  bool isEdit = false;
  String userString = "";
  Map<String, dynamic> user = {};
  Map<String, dynamic> weathers = {'tc': '0.00', 'rh': '0.00', 'rain': '0.00', 'ws10m': '0.00'};
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
    await _fetchDataWeathers();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchDataWeathers() async {
    final response = await ApiService.fetchDataWeathers();

    setState(() {
      if (response['status'] == 'success' && response['data'][0]['success']) {
        weathers = response['data'][0]['data']['WeatherForecasts'][0]['forecasts'][0]['data'];
      }
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
    final maxheight = screenHeight;

    // Responsive font sizes
    final fs_small = screenWidth < 360
        ? 10.0
        : screenWidth < 400
        ? 12.0
        : isLandscape
        ? 16.0
        : 14.0;
    // final fs_medium = screenWidth < 360 ? 11.0 : screenWidth < 400 ? 13.0 : isLandscape ? 17.0 : 15.0;

    // Responsive spacing
    final spacing = screenWidth < 360
        ? 8.0
        : isLandscape
        ? 16.0
        : 12.0;
    final padding = screenWidth < 360
        ? 8.0
        : isLandscape
        ? 16.0
        : 12.0;

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
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomeUpdatePage())).then((_) {
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
                // Header Section
                Padding(
                  padding: EdgeInsets.all(padding),
                  child: ChickenFarmHeader(title: user['b_name']?.toString().toUpperCase() ?? 'CHICKEN FARM #1'),
                ),
                // Section 1: Top card with image and data
                Container(
                  padding: EdgeInsets.all(padding),
                  margin: EdgeInsets.fromLTRB(padding, padding / 10, padding, padding / 2),
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
                          ? maxheight * 0.55
                          : maxheight > 800
                          ? 280.00
                          : screenWidth < 360
                          ? maxheight * 0.35
                          : screenWidth < 600
                          ? maxheight * 0.40
                          : screenWidth < 900
                          ? maxheight * 0.35
                          : maxheight * 0.50;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left section with image
                          SizedBox(
                            width: leftWidth,
                            child: Stack(
                              alignment: AlignmentGeometry.center,
                              children: [
                                Positioned(
                                  top: 0,
                                  child: Container(
                                    width: leftWidth,

                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.air,
                                                  color: blackColor,
                                                  size: isLandscape
                                                      ? 24* 0.9
                                                      : screenWidth < 360
                                                      ? 18* 0.9
                                                      : 20* 0.9,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  '${weathers['ws10m']}m/s',
                                                  style: TextStyle(
                                                    color: blackColor,
                                                    fontSize: fs_small* 0.9,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.cloudy_snowing,
                                                  color: blackColor,
                                                  size: isLandscape
                                                      ? 24* 0.9
                                                      : screenWidth < 360
                                                      ? 18* 0.9
                                                      : 20* 0.9,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  '${weathers['rain']}mm',
                                                  style: TextStyle(
                                                    color: blackColor,
                                                    fontSize: fs_small* 0.9,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.water_drop_outlined,
                                                  color: blackColor,
                                                  size: isLandscape
                                                      ? 24* 0.9
                                                      : screenWidth < 360
                                                      ? 18* 0.9
                                                      : 20* 0.9,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  '${weathers['rh']}%',
                                                  style: TextStyle(
                                                    color: blackColor,
                                                    fontSize: fs_small* 0.9,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.thermostat_outlined,
                                                  color: blackColor,
                                                  size: isLandscape
                                                      ? 24* 0.9
                                                      : screenWidth < 360
                                                      ? 18* 0.9
                                                      : 20* 0.9,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  '${weathers['tc']}°C',
                                                  style: TextStyle(
                                                    color: blackColor,
                                                    fontSize: fs_small* 0.9,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: leftWidth - (leftWidth * 0.15),
                                  height: isLandscape ? 300 : imageHeight,
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
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
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
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item['label_text'],
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontSize: fs_small,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                        Text(
                                          item['value'],
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: fs_small,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
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
                  padding: EdgeInsets.all(padding),
                  margin: EdgeInsets.fromLTRB(padding, padding / 2, padding, padding / 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    boxShadow: [BoxShadow(offset: Offset(0, 5), color: Colors.black12, blurRadius: 2)],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final containerWidth = constraints.maxWidth;
                      final itemWidth = (containerWidth - (spacing * 2)) / 3;
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
                            padding: EdgeInsets.all(
                              isLandscape
                                  ? 12
                                  : screenWidth < 360
                                  ? 14
                                  : 18,
                            ),
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
                  padding: EdgeInsets.all(padding),
                  margin: EdgeInsets.fromLTRB(padding, padding / 2, padding, padding),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    boxShadow: [
                      BoxShadow(offset: Offset(0, 1), color: const Color.fromARGB(31, 136, 136, 136), blurRadius: 0.2),
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final containerWidth = constraints.maxWidth;
                      final itemWidth = (containerWidth - (spacing * 2)) / 3;
                      final leftWidth = (itemWidth * 2) + spacing;
                      final rightWidth = itemWidth;
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
                                    horizontal: isLandscape ? 12 : 8,
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
                                  padding: EdgeInsets.symmetric(vertical: isLandscape ? 16 : 12, horizontal: 4),
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
