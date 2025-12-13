import 'package:flutter/material.dart';
import 'package:iot_app/components/session.dart';
import 'package:iot_app/pages/Farm/mainFarm.dart';
import 'package:iot_app/pages/greenhourse/branch.dart';
import 'package:iot_app/pages/greenhourse/config.dart';
import 'package:iot_app/pages/greenhourse/dashboard.dart';
import 'package:iot_app/pages/greenhourse/datax.dart';
import 'package:iot_app/pages/greenhourse/device.dart';
import 'package:iot_app/pages/greenhourse/group.dart';
import 'package:iot_app/pages/greenhourse/icons.dart';
import 'package:iot_app/pages/login.dart';
import 'package:iot_app/pages/greenhourse/users_admin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SideBarWidget extends StatelessWidget {
  const SideBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 255, 255), // 💙 สีเริ่มต้น
                  Color.fromARGB(255, 18, 185, 88), // 💜 สีปลายทาง
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Text("Menu", style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const mainboardPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Dashboard"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardPage()));
            },
          ),
          Visibility(
            visible: int.parse(CurrentUser['role_id']) >= 88,
            child: ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Configuration"),
              onTap: () {
                Navigator.pop(context); // ปิด Drawer ก่อน
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ConfigPage()));
              },
            ),
          ),
          Visibility(
            visible: int.parse(CurrentUser['role_id']) >= 88,
            child: ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Icons"),
              onTap: () {
                Navigator.pop(context); // ปิด Drawer ก่อน
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const IconsPage()));
              },
            ),
          ),
          Visibility(
            visible: int.parse(CurrentUser['role_id']) >= 88,
            child: ListTile(
              leading: const Icon(Icons.house_siding),
              title: const Text("Branch"),
              onTap: () {
                Navigator.pop(context); // ปิด Drawer ก่อน
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BranchPage()));
              },
            ),
          ),
          Visibility(
            visible: int.parse(CurrentUser['role_id']) >= 88,
            child: ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text("Groups"),
              onTap: () {
                Navigator.pop(context); // ปิด Drawer ก่อน
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const GroupPage()));
              },
            ),
          ),
          Visibility(
            visible: int.parse(CurrentUser['role_id']) >= 88,
            child: ListTile(
              leading: const Icon(Icons.app_settings_alt),
              title: const Text("Devices"),
              onTap: () {
                Navigator.pop(context); // ปิด Drawer ก่อน
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DevicePage()));
              },
            ),
          ),
          Visibility(
            visible: int.parse(CurrentUser['role_id']) >= 88,
            child: ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Data"),
              onTap: () {
                Navigator.pop(context); // ปิด Drawer ก่อน
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DataxPage()));
              },
            ),
          ),
          Visibility(
            visible: int.parse(CurrentUser['role_id']) >= 88,
            child: ListTile(
              leading: const Icon(Icons.people),
              title: const Text("User settings"),
              onTap: () {
                Navigator.pop(context); // ปิด Drawer ก่อน
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const UserAdminPage()));
              },
            ),
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('user'); // await prefs.clear();

              // กลับไปหน้า LoginPage
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
              }
            },
          ),
        ],
      ),
    );
  }
}
