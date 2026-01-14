import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/appbar.dart';
import 'package:iot_app/components/session.dart';
import 'package:iot_app/pages/greenhourse/dashboard.dart';

class DashboardCreatePage extends StatefulWidget {
  const DashboardCreatePage({super.key});

  @override
  State<DashboardCreatePage> createState() => _DashboardCreatePageState();
}

class _DashboardCreatePageState extends State<DashboardCreatePage> {
  bool isLoading = true;

  Map<String, dynamic> data = {'branch_id': CurrentUser['branch_id'],'label_color_code': '#FFF2E6'};
  List<dynamic> listvalues = [0, 0];
  List<dynamic> monitors = [];
  List<dynamic> icons = [];
  List<dynamic> groups = [];
  List<dynamic> devices = [];
  List<dynamic> dataxs = [];
  List<dynamic> types = [];
  List<dynamic> typeDashboards = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchicons();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _fetchData() async {
    final mres = await ApiService.fetchConfigBybranchId(CurrentUser['branch_id']);
    final gres = await ApiService.fetchGroupsBybranchId(CurrentUser['branch_id']);
    final dres = await ApiService.fetchDevicesBybranchId(CurrentUser['branch_id']);
    final tres = await ApiService.fetchTypesBybranchId();
    final xres = await ApiService.fetchDataxBybranchId(CurrentUser['branch_id']);
    final tdres = await ApiService.fetchDashboardType();

    if (!mounted) return;

    setState(() {
      monitors = mres['data'] as List;
      groups = gres['data'] as List;
      devices = dres['data'] as List;
      types = tres['data'] as List;
      dataxs = xres['data'] as List;
      typeDashboards = tdres['data'] as List;

      isLoading = false;
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
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF9800)),
        ),
      );
    }
    final maxwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppbarWidget(txtt: 'Create Dashboard'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFF9800), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Name Field
                _buildFormField(
                  label: "Name :",
                  maxwidth: maxwidth,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "ใส่ชื่อ Dashboard",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        data['name'] = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Type Field
                _buildFormField(
                  label: "Type :",
                  maxwidth: maxwidth,
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    value: data['type_dashboard_id'],
                    isExpanded: true,
                    hint: Text("เลือกประเภท Dashboard", style: TextStyle(color: Colors.grey[400])),
                    items: typeDashboards.map<DropdownMenuItem<String>>((type) {
                      return DropdownMenuItem(value: type['id'], child: Text(type['type_name']));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        data['type_dashboard_id'] = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Size Field
                _buildFormField(
                  label: "Size :",
                  maxwidth: maxwidth,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSizeOption("Large", "1"),
                        _buildSizeOption("Medium", "2"),
                        _buildSizeOption("Small", "3"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Icon Field
                _buildFormField(
                  label: "Icon :",
                  maxwidth: maxwidth,
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          value: data['icon_id'],
                          isExpanded: true,
                          hint: Text("เลือกไอคอน", style: TextStyle(color: Colors.grey[400])),
                          items: icons.map<DropdownMenuItem<String>>((icons) {
                            return DropdownMenuItem<String>(
                              value: icons['id']?.toString(),
                              child: Text(icons['name'] ?? ''),
                            );
                          }).toList(),
                          onChanged: (valuex) {
                            setState(() {
                              data['icon_id'] = valuex;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFF9800), width: 2),
                        ),
                        child: data['icon_id'] != null
                            ? Padding(
                                padding: const EdgeInsets.all(8),
                                child: Image.network(
                                  "${CurrentUser['baseURL']}../" +
                                      icons.firstWhere(
                                        (i) => i['id'] == data['icon_id'],
                                        orElse: () => {"path": "img/icons/default.png"},
                                      )['path'],
                                  fit: BoxFit.contain,
                                ),
                              )
                            : const Icon(Icons.image_outlined, color: Color(0xFFFF9800)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Data Field
                _buildFormField(
                  label: "Data :",
                  maxwidth: maxwidth,
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    isExpanded: true,
                    hint: Text("เลือกข้อมูล", style: TextStyle(color: Colors.grey[400])),
                    items: monitors.map<DropdownMenuItem<String>>((monitor) {
                      return DropdownMenuItem<String>(
                        value: monitor['monitor_id'],
                        child: Text('[${monitor['monitor_id']}] ${monitor['monitor_name'] ?? ""}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        listvalues[0] = value;
                        data['data'] = listvalues;
                      });
                    },
                  ),
                ),

                // Monitor Field (Conditional)
                Visibility(
                  visible: ['2', '5', '6', '12'].contains(data['type_dashboard_id']),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildFormField(
                        label: "Monitor :",
                        maxwidth: maxwidth,
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          isExpanded: true,
                          hint: Text("เลือกข้อมูล", style: TextStyle(color: Colors.grey[400])),
                          items: monitors.map<DropdownMenuItem<String>>((monitor) {
                            return DropdownMenuItem<String>(
                              value: monitor['monitor_id'],
                              child: Text('[${monitor['monitor_id']}] ${monitor['monitor_name'] ?? ""}'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              listvalues[1] = value;
                              data['data'] = listvalues;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Save Button
                Visibility(
                  visible: !listEquals(listvalues, [0, 0]) &&
                      data['icon_id'] != null &&
                      data['type_dashboard_id'] != null &&
                      data['name'] != null,
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () async {
                        var response = await ApiService.createDashboard(data);
                        if (response['status'] == 'success') {
                          data['dashboard_id'] = response['id'];
                          var res = await ApiService.createSubDashboard(data);
                          if (res['status'] == 'success') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const DashboardPage()),
                            );
                          }
                        }
                      },
                      child: const Text(
                        "บันทึก",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildFormField({
    required String label,
    required double maxwidth,
    required Widget child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: maxwidth * 0.2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildSizeOption(String label, String value) {
    final isSelected = data['size'] == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          data['size'] = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF3E0) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF9800) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF9800) : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? const Color(0xFFFF9800) : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFFFF9800) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}