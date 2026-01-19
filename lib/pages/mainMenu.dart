import 'package:flutter/material.dart';
import 'package:iot_app/pages/Farm/knowledge.dart';
import 'package:iot_app/pages/greenhourse/HomeOld.dart';
import 'package:iot_app/pages/Farm/live.dart';
import 'package:iot_app/pages/Farm/settings.dart';
import 'package:iot_app/pages/greenhourse/dashboard.dart';

class mainboardPage extends StatefulWidget {
  const mainboardPage({super.key});

  @override
  State<mainboardPage> createState() => _mainboardPageState();
}

class _mainboardPageState extends State<mainboardPage> {
  bool isLoading = true;
  int _currentIndex = 0;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  final List<Widget> _pages = [
    HomeOldPage(), 
    DashboardPage(), 
    LivePage(), KnowledgePage(), SettingsPage()];

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  Future<void> _prepareData() async {
        if (!mounted) return;
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
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined), label: "Live"),
          BottomNavigationBarItem(icon: Icon(Icons.schedule_outlined), label: "Knowledge"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Settings"),
        ],
      ),
    );
  }

}
