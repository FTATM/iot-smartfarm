import 'package:flutter/material.dart';
import 'package:iot_app/pages/greenhourse/HomeOld.dart';
import 'package:iot_app/pages/Farm/live.dart';
import 'package:iot_app/pages/Farm/profile.dart';
import 'package:iot_app/pages/Farm/tutorial.dart';
import 'package:iot_app/pages/Farm/home.dart';

class mainboardPage extends StatefulWidget {
  const mainboardPage({super.key});

  @override
  State<mainboardPage> createState() => _mainboardPageState();
}

class _mainboardPageState extends State<mainboardPage> {
  bool isLoading = true;
  int _currentIndex = 0;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  final List<Widget> _pages = [HomePage(), HomeOldPage(), LivePage(), TutorialPage(), ProfilePage()];

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  Future<void> _prepareData() async {
    setState(() {
      isLoading = false;
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
    return Scaffold(
      body: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(builder: (_) => _pages[_currentIndex]);
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _navigatorKey.currentState?.popUntil((route) => route.isFirst);
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
