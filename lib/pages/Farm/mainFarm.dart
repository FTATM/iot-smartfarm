import 'package:flutter/material.dart';
import 'package:iot_app/pages/Farm/HomeOld.dart';
// import 'package:iot_app/api/apiAll.dart';
// import 'package:iot_app/components/appbar.dart';
// import 'package:iot_app/components/session.dart';
import 'package:iot_app/pages/Farm/live.dart';
import 'package:iot_app/pages/Farm/profile.dart';
import 'package:iot_app/pages/Farm/tutorial.dart';
// import 'package:iot_app/components/sidebar.dart';
// import 'package:iot_app/pages/greenhourse/mainboard-Create.dart';
import 'package:iot_app/pages/Farm/home.dart';

class mainboardPage extends StatefulWidget {
  const mainboardPage({super.key});

  @override
  State<mainboardPage> createState() => _mainboardPageState();
}

class _mainboardPageState extends State<mainboardPage> {
  bool isLoading = true;
  int _currentIndex = 0;
  // bool isEdit = false;
  // String userString = "";
  // Map<String, dynamic> user = {};
  // List<dynamic> data = [];
  // List<dynamic> icons = [];

  final List<Widget> _pages = [
    HomePage(), 
    HomeOldPage(), 
    LivePage(), 
    TutorialPage(), 
    ProfilePage()
  ];

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  Future<void> _prepareData() async {
    // await _fetchicons();
    // await _fetchmainBoard();
    setState(() {
      isLoading = false;
    });
  }

  // Future<void> _fetchicons() async {
  //   final response = await ApiService.fetchIcons();
  //   setState(() {
  //     icons = response['data'] as List;
  //   });
  // }

  // Future<void> _fetchmainBoard() async {
  //   final response = await ApiService.fetchMainboard();
  //   setState(() {
  //     data = response['data'] as List;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // final maxwidth = MediaQuery.of(context).size.width;
    // final maxheight = MediaQuery.of(context).size.height - kTextTabBarHeight;
    // ดึง item ลำดับที่ 6 - 12 (index 6 ถึง 12)
    // final selected6_12 = data.sublist(6, 12);
    // final selected12_16 = data.sublist(12, 16);
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color.fromARGB(255, 255, 136, 0),
        unselectedItemColor: Colors.black,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home 1"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home 2"),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: "Live"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Toturials"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
