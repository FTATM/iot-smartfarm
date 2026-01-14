import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/appbar.dart';
import 'package:iot_app/components/session.dart';
import 'package:iot_app/pages/greenhourse/config-Create.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  bool isLoading = true;
  String txtPath = "";
  Timer? _timer;

  List<String> daysList = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  List<TextEditingController> minControllers = [];
  List<TextEditingController> maxControllers = [];
  List<TextEditingController> linesControllers = [];
  List<TextEditingController> emailsControllers = [];

  List<dynamic> data = [];
  List<dynamic> groups = [];
  List<dynamic> devices = [];
  List<dynamic> types = [];
  List<dynamic> dataxs = [];

  List<String?> selectedGroups = [];
  List<String?> selectedDevices = [];
  List<String?> selectedTypes = [];
  List<String?> selectedDataxs = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // _fetchData(); // ดึงซ้ำทุก 5 วิ
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in minControllers) {
      c.dispose();
    }
    for (var c in maxControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _fetchData() async {
    final response = await ApiService.fetchConfigBybranchId(CurrentUser['branch_id']);
    final gres = await ApiService.fetchGroupsBybranchId(CurrentUser['branch_id']);
    final dres = await ApiService.fetchDevicesBybranchId(CurrentUser['branch_id']);
    final tres = await ApiService.fetchTypesBybranchId();
    final xres = await ApiService.fetchDataxBybranchId(CurrentUser['branch_id']);

    if (!mounted) return;

    setState(() {
      data = response['data'] as List;
      groups = gres['data'] as List;
      devices = dres['data'] as List;
      types = tres['data'] as List;
      dataxs = xres['data'] as List;

      minControllers = data.map((item) => TextEditingController(text: item['min_value']?.toString() ?? '')).toList();
      maxControllers = data.map((item) => TextEditingController(text: item['max_value']?.toString() ?? '')).toList();
      linesControllers = data.map((item) => TextEditingController(text: item['input_line']?.toString() ?? '')).toList();
      emailsControllers = data
          .map((item) => TextEditingController(text: item['input_email']?.toString() ?? ''))
          .toList();

      isLoading = false;
    });
  }

  void _showEditDialog(int index, var item, List<int> listTime) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            String nameshort = item["monitor_name"] ?? "-";
            if (nameshort.length > 20) {
              nameshort = "${nameshort.substring(0, 20)}...";
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with image
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                        image: DecorationImage(image: AssetImage('assets/images/default.jpg'), fit: BoxFit.cover),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.5)],
                          ),
                        ),
                        padding: EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                nameshort,
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                'ID : ${item["monitor_id"] ?? "0"}',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Value Section
                            Text(
                              'Value',
                              style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8),
                            Text(
                              item['datax_value'] ?? '0',
                              style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Color(0xFFFF9F43)),
                            ),
                            SizedBox(height: 24),
                            Divider(thickness: 1, color: Colors.grey[300]),
                            SizedBox(height: 20),

                            // Configuration Section
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Configuration',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ),
                            SizedBox(height: 16),
                            // Group Dropdown
                            _buildDropdownField(
                              label: 'Group',
                              value: item['group_id'],
                              items: groups.map<DropdownMenuItem<String>>((group) {
                                return DropdownMenuItem<String>(
                                  value: group['group_id']?.toString(),
                                  child: Text(group['group_name'] ?? ''),
                                );
                              }).toList(),
                              onChanged: (valueg) {
                                setStateDialog(() {
                                  item['group_id'] = valueg;
                                });
                                setState(() {
                                  item['group_id'] = valueg;
                                });
                              },
                            ),
                            SizedBox(height: 12),
                            // Device Dropdown
                            _buildDropdownField(
                              label: 'Device',
                              value: item['device_id'],
                              items: devices.map<DropdownMenuItem<String>>((device) {
                                return DropdownMenuItem<String>(
                                  value: device['device_id']?.toString(),
                                  child: Text(device['divice_name'] ?? '', overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (valued) {
                                setStateDialog(() {
                                  item['device_id'] = valued;
                                });
                                setState(() {
                                  item['device_id'] = valued;
                                });
                              },
                            ),
                            SizedBox(height: 12),

                            // Type Dropdown
                            _buildDropdownField(
                              label: 'Type',
                              value: item['type_id'],
                              items: types.map<DropdownMenuItem<String>>((type) {
                                return DropdownMenuItem<String>(
                                  value: type['type_id'],
                                  child: Text('[${type['type_id']}] ${type['type_name']}'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setStateDialog(() {
                                  item['type_id'] = value;
                                });
                                setState(() {
                                  item['type_id'] = value;
                                });
                              },
                            ),
                            SizedBox(height: 12),

                            // Data Dropdown
                            _buildDropdownField(
                              label: 'Data',
                              value: item['datax_id'],
                              items: dataxs.map<DropdownMenuItem<String>>((datax) {
                                return DropdownMenuItem<String>(
                                  value: datax['datax_id']?.toString(),
                                  child: Text(datax['datax_name'] ?? ''),
                                );
                              }).toList(),
                              onChanged: (valuex) {
                                setStateDialog(() {
                                  item['datax_id'] = valuex;
                                });
                                setState(() {
                                  item['datax_id'] = valuex;
                                });
                              },
                            ),
                            SizedBox(height: 24),
                            Divider(thickness: 1, color: Colors.grey[300]),
                            SizedBox(height: 20),
                            // Notify and Time Section
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Notify and Time',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ),
                            SizedBox(height: 16),

                            // Min Switch and Input
                            Row(
                              children: [
                                Switch(
                                  value: item['is_min'] == '1',
                                  onChanged: (value) {
                                    setStateDialog(() {
                                      item['is_min'] = value ? '1' : '0';
                                    });
                                    setState(() {
                                      data[index]['is_min'] = value ? '1' : '0';
                                    });
                                  },
                                  activeColor: Color(0xFFFF9F43),
                                  inactiveThumbColor: Colors.grey,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'min',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: TextField(
                                      controller: minControllers[index],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      decoration: InputDecoration(border: InputBorder.none, isDense: true),
                                      onChanged: (value) {
                                        setState(() {
                                          data[index]['min_value'] = value;
                                        });
                                        setStateDialog(() {
                                          item['min_value'] = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),

                            // Max Switch and Input
                            Row(
                              children: [
                                Switch(
                                  value: item['is_max'] == '1',
                                  onChanged: (value) {
                                    setStateDialog(() {
                                      item['is_max'] = value ? '1' : '0';
                                    });
                                    setState(() {
                                      data[index]['is_max'] = value ? '1' : '0';
                                    });
                                  },
                                  activeColor: Color(0xFFFF9F43),
                                  inactiveThumbColor: Colors.grey,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'max',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: TextField(
                                      controller: maxControllers[index],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      decoration: InputDecoration(border: InputBorder.none, isDense: true),
                                      onChanged: (value) {
                                        setState(() {
                                          data[index]['max_value'] = value;
                                        });
                                        setStateDialog(() {
                                          item['max_value'] = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            // Line Input
                            _buildTextField(
                              label: 'Line',
                              controller: linesControllers[index],
                              onChanged: (value) {
                                setState(() {
                                  data[index]['input_line'] = value;
                                });
                                setStateDialog(() {
                                  item['input_line'] = value;
                                });
                              },
                            ),
                            SizedBox(height: 12),

                            // Email Input
                            _buildTextField(
                              label: 'Email',
                              controller: emailsControllers[index],
                              onChanged: (value) {
                                setState(() {
                                  data[index]['input_email'] = value;
                                });
                                setStateDialog(() {
                                  item['input_email'] = value;
                                });
                              },
                            ),
                            SizedBox(height: 24),

                            // Days of Week Checkboxes
                            ...daysList.asMap().entries.map((entry) {
                              final dayIndex = entry.key;
                              final day = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      day,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setStateDialog(() {
                                          if (listTime.contains(dayIndex)) {
                                            listTime.remove(dayIndex);
                                          } else {
                                            listTime.add(dayIndex);
                                          }
                                        });
                                        setState(() {
                                          item['list_time_of_work'] = listTime.join(',');
                                        });
                                      },
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: listTime.contains(dayIndex) ? Color(0xFFFF9F43) : Colors.white,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: listTime.contains(dayIndex) ? Color(0xFFFF9F43) : Colors.grey[400]!,
                                            width: 2,
                                          ),
                                        ),
                                        child: listTime.contains(dayIndex)
                                            ? Icon(Icons.check, color: Colors.white, size: 18)
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),

                    // Action Buttons
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                              child: Text(
                                'ยกเลิก',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                setState(() {
                                  data[index] = Map<String, dynamic>.from(item);
                                  data[index] = item;
                                });
                                await ApiService.updateMonitorById(item);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: Color(0xFFFF9F43),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                'บันทึก',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 6),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
          child: DropdownButton<String>(
            value: value,
            items: items,
            isExpanded: true,
            underline: SizedBox(),
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[700]),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 6),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(color: Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: controller,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
            decoration: InputDecoration(border: InputBorder.none, isDense: true),
            onChanged: onChanged,
          ),
        ),
      ],
    );
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

    return Scaffold(
      backgroundColor: Color(0xFFE8E8E8),
      appBar: AppbarWidget(txtt: 'Configuration'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ConfigCreatePage()));
        },
        backgroundColor: Color(0xFFFF9F43),
        child: Icon(Icons.add, color: Colors.white, size: 32),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: data.asMap().entries.map((entry) {
                      int index = entry.key;
                      var item = entry.value;

                      List<int> listTime = [];
                      var raw = item['list_time_of_work'];
                      if (raw != null && raw is String && raw.isNotEmpty) {
                        listTime = raw.split(',').map((e) => int.parse(e)).toList();
                      }

                      txtPath = "";
                      txtPath +=
                          groups.where((g) => g['group_id'] == item['group_id']).map((g) => g['group_name']).first +
                          "/";
                      txtPath +=
                          devices.where((g) => g['device_id'] == item['device_id']).map((g) => g['divice_name']).first +
                          "/";

                      String name = item["monitor_name"] ?? "-";
                      if (name.length > 20) {
                        name = "${name.substring(0, 20)}...";
                      }

                      return Card(
                        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 3,
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with background image (ไม่มี GestureDetector แล้ว)
                            Container(
                              height: 160,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/default.jpg'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.5)],
                                  ),
                                ),
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          item['datax_value'] ?? '0',
                                          style: TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'ID : ${item["monitor_id"] ?? "0"}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Footer
                            Container(
                              padding: EdgeInsets.all(16),
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      txtPath,
                                      style: TextStyle(fontSize: 13, color: Colors.black87),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _showEditDialog(index, item, listTime);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFFFF5EC),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Text(
                                        'แก้ไข',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFFFF9F43),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // Bottom Navigation Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: Offset(0, -2))],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? Color(0xFFFF9F43) : Colors.grey, size: 26),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Color(0xFFFF9F43) : Colors.grey,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
