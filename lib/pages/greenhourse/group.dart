import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/appbar.dart';
import 'package:iot_app/components/session.dart';

const Color brandOrange = Color(0xFFFF8021);
const Color brandOrangeLight = Color(0xFFFF9D52);

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  bool isLoading = true;
  Map<String, dynamic> newname = {'newname': ''};
  List<dynamic> branchs = [];
  List<dynamic> groups = [];
  List<dynamic> temp = [];
  List<TextEditingController> nameControllers = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    final bres = await ApiService.fetchBranchAll();
    final response = await ApiService.fetchGroupsBybranchId(CurrentUser['branch_id']);
    if (!mounted) return;

    setState(() {
      branchs = bres['data'] as List;
      groups = response['data'] as List;
      temp = groups.map((e) => Map<String, dynamic>.from(e)).toList();
      nameControllers = groups
          .map((item) => TextEditingController(text: item['group_name']?.toString() ?? ''))
          .toList();
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
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppbarWidget(txtt: 'Groups Management'),

      floatingActionButton: FloatingActionButton(
        backgroundColor: brandOrange,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        onPressed: () => _showCreateGroupDialog(context),
      ),

      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final item = groups[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF5ED),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          item['group_id'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: brandOrange,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showEditDialog(index, item),
                        child: Text(
                          item['group_name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showDeleteDialog(index, item),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFBDBDBD),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ================= Premium Create Dialog =================

  void _showCreateGroupDialog(BuildContext context) {
    String? selectedBranchId;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Stack(
              children: [
                // iOS blur
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(color: Colors.transparent),
                ),

                Center(
                  child: Dialog(
                    insetPadding: const EdgeInsets.all(16),
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Container(
                      width: 360,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white.withOpacity(0.6)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.12),
                            blurRadius: 40,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -24,
                            right: -24,
                            child: Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: brandOrange.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFF5ED),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.group,
                                      color: brandOrange,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "สร้าง Group ใหม่",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              
                              // ชื่อ Group
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Text(
                                  "ชื่อ Group",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff464646),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                onChanged: (value) {
                                  newname['newname'] = value;
                                },
                                decoration: InputDecoration(
                                  hintText: "กรอกชื่อ Group",
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFB),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        const BorderSide(color: brandOrange),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // เลือก Branch
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Text(
                                  "เลือก Branch",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff464646),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: selectedBranchId,
                                decoration: InputDecoration(
                                  hintText: "เลือก Branch ของ Group",
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFB),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        const BorderSide(color: brandOrange),
                                  ),
                                ),
                                items: branchs.map<DropdownMenuItem<String>>((b) {
                                  return DropdownMenuItem(
                                    value: b['branch_id'],
                                    child: Text(b['branch_name']),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setStateDialog(() {
                                    selectedBranchId = value;
                                    newname['branch_id'] = value;
                                  });
                                },
                              ),
                              
                              const SizedBox(height: 28),
                              
                              // ปุ่มสร้าง
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (newname['newname'] != '') {
                                      final response = await ApiService.createGroup(newname);
                                      if (response['status'] == 'success') {
                                        _fetchData();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("Group ใหม่ ${newname['newname']} ถูกสร้างแล้ว!"),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("เกิดข้อผิดพลาดในการสร้าง")),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Group ใหม่ จำเป็นต้องมีชื่อ!")),
                                      );
                                    }
                                    newname['newname'] = '';
                                    Navigator.pop(context);
                                  },
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          brandOrange,
                                          brandOrangeLight,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color.fromRGBO(255, 128, 33, 0.35),
                                          blurRadius: 14,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "สร้าง",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    newname['newname'] = '';
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    "ยกเลิก",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditDialog(int index, dynamic item) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
            Center(
              child: Dialog(
                insetPadding: const EdgeInsets.all(16),
                backgroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Container(
                  width: 360,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.12),
                        blurRadius: 40,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "เปลี่ยนชื่อ Group",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const SizedBox(
                            width: 80,
                            child: Text(
                              "ชื่อเดิม:",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xff464646),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item['group_name'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Text(
                          "ชื่อใหม่",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff464646),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameControllers[index],
                        onChanged: (value) {
                          temp[index]['group_name'] = value;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: brandOrange),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              nameControllers[index].text = item['group_name'];
                              temp = groups.map((e) => Map<String, dynamic>.from(e)).toList();
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "ยกเลิก",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            height: 42,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: () async {
                                setState(() {
                                  groups = temp.map((e) => Map<String, dynamic>.from(e)).toList();
                                });
                                final response = await ApiService.updateGroupById(groups[index]);
                                if (response['status'] == 'success') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("ทำการเปลี่ยนชื่อเป็น ${groups[index]['group_name']} เรียบร้อยแล้ว"),
                                    ),
                                  );
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("เกิดข้อผิดพลาดในการแก้ไขชื่อ โปรดลองอีกครั้ง"),
                                    ),
                                  );
                                }
                              },
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [brandOrange, brandOrangeLight],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromRGBO(255, 128, 33, 0.35),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 8,
                                ),
                                child: const Text(
                                  "บันทึก",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(int index, dynamic item) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
            Center(
              child: Dialog(
                insetPadding: const EdgeInsets.all(20),
                backgroundColor: const Color(0xFFF6F1F4),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Container(
                  width: 340,
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.18),
                        blurRadius: 30,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "แจ้งเตือน",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "คุณต้องการลบ ${item['group_name']} ใช่หรือไม่?",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFFE53935),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "หากลบแล้วจะไม่สามารถกู้คืนได้ ทำให้มิเตอร์บางส่วนที่เกี่ยวข้องกับ ${item['group_name']} จะไม่สามารถใช้งานได้",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFE53935),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "ยกเลิก",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            height: 42,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: () async {
                                final response = await ApiService.deleteGroupById(groups[index]);
                                if (response['status'] == 'success') {
                                  _fetchData();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("ลบ ${item['group_name']} แล้ว")),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("เกิดข้อผิดพลาดในการลบ โปรดลองอีกครั้ง"),
                                    ),
                                  );
                                }
                                Navigator.pop(context);
                              },
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF44336),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromRGBO(244, 67, 54, 0.35),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 8,
                                ),
                                child: const Text(
                                  "ลบ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}