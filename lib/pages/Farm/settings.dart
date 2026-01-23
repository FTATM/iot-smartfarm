import 'package:flutter/material.dart';
import 'package:iot_app/components/session.dart';
import 'package:iot_app/pages/Farm/account.dart';
import 'package:iot_app/pages/Farm/guidebook.dart';
import 'package:iot_app/pages/Farm/schedules.dart';
import 'package:iot_app/pages/greenhourse/branch.dart';
import 'package:iot_app/pages/greenhourse/config.dart';
import 'package:iot_app/pages/greenhourse/datax.dart';
import 'package:iot_app/pages/greenhourse/device.dart';
import 'package:iot_app/pages/greenhourse/group.dart';
import 'package:iot_app/pages/greenhourse/icons.dart';
import 'package:iot_app/pages/greenhourse/logos.dart';
import 'package:iot_app/pages/greenhourse/users_admin.dart';
import 'package:iot_app/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isLoading = false;
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ================= PROFILE =================
              const SizedBox(height: 32),
              Container(
                width: 120,
                height: 120,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Image.asset('assets/images/Logo.png'),
              ),
              const SizedBox(height: 16),
              Text(
                CurrentUser['name'] ?? "Administrator",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text("@${CurrentUser['username'] ?? 'admin'}", style: const TextStyle(color: Colors.grey)),

              const SizedBox(height: 32),

              // ================= SETTINGS =================
              _sectionTitle("Setting"),
              _card([
                Visibility(
                  visible: int.parse(CurrentUser['role_id']) >= 55,
                  child: _menuItem("Configuration", Icons.tune, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ConfigPage()));
                  }),
                ),
                Visibility(
                  visible: int.parse(CurrentUser['role_id']) >= 55,
                  child: _menuItem("Management", Icons.group, () {
                    setState(() => _isOpen = !_isOpen);
                  }),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: _isOpen
                      ? Column(
                          children: [
                            _subMenu("Branchs", Icons.account_tree_sharp, () => _go(const BranchPage())),
                            _subMenu("Groups", Icons.group, () => _go(const GroupPage())),
                            _subMenu("Devices", Icons.devices, () => _go(const DevicePage())),
                            _subMenu("Dataxs", Icons.data_usage, () => _go(const DataxPage())),
                            _subMenu("Icons", Icons.image, () => _go(const IconsPage())),
                            _subMenu("Logos", Icons.layers, () => _go(const LogosPage())),
                            _subMenu("Users", Icons.person, () => _go(const UserAdminPage())),
                          ],
                        )
                      : const SizedBox(),
                ),
                Visibility(
                  visible: int.parse(CurrentUser['role_id']) >= 55,
                  child: _menuItem("Schedule", Icons.schedule, () {
                    _go(const SchedulePage());
                  }),
                ),
                _menuItem("Knowledge", Icons.menu_book, () {
                  _go(const GuidebookPage());
                }),
              ]),

              const SizedBox(height: 24),

              // ================= ACCOUNTS =================
              _sectionTitle("Accounts"),
              _card([
                _menuItem("Accounts", Icons.person, () {
                  _go(const AccountPage());
                }),
                _menuItem("Logout", Icons.logout, () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('user');
                  // กลับไปหน้า LoginPage
                  if (context.mounted) {
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
                  }
                }, color: Colors.red),
              ]),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ================= COMPONENTS =================

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }

  Widget _menuItem(String text, IconData icon, VoidCallback onTap, {Color color = Colors.black}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text, style: TextStyle(color: color, fontSize: 16)),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _subMenu(String text, IconData icon, VoidCallback onTap) {
    return Padding(padding: const EdgeInsets.only(left: 60), child: _menuItem(text, icon, onTap));
  }

  void _go(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}
