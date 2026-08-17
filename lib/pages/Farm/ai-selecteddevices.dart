import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/Colors.dart';
import 'package:iot_app/components/appbar.dart';

class AiSelectedDevicesPage extends StatefulWidget {
  const AiSelectedDevicesPage({super.key});

  @override
  State<AiSelectedDevicesPage> createState() => _AiSelectedDevicesPageState();
}

class _AiSelectedDevicesPageState extends State<AiSelectedDevicesPage> {
  late bool toggle_AIMODE = false;
  bool isLoading = true;
  List<Map<String, dynamic>> devices = [];

  @override
  void initState() {
    super.initState();
    prepare();
  }

  Future<void> prepare() async {
    var res = await ApiService.fetchAIConfigDevices();

    var raw = formatDevices(res['data']);

    setState(() {
      devices = raw;
      isLoading = false;
    });
  }

  List<Map<String, dynamic>> formatDevices(List<dynamic> devices) {
    return devices.map<Map<String, dynamic>>((d) {
      return {
        "id": d['monitor_id'],
        "name": d['monitor_name'],
        "group_id": d['group_id'],
        "type_id": d['type_id'],
        "ai_allow": d['ai_allow'],
        "desc": d['description'],
      };
    }).toList();
  }

  Future<void> updateDevicesAI() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    var res = await ApiService.updateDevicesAI(devices);
    print(res);

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppbarWidget(txtt: "AI Device selection", icon: Icons.sensors),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...devices.map(
                        (d) => Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Checkbox
                              Checkbox(
                                value: d['ai_allow'] == '1',
                                activeColor: primaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    d['ai_allow'] = value == true ? '1' : '0';
                                  });
                                },
                              ),

                              const SizedBox(width: 4),

                              // Device information
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Device name
                                    Text(
                                      d['name'].toString(),
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                    ),

                                    const SizedBox(height: 3),

                                    // Device detail
                                    Text('${d['desc']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Data type
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.grey.shade200,
                                ),
                                child: Column(
                                  children: [
                                    Text('ID: ${d['id']}', style: const TextStyle(fontSize: 11)),
                                    Text(
                                      d['type_id'] == '1'
                                          ? "Analog"
                                          : d['type_id'] == '2'
                                          ? "Analog"
                                          : d['type_id'] == '3'
                                          ? "Digital"
                                          : "Digital",
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: TextButton(
                  style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(primaryColor)),
                  onPressed: () => updateDevicesAI(),
                  child: Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_alt, size: 18, color: Colors.white),
                      Text(
                        "Update",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
