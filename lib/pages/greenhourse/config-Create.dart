import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/appbar.dart';
import 'package:iot_app/components/session.dart';

class ConfigCreatePage extends StatefulWidget {
  const ConfigCreatePage({super.key});

  @override
  State<ConfigCreatePage> createState() => _ConfigCreatePageState();
}

class _ConfigCreatePageState extends State<ConfigCreatePage> {
  bool isLoading = true;
  String txtPath = "";
  Timer? _timer;

  List<int> listTime = [];

  List<String> daysList = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  Map<String, dynamic> item = {};

  TextEditingController nameController = TextEditingController();
  TextEditingController minValueController = TextEditingController();
  TextEditingController maxValueController = TextEditingController();
  TextEditingController lineValueController = TextEditingController();
  TextEditingController emailValueController = TextEditingController();

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
    nameController.dispose();
    minValueController.dispose();
    maxValueController.dispose();
    lineValueController.dispose();
    emailValueController.dispose();
    super.dispose();
  }

  void _fetchData() async {
    final gres = await ApiService.fetchGroupsBybranchId(CurrentUser['branch_id']);
    final dres = await ApiService.fetchDevicesBybranchId(CurrentUser['branch_id']);
    final tres = await ApiService.fetchTypesBybranchId();
    final xres = await ApiService.fetchDataxBybranchId(CurrentUser['branch_id']);

    if (!mounted) return;

    setState(() {
      groups = gres['data'] as List;
      devices = dres['data'] as List;
      types = tres['data'] as List;
      dataxs = xres['data'] as List;

      item['branch_id'] = CurrentUser['branch_id'];

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Configuration',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 600),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header with image
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      image: DecorationImage(
                        image: AssetImage('assets/images/default.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                      padding: EdgeInsets.all(20),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'New Configuration',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name Field
                        _buildTextField(
                          label: 'Name',
                          controller: nameController,
                          onChanged: (value) {
                            setState(() {
                              item['monitor_name'] = value;
                            });
                          },
                        ),
                        SizedBox(height: 24),
                        Divider(thickness: 1, color: Colors.grey[300]),
                        SizedBox(height: 20),

                        // Configuration Section
                        Text(
                          'Configuration',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
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
                              child: Text(
                                device['divice_name'] ?? '',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (valued) {
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
                            setState(() {
                              item['datax_id'] = valuex;
                            });
                          },
                        ),
                        SizedBox(height: 24),
                        Divider(thickness: 1, color: Colors.grey[300]),
                        SizedBox(height: 20),

                        // Notify and Time Section
                        Text(
                          'Notify and Time',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16),

                        // Min Switch and Input
                        Row(
                          children: [
                            Switch(
                              value: item['is_min'] == '1',
                              onChanged: (value) {
                                setState(() {
                                  item['is_min'] = value ? '1' : '0';
                                });
                              },
                              activeColor: Color(0xFFFF9F43),
                              inactiveThumbColor: Colors.grey,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'min',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
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
                                  controller: minValueController,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
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
                                setState(() {
                                  item['is_max'] = value ? '1' : '0';
                                });
                              },
                              activeColor: Color(0xFFFF9F43),
                              inactiveThumbColor: Colors.grey,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'max',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
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
                                  controller: maxValueController,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
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
                          controller: lineValueController,
                          onChanged: (value) {
                            setState(() {
                              item['input_line'] = value;
                            });
                          },
                        ),
                        SizedBox(height: 12),

                        // Email Input
                        _buildTextField(
                          label: 'Email',
                          controller: emailValueController,
                          onChanged: (value) {
                            setState(() {
                              item['input_email'] = value;
                            });
                          },
                        ),
                        SizedBox(height: 24),

                        // Days of Week Checkboxes
                        ...daysList.asMap().entries.map((entry) {
                          final index = entry.key;
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
                                    setState(() {
                                      if (listTime.contains(index)) {
                                        listTime.remove(index);
                                      } else {
                                        listTime.add(index);
                                      }
                                      item['list_time_of_work'] = listTime.join(',');
                                    });
                                  },
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: listTime.contains(index)
                                          ? Color(0xFFFF9F43)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: listTime.contains(index)
                                            ? Color(0xFFFF9F43)
                                            : Colors.grey[400]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: listTime.contains(index)
                                        ? Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 18,
                                          )
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              var res = await ApiService.createMonitorById(item);
                              if (res['status'] == 'success') {
                                Navigator.of(context).pop();
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Color(0xFFFF9F43),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'บันทึก',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            items: items,
            isExpanded: true,
            underline: SizedBox(),
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[700]),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
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
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}