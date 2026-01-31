import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/DashboardblogById.dart';
import 'package:iot_app/components/EditDashboardItemDialog.dart';
import 'package:iot_app/components/AddDashboardItemDialog.dart';
import 'package:iot_app/components/appbar.dart';
import 'package:iot_app/components/session.dart';
import 'package:iot_app/functions/function.dart';
import 'package:iot_app/pages/greenhourse/dashboard-Create.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isLoading = true;
  bool isEdit = false;
  String userString = "";
  Timer? _timer;
  Map<String, dynamic> user = {};
  List<dynamic> data = [];
  List<dynamic> icons = [];
  List<dynamic> monitors = [];
  List<dynamic> subDashboard = [];
  List<dynamic> clone = [];
  String _currentTime = '';
  DateTime _currentDateTime = DateTime.now();

  List<TextEditingController> nameControllers = [];
  List<TextEditingController> sizeControllers = [];
  List<TextEditingController> sortControllers = [];

  @override
  void initState() {
    super.initState();
    _prepareData();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateTime();
      _fetchDashboard(CurrentUser['branch_id']);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in nameControllers) {
      controller.dispose();
    }
    for (var controller in sizeControllers) {
      controller.dispose();
    }
    for (var controller in sortControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentDateTime = now;
      _currentTime =
          '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}:'
          '${now.second.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _prepareData() async {
    await _fetchDashboard(CurrentUser['branch_id'].toString());
    await _fetchicons();
    await _fetchMonitors();
    await _fetchDashboardSub();

    setState(() {
      user = CurrentUser;
      isLoading = false;
    });
  }

  Future<void> _fetchicons() async {
    final response = await ApiService.fetchIcons();
    setState(() {
      icons = response['data'] as List;
    });
  }

  Future<void> _fetchDashboardSub() async {
    final response = await ApiService.fetchDashboardSub();
    setState(() {
      subDashboard = response['data'] as List;
    });
  }

  Future<void> _fetchMonitors() async {
    final response = await ApiService.fetchConfigBybranchId(CurrentUser['branch_id'].toString());
    setState(() {
      monitors = response['data'] as List;
    });
  }

  Future<void> _fetchDashboard(String branchId) async {
    final response = await ApiService.fetchDashboardBybranchId(branchId);

    setState(() {
      // เรียงลำดับจากล่าสุดไปเก่าสุด (ใช้ id)
      data = (response['data'] as List);

      clone = data.map((e) => Map<String, dynamic>.from(e)).toList();

      nameControllers = data.map((item) => TextEditingController(text: item['item_name']?.toString() ?? '')).toList();
      sizeControllers = data.map((item) => TextEditingController(text: item['size']?.toString() ?? '')).toList();
      sortControllers = data.map((item) => TextEditingController(text: item['sort']?.toString() ?? '')).toList();
    });
  }

  String colorToHex(Color color) {
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#${r + g + b}'.toUpperCase();
  }

  String _getFormattedDate() {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return '${days[_currentDateTime.weekday - 1]}, ${_currentDateTime.day} ${months[_currentDateTime.month - 1]} ${_currentDateTime.year}';
  }

  Widget _buildTimeCard(double maxwidth) {
    return Container(
      width: maxwidth - 24,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: const Border(bottom: BorderSide(color: Color(0xFFFF9800), width: 3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Text(
            _currentTime,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(_getFormattedDate(), style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFF9800))),
      );
    }
    final maxwidth = MediaQuery.of(context).size.width;
    final maxheight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppbarWidget(txtt: user['b_name'] ?? "Loading..."),
      floatingActionButton: Visibility(
        visible: int.parse(CurrentUser['role_id']) >= 55,
        child: FloatingActionButton(
          shape: CircleBorder(),
          onPressed: () {
            setState(() {
              isEdit = !isEdit;
            });
          },
          backgroundColor: const Color(0xFFFF9800),
          child: Icon(isEdit ? Icons.done : Icons.edit, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: const Color(0xFFF5F5F5),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Time Card
                _buildTimeCard(maxwidth),

                // Add Dashboard Button (Visible in Edit Mode)
                Visibility(
                  visible: isEdit,
                  child: Container(
                    width: maxwidth,
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        border: const Border(bottom: BorderSide(color: Color(0xFFFF9800), width: 3)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardCreatePage()));
                        },
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: Color(0xFFFF9800), size: 36),
                              SizedBox(height: 4),
                              Text(
                                'Add Dashboard Item',
                                style: TextStyle(color: Color(0xFFFF9800), fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Dashboard Items with proper layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    // คำนวณจำนวนคอลัมน์ตามขนาด
                    List<Widget> buildRow(List<dynamic> items) {
                      // debugPrint(items.toString());
                      return items.map((item) {
                        final bg = hexToColor(item['sub_bg_color_code'] ?? '#999999');
                        final size = double.parse(item['size']);
                        final itemIndex = data.indexOf(item);

                        // คำนวณความกว้างตามขนาด
                        // size 1 = 1 อันต่อแถว (full width)
                        // size 2 = 2 อันต่อแถว (half width)
                        // size 3 = 3 อันต่อแถว (third width)
                        final itemWidth = size == 1
                            ? maxwidth -
                                  24 // Full width minus padding
                            : size == 2
                            ? (maxwidth - 36) /
                                  2 // Half width
                            : (maxwidth - 48) / 3; // Third width

                        return Container(
                          width: itemWidth,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: const Border(bottom: BorderSide(color: Color(0xFFFF9800), width: 3)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: DashboardBlogByIdWidget(
                                  type: item['item_type_id'],
                                  size: item['size'],
                                  title: item['item_name'],
                                  value: item['m_value'] ?? "0",
                                  isDialog: false,
                                  pathImage: item['i_path'] ?? "img/icons/default.png",
                                  color: bg,
                                  labelJson: jsonEncode(item['labels']),
                                  valueJson: jsonEncode(item['values']),
                                  onValueChanged: (keyVal, newVal) async {
                                    setState(() {
                                      item[keyVal] = newVal;
                                    });
                                    if (["2", "4"].contains(item['m_type_id'])) {
                                      final result = await ApiService.updateSensorById(item);
                                    }
                                  },
                                ),
                              ),

                              // Edit Button Overlay
                              Visibility(
                                visible: isEdit,
                                child: Positioned(
                                  top: 8,
                                  right: 8,
                                  child: InkWell(
                                    onTap: () {
                                      _showEditDialog(context, item, itemIndex, maxwidth, maxheight, bg);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(Icons.edit, size: 20, color: Color(0xFFFF9800)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList();
                    }

                    // จัดกลุ่ม items ตามขนาด
                    List<Widget> rows = [];
                    int i = 0;

                    while (i < data.length) {
                      // final currentSize = double.parse(data[i]['size']);

                      rows.add(buildRow([data[i]]).first);
                      i++;
                      // if (currentSize == 1) {
                      //   // ขนาดใหญ่ - 1 อันต่อแถว
                      //   rows.add(Row(mainAxisAlignment: MainAxisAlignment.start, children: buildRow([data[i]])));
                      //   i++;
                      // } else if (currentSize == 2) {
                      //   // ขนาดกลาง - 2 อันต่อแถว
                      //   List<dynamic> rowItems = [data[i]];
                      //   if (i + 1 < data.length && double.parse(data[i + 1]['size']) == 2) {
                      //     rowItems.add(data[i + 1]);
                      //     i += 2;
                      //   } else {
                      //     i++;
                      //   }
                      //   rows.add(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: buildRow(rowItems)));
                      // } else {
                      //   // ขนาดเล็ก - 3 อันต่อแถว
                      //   List<dynamic> rowItems = [data[i]];
                      //   int count = 1;
                      //   while (count < 3 && i + count < data.length && double.parse(data[i + count]['size']) == 3) {
                      //     rowItems.add(data[i + count]);
                      //     count++;
                      //   }
                      //   i += count;
                      //   rows.add(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: buildRow(rowItems)));
                      // }
                    }

                    return Wrap(alignment: WrapAlignment.spaceBetween, children: rows);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, var item, int index, double maxwidth, double maxheight, Color bg) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            var filtered = subDashboard.where((element) {
              return element['dashboard_item_id'].toString() == item['id'];
            }).toList();
            bool foundIcon = icons.any((i) => i['id'] == item['icon_id']);

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                width: maxwidth,
                constraints: BoxConstraints(maxHeight: maxheight > 600 ? 600 : maxheight * 0.85),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with close button
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF9800),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'แก้ไขรายการ',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {
                                clone[index] = Map<String, dynamic>.from(data[index]);
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Preview Card
                            Container(
                              margin: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.3), width: 1),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: const Border(bottom: BorderSide(color: Color(0xFFFF9800), width: 3)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(13),
                                  child: DashboardBlogByIdWidget(
                                    type: item['item_type_id'],
                                    size: item['size'],
                                    title: item['item_name'],
                                    value: item['m_value'] ?? "0",
                                    isDialog: false,
                                    pathImage: item['i_path'] ?? "img/icons/default.png",
                                    color: bg,
                                    labelJson: jsonEncode(item['labels']),
                                    valueJson: jsonEncode(item['values']),
                                    onValueChanged: (keyVal, newVal) {
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                            ),

                            // Edit Form
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Name Field
                                  const Text(
                                    'ชื่อรายการ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF424242),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: nameControllers[index],
                                    decoration: InputDecoration(
                                      hintText: 'กรุณาใส่ชื่อรายการ',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      filled: true,
                                      fillColor: const Color(0xFFFAFAFA),
                                    ),
                                    onChanged: (value) {
                                      clone[index]['item_name'] = value;
                                      item['item_name'] = value;
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // Size Selection
                                  const Text(
                                    'ขนาด',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF424242),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildEnhancedSizeOption(setStateDialog, index, "1", "Large", Icons.crop_square),
                                      _buildEnhancedSizeOption(
                                        setStateDialog,
                                        index,
                                        "2",
                                        "Medium",
                                        Icons.crop_portrait,
                                      ),
                                      _buildEnhancedSizeOption(setStateDialog, index, "3", "Small", Icons.crop_din),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // Sort Field
                                  const Text(
                                    'ลำดับของ Dashboard นี้',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF424242),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: sortControllers[index],
                                    decoration: InputDecoration(
                                      hintText: 'ใส่ตัวเลข',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      filled: true,
                                      fillColor: const Color(0xFFFAFAFA),
                                    ),
                                    onChanged: (value) {
                                      clone[index]['sort'] = value;
                                      item['sort'] = value;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  // Icon Dropdown
                                  const Text(
                                    'ไอคอน',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF424242),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFAFAFA),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFE0E0E0)),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: DropdownButton<String>(
                                      value: foundIcon ? item['icon_id'] : null,
                                      items: icons.map<DropdownMenuItem<String>>((icons) {
                                        return DropdownMenuItem<String>(
                                          value: icons['id']?.toString(),
                                          child: Text(icons['name'] ?? '', style: const TextStyle(fontSize: 14)),
                                        );
                                      }).toList(),
                                      isExpanded: true,
                                      underline: const SizedBox(),
                                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFFF9800)),
                                      onChanged: (valuex) {
                                        setStateDialog(() {
                                          item['icon_id'] = valuex;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Data Section
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'ข้อมูล',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF424242),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          await _handleAddData(context, item, setStateDialog);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF9800),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.add, color: Colors.white, size: 18),
                                              SizedBox(width: 4),
                                              Text(
                                                'เพิ่ม',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Data List
                                  ...filtered
                                      .map((item2) => _buildEnhancedDataItem(context, item2, setStateDialog))
                                      .toList(),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Action Buttons
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        border: Border(top: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Delete Button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await _handleDelete(context, item);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red, width: 2),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.delete_outline, size: 20),
                              label: const Text('ลบ', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Save Button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await _handleSave(context, item, index);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF9800),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.check, size: 20),
                              label: const Text('บันทึก', style: TextStyle(fontWeight: FontWeight.w600)),
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

  Widget _buildEnhancedSizeOption(StateSetter setStateDialog, int index, String size, String label, IconData icon) {
    final isSelected = sizeControllers[index].text == size;

    return InkWell(
      onTap: () {
        setStateDialog(() {
          sizeControllers[index].text = size;
          clone[index]['size'] = size;
          data[index]['size'] = size;
        });
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFFFF9800) : const Color(0xFFE0E0E0), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF9800) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? const Color(0xFFFF9800) : const Color(0xFFD0D0D0), width: 2),
              ),
              child: Center(
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Icon(icon, color: const Color(0xFFBDBDBD), size: 20),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFFFF9800) : const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedDataItem(BuildContext context, var item2, StateSetter setStateDialog) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // ID Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "ID: ${item2["monitor_id"]}",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFFF9800)),
              ),
            ),
            const SizedBox(width: 12),

            // Label Name
            Expanded(
              child: Text(
                item2["label_name"] ?? '',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF424242)),
              ),
            ),

            // Color Indicator
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: hexToColor(item2['label_color_code'] ?? '#FF9800'),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
              ),
            ),
            const SizedBox(width: 8),

            // Edit Button
            InkWell(
              onTap: () async {
                await _handleEditData(context, item2, setStateDialog);
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_outlined, color: Color(0xFFFF9800), size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAddData(BuildContext context, var item, StateSetter setStateDialog) async {
    Map<String, dynamic> newData = {};
    final result = await showDialog(
      context: context,
      builder: (context) => AddDashboardItemDialog(monitors: monitors),
    );

    if (result != null) {
      setStateDialog(() {
        newData['dashboard_id'] = item['id'];
        newData['data'] = [result['monitor_id']];
        newData['name'] = result['monitor_name'];
        newData['label_color_code'] = result['label_color_code'];
      });

      var response = await ApiService.createSubDashboard(newData);
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("เพิ่มข้อมูลสำเร็จ")));
        await _prepareData();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("การบันทึกข้อมูล เกิดข้อผิดพลาด โปรดลองอีกครั้งในภายหลัง.")));
      }
    }
  }

  Future<void> _handleEditData(BuildContext context, var item2, StateSetter setStateDialog) async {
    final result = await showDialog(
      context: context,
      builder: (context) => EditDashboardItemDialog(subItem: item2, monitors: monitors),
    );

    if (result != null) {
      if (result['delete']) {
        var response = await ApiService.deleteSubDashboardById(item2);
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ลบข้อมูลสำเร็จ")));
        }
      } else {
        setStateDialog(() {
          item2['monitor_id'] = result['monitor_id'];
          item2['label_color_code'] = result['label_color_code'];
        });

        var response = await ApiService.updateSubDashboardById(item2);
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("แก้ไขข้อมูลสำเร็จ")));
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("บันทึกข้อมูล เกิดข้อผิดพลาด โปรดลองอีกครั้งในภายหลัง.")));
        }
      }
      Navigator.of(context).pop();
      await _prepareData();
    }
  }

  Future<void> _handleDelete(BuildContext context, var item) async {
    final response = await ApiService.deleteDashboardById(item);
    if (response['status'] == 'success') {
      await _fetchDashboard(CurrentUser['branch_id']);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ลบสำเร็จ")));
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleSave(BuildContext context, var item, int index) async {
    Navigator.of(context).pop();

    if (!mounted) return;
    setState(() {
      data[index] = clone[index];
    });

    await ApiService.updateDashboardById(item);

    final responsedata = await ApiService.fetchDashboardBybranchId(CurrentUser['branch_id'].toString());

    setState(() {
      // เรียงลำดับเหมือนกับ _fetchDashboard
      data = (responsedata['data'] as List);
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("บันทึกสำเร็จ")));
  }
}
