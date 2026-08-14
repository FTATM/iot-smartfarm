import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/appbar.dart';
import 'package:iot_app/components/session.dart';
import 'package:iot_app/components/chat-box.dart';

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  // ============================================================
  // Variables
  // ============================================================

  bool isLoading = true;

  // เก็บ Widget ของ Chat
  List<Widget> chatlist = [];

  Map<String, dynamic> user = {};
  Map<String, dynamic> AIping = {};

  String AIModel = '';

  // TextField Controller
  final TextEditingController _messageController = TextEditingController();

  // ============================================================
  // Init
  // ============================================================

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  // ============================================================
  // Dispose
  // ============================================================

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // ============================================================
  // Prepare Data
  // ============================================================

  Future<void> _prepareData() async {
    try {
      await _fetchAIMode();
      await _fetchAIPing();

      // เตรียมข้อความเริ่มต้น
      _initChat();

      if (!mounted) return;

      setState(() {
        user = CurrentUser;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Prepare AI Data Error: $e");

      if (!mounted) return;

      setState(() {
        user = CurrentUser;
        isLoading = false;
      });
    }
  }

  // ============================================================
  // Fetch AI Model
  // ============================================================

  Future<void> _fetchAIMode() async {
    final response = await ApiService.fetchAIInfo();

    if (!mounted) return;

    setState(() {
      AIModel = response['data']['AI_MODE'] == '1'
          ? response['data']['AI_EXTERNAL_MODEL']
          : response['data']['AI_MODEL'];
    });
  }

  // ============================================================
  // Fetch AI Ping
  // ============================================================

  Future<void> _fetchAIPing() async {
    final response = await ApiService.fetchAIPing();

    if (!mounted) return;

    setState(() {
      AIping = response;
    });

    print(AIping);
  }

  // ============================================================
  // Init Chat
  // ============================================================

  void _initChat() {
    // ถ้า AI เชื่อมต่อไม่ได้ ไม่ต้องเพิ่มข้อความ
    if (AIping['status'] != 'ok') {
      return;
    }

    const ai = CreateBoxAI("สวัสดี มีอะไรให้ช่วยไหม?");

    if (!mounted) return;

    setState(() {
      chatlist.add(ai);
    });
  }

  // ============================================================
  // Send Message
  // ============================================================

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    if (AIping['status'] != 'ok') {
      return;
    }

    // --------------------------------
    // แสดงข้อความ User ก่อน
    // --------------------------------

    setState(() {
      chatlist.add(CreateBoxUser(message));
    });

    _messageController.clear();

    // --------------------------------
    // ส่งไป API
    // --------------------------------

    final response = await ApiService.sendAIMessage(message);

    if (!mounted) return;

    // --------------------------------
    // AI Response
    // --------------------------------

    if (response['success'] == true) {
      final aiMessage = response['answer'];

      setState(() {
        chatlist.add(CreateBoxAI(aiMessage.toString()));
      });
    } else {
      setState(() {
        chatlist.add(CreateBoxAI("เกิดข้อผิดพลาด: ${response['message'] ?? 'ไม่สามารถเชื่อมต่อ AI ได้'}"));
      });
    }
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // Loading
    // ==========================================================

    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),

        appBar: AppbarWidget(txtt: "Ai Assistant", icon: Icons.auto_awesome),

        body: Column(
          children: [
            // --------------------------------------------------
            // AI Status
            // --------------------------------------------------
            Container(
              width: double.infinity,
              height: 25,
              color: Colors.grey[100],

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  Text("Model : $AIModel", textAlign: TextAlign.center),

                  const Text("Connecting"),

                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(color: Color(0xFFF97316), strokeWidth: 2),
                  ),
                ],
              ),
            ),

            // --------------------------------------------------
            // Loading Area
            // --------------------------------------------------
            const Expanded(
              child: Center(child: CircularProgressIndicator(color: Color(0xFFF97316))),
            ),
          ],
        ),
      );
    }

    // ==========================================================
    // Main Page
    // ==========================================================

    final bool isConnected = AIping['status'] == 'ok';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppbarWidget(txtt: "Ai Assistant", icon: Icons.auto_awesome),

      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // AI Status Bar
            // ==================================================
            Container(
              width: double.infinity,
              height: 25,
              color: Colors.grey[100],

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  Text("Model : $AIModel", textAlign: TextAlign.center),

                  Text(isConnected ? "Connected" : "Failed"),

                  Icon(
                    isConnected ? Icons.check_circle : Icons.cancel,

                    color: isConnected ? Colors.green : Colors.red,

                    size: 16,
                  ),
                ],
              ),
            ),

            // ==================================================
            // Chat Area
            // ==================================================
            Expanded(
              child: Column(
                children: [
                  // ============================================
                  // Chat Messages
                  // ============================================
                  Expanded(
                    child: chatlist.isEmpty
                        ? Center(
                            child: Text(
                              isConnected ? "Start a conversation" : "AI is not connected",
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),

                            itemCount: chatlist.length,

                            itemBuilder: (context, index) {
                              return chatlist[index];
                            },
                          ),
                  ),

                  // ============================================
                  // Message Input
                  // ============================================
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,

                      children: [
                        // --------------------------------------
                        // Text Field
                        // --------------------------------------
                        Expanded(
                          child: TextField(
                            controller: _messageController,

                            enabled: isConnected,

                            minLines: 1,
                            maxLines: 4,

                            textInputAction: TextInputAction.newline,

                            decoration: InputDecoration(
                              hintText: isConnected ? "Message AI..." : "AI is not connected",

                              filled: true,

                              fillColor: Colors.white,

                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),

                                borderSide: BorderSide.none,
                              ),
                            ),

                            onSubmitted: (_) {
                              _sendMessage();
                            },
                          ),
                        ),

                        const SizedBox(width: 8),

                        // --------------------------------------
                        // Send Button
                        // --------------------------------------
                        SizedBox(
                          width: 45,
                          height: 45,

                          child: IconButton(
                            onPressed: isConnected ? _sendMessage : null,

                            icon: const Icon(Icons.send, color: Colors.white, size: 20),

                            style: IconButton.styleFrom(
                              backgroundColor: isConnected ? const Color(0xFFF97316) : Colors.grey,

                              disabledBackgroundColor: Colors.grey[300],

                              shape: const CircleBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
