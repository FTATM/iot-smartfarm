import 'package:flutter/material.dart';
import 'package:iot_app/components/session.dart';
import 'package:iot_app/pages/Farm/account.dart';
import 'package:iot_app/pages/Farm/schedules.dart';
import 'package:iot_app/pages/greenhourse/branch.dart';
import 'package:iot_app/pages/greenhourse/config.dart';
import 'package:iot_app/pages/greenhourse/datax.dart';
import 'package:iot_app/pages/greenhourse/device.dart';
import 'package:iot_app/pages/greenhourse/group.dart';
import 'package:iot_app/pages/greenhourse/icons.dart';
import 'package:iot_app/pages/greenhourse/users_admin.dart';
import 'package:iot_app/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isLoading = true;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
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
    final maxwidth = MediaQuery.of(context).size.width;
    // final maxheight = MediaQuery.of(context).size.height - kTextTabBarHeight;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          color: Colors.white,
          width: maxwidth,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: maxwidth,
                  // color: Colors.amber,
                  height: 300,
                  child: Column(
                    spacing: 8,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 125, height: 150, child: Image.asset('assets/images/Logo.png')),
                      Container(
                        child: Text(CurrentUser['name'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      Container(child: Text("@${CurrentUser['username']}")),
                    ],
                  ),
                ),
                Container(
                  // color: Colors.pink,
                  width: maxwidth,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    spacing: 4,
                    children: [
                      const Divider(),
                      GestureDetector(
                        child: _menuItem("Configuration", Icons.electric_meter_outlined, Colors.black),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => ConfigPage()));
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isOpen = !_isOpen;
                          });
                        },
                        child: SizedBox(
                          height: 40,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(child: Row(spacing: 4, children: [Icon(Icons.shape_line), Text("Management")])),
                              Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 24), child: Text(">")),
                            ],
                          ),
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _isOpen
                            ? Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      child: _menuItem("Branchs", Icons.account_tree, Colors.black),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const BranchPage()),
                                        );
                                      },
                                    ),
                                    GestureDetector(
                                      child: _menuItem("Groups", Icons.group, Colors.black),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const GroupPage()),
                                        );
                                      },
                                    ),
                                    GestureDetector(
                                      child: _menuItem("Devices", Icons.devices_other, Colors.black),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const DevicePage()),
                                        );
                                      },
                                    ),
                                    GestureDetector(
                                      child: _menuItem("Dataxs", Icons.dataset, Colors.black),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const DataxPage()),
                                        );
                                      },
                                    ),
                                    GestureDetector(
                                      child: _menuItem("Icons", Icons.widgets, Colors.black),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const IconsPage()),
                                        );
                                      },
                                    ),
                                    GestureDetector(
                                      child: _menuItem("Users", Icons.manage_accounts, Colors.black),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const UserAdminPage()),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                      ),
                      GestureDetector(
                        child: _menuItem("Schedule", Icons.schedule, Colors.black),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SchedulePage()));
                        },
                      ),
                      const Divider(),
                      GestureDetector(
                        child: _menuItem("Account", Icons.account_box, Colors.black),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountPage()));
                        },
                      ),
                      GestureDetector(
                        child: _menuItem("Logout", Icons.logout, Colors.red),
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('user');

                          // กลับไปหน้า LoginPage
                          if (context.mounted) {
                            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                              (route) => false,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuItem(String text, IconData icon, Color color) {
    return Container(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Row(
              spacing: 6,
              children: [
                Icon(icon),
                Text(text, style: TextStyle(color: color)),
              ],
            ),
          ),
          Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 24), child: Text(">")),
        ],
      ),
    );
  }
}
