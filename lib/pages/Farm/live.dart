import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LivePage extends StatefulWidget {
  const LivePage({super.key});

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  WebSocketChannel? _socket;
  Timer? _reconnectTimer;
  StreamSubscription? _socketSub;

  bool isConnected = false;

  /// กล้องทั้งหมด (room ต้องตรงกับ Python)
  final List<String> cameraRooms = ['Camera1', 'Camera2', 'Camera3'];

  /// room -> image bytes
  final Map<String, Uint8List> _frames = {};

  List<dynamic> _datatemp = [];

  /// room ที่กำลังดู
  String? selectedRoom;

  final String wsUrl = 'ws://192.168.1.179:8765'; // 🔥 เปลี่ยนเป็น IP server

  // =========================
  // SOCKET CONNECT
  // =========================
  void _connectSocket() {
    debugPrint('🔌 Connecting WebSocket...');
    _socket = WebSocketChannel.connect(Uri.parse(wsUrl));

    _socketSub = _socket!.stream.listen(
      _onMessage,
      // onDone: _onDisconnected,
      onError: (e) {
        debugPrint('❌ WS error: $e');
        _onDisconnected();
      },
    );
  }

  // =========================
  // MESSAGE HANDLER
  // =========================
  void _onMessage(dynamic message) {
    if (!mounted) return;

    final data = jsonDecode(message);

    if (data['type'] == 'image') {
      final room = data['room'];
      final bytes = base64Decode(data['data']);
      final datatemp = data['crops'];

      setState(() {
        _frames[room] = bytes;
        if (_datatemp.length >= 20) {
          _datatemp.removeAt(0);
        }
        _datatemp.addAll(datatemp);
      });
    }
  }

  // =========================
  // DISCONNECTED
  // =========================
  void _onDisconnected() {
    debugPrint('🔴 WebSocket disconnected');
    isConnected = false;
    _socket = null;

    _startAutoReconnect();
  }

  // =========================
  // AUTO RECONNECT
  // =========================
  void _startAutoReconnect() {
    if (_reconnectTimer != null) {
      _reconnectTimer?.cancel();
    }

    _reconnectTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      if (_socket == null) {
        debugPrint('🔄 Reconnecting...');
        _connectSocket();

        /// join ห้องทั้งหมดที่เคยดู
        for (final room in cameraRooms) {
          _joinRoom(room);
        }
      }
    });
  }

  // =========================
  // JOIN ROOM
  // =========================
  void _joinRoom(String room) {
    if (_socket == null) {
      _connectSocket();
      return;
    }

    _socket!.sink.add(jsonEncode({'type': 'joinroom', 'data': room}));

    debugPrint('📡 Joined room $room');
  }

  // =========================
  // INIT
  // =========================
  @override
  void initState() {
    super.initState();
    _connectSocket();

    /// join ทุกกล้อง (รองรับหลายกล้องพร้อมกัน)
    for (final room in cameraRooms) {
      _joinRoom(room);
    }
  }

  // =========================
  // DISPOSE
  // =========================
  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _socket?.sink.close();
    _socketSub?.cancel();
    _socket = null;
    super.dispose();
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    final maxwidth = MediaQuery.of(context).size.width;
    final maxheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(backgroundColor: Colors.white, title: const Text('Live Camera')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          spacing: 12,
          children: [
            /// LIVE VIEW
            Container(
              width: maxwidth,
              height: maxwidth * 0.5,
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
              child: selectedRoom == null || !_frames.containsKey(selectedRoom)
                  ? const Center(
                      child: Text('Waiting for signal...', style: TextStyle(color: Colors.white70)),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(_frames[selectedRoom]!, fit: BoxFit.cover, gaplessPlayback: true),
                    ),
            ),

            /// STATUS
            Row(
              children: [
                Icon(Icons.circle, size: 12, color: isConnected ? Colors.green : Colors.red),
                const SizedBox(width: 8),
                Text(isConnected ? 'Connected' : 'Disconnected', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),

            /// SELECT CAMERA
            DropdownButton<String>(
              hint: const Text('Select Camera here.'),
              value: selectedRoom,
              isExpanded: true,
              items: cameraRooms.map((room) {
                return DropdownMenuItem(value: room, child: Text(room));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRoom = value;
                });
              },
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
                  columnWidths: const {0: FlexColumnWidth(1.5), 1: FlexColumnWidth(2), 2: FlexColumnWidth(2)},
                  children: [
                    TableRow(children: [Text("Name"), Text("Position"), Text("Tempureture")]),
                    ..._datatemp.reversed.map((item) {
                      return TableRow(
                        children: [
                          SizedBox(width: maxwidth * 0.2, height: 40, child: Text(item['class'])),
                          SizedBox(width: maxwidth * 0.3, height: 40, child: Text(item['bbox'].toString())),
                          SizedBox(
                            width: maxwidth * 0.2,
                            height: 40,
                            child: Text("${item['max_temp'].toStringAsFixed(2)} °C"),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
