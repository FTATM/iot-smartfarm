import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/Colors.dart';
import 'package:iot_app/components/appbar.dart';
import 'package:iot_app/pages/Farm/ai-selecteddevices.dart';

class AiManagementPage extends StatefulWidget {
  const AiManagementPage({super.key});

  @override
  State<AiManagementPage> createState() => _AiManagementPageState();
}

class _AiManagementPageState extends State<AiManagementPage> {
  late bool toggle_AIMODE = false;
  bool isLoading = true;
  String startedAt = '2000-01-01 00:00:00';
  String updatedAt = '2000-01-01 00:00:00';

  Map<String, dynamic> statusAI = {};
  List<Map<String, dynamic>> logs = [];

  bool isActive = false;

  @override
  void initState() {
    super.initState();
    prepare();
  }

  Future<void> prepare() async {
    var res = await ApiService.fetchCheckscriptAI();

    var rawlog = await ApiService.fetchAILog();

    if (!mounted) {
      return;
    }

    setState(() {
      statusAI = res['runtime_ai']['status'];
      startedAt = statusAI['started_at'];
      updatedAt = statusAI['updated_at'];
      toggle_AIMODE = statusAI['running'];
      isActive = statusAI['running'];
      logs = rawlog['data'];
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
      appBar: AppbarWidget(txtt: "AI Management", icon: Icons.psychology),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Card 1 infomation Ai script
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            spacing: 10,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                child: Icon(Icons.terminal, color: Colors.white),
                              ),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("AI Script", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  Text('Status: Running'),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text("AI MODE", style: TextStyle(fontSize: 12)),
                              SizedBox(
                                height: 40,
                                child: Switch(
                                  splashRadius: 10,
                                  value: toggle_AIMODE,
                                  activeThumbColor: primaryColor,
                                  inactiveThumbColor: Colors.white,
                                  inactiveTrackColor: Colors.grey[600],
                                  trackOutlineWidth: WidgetStatePropertyAll(0),
                                  onChanged: (value) {
                                    setState(() {
                                      toggle_AIMODE = !toggle_AIMODE;
                                    });
                                    print("AIMODE : $toggle_AIMODE");
                                  },
                                ),
                              ),
                              Text(toggle_AIMODE ? "EXTERNAL AI" : "Local AI", style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Started At"),
                          Text(startedAt, style: TextStyle(backgroundColor: Colors.grey[200])),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Updated At"),
                          Text(updatedAt, style: TextStyle(backgroundColor: Colors.grey[200])),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        spacing: 10,
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  isActive = !isActive;
                                });
                              },
                              style: ButtonStyle(
                                backgroundColor: isActive
                                    ? WidgetStatePropertyAll(Colors.redAccent)
                                    : WidgetStatePropertyAll(primaryColor),
                              ),
                              child: Text(
                                "${isActive ? "Stop" : "Start"} Script",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.grey[200])),
                              onPressed: () {},
                              child: Text("Reset History", style: TextStyle(color: Colors.black)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Devices Selecter Menu
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AiSelectedDevicesPage()));
                    // print("ไปหน้าเลือก อุปกรณ์");
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            spacing: 10,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                child: const Icon(Icons.sensors, color: Colors.white),
                              ),
                              const Text(
                                'Selected Devices',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 28),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const double rowHeight = 35;
                    const double headerHeight = 80;
                    const double dividerHeight = 1;
                    const double paddingHeight = 16;

                    final availableHeight = constraints.maxHeight - headerHeight - dividerHeight - paddingHeight;

                    final maxRows = (availableHeight / rowHeight).floor();

                    final displayLogs = logs.take(maxRows).toList();

                    print("${availableHeight/rowHeight} $maxRows = $availableHeight / $rowHeight");

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: paddingHeight, vertical: paddingHeight),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: headerHeight - (paddingHeight * 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Recent AI Logs", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  Text("more"),
                                ],
                              ),
                            ),

                            const Divider(height: dividerHeight),

                            Expanded(
                              child: displayLogs.isEmpty
                                  ? const Center(
                                      child: Text("No AI logs", style: TextStyle(color: Colors.grey)),
                                    )
                                  : ListView.builder(
                                      itemCount: displayLogs.length,
                                      itemBuilder: (context, index) {
                                        final log = displayLogs[index];
                                        final isSuccess = log['is_success']?.toString() == '1';

                                        return SizedBox(
                                          height: rowHeight,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(log['created_at']?.toString().split('.').first ?? '-',),

                                              Text(
                                                isSuccess ? 'SUCCESS' : 'FAILED',
                                                style: TextStyle(
                                                  color: isSuccess ? Colors.green : Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
