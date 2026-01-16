import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ConnectedIcon extends StatelessWidget {
  final double size;
  final Color color;

  const ConnectedIcon({
    super.key,
    this.size = 24,
    this.color = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ConnectedIconPainter(color),
    );
  }
}

class _ConnectedIconPainter extends CustomPainter {
  final Color color;

  _ConnectedIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw circle
    canvas.drawCircle(center, radius, paint);

    // Draw wifi/connection paths
    final pathPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path1 = Path();
    // Bottom left connection symbol
    path1.moveTo(size.width * 0.30, size.height * 0.70);
    path1.lineTo(size.width * 0.22, size.height * 0.78);
    path1.lineTo(size.width * 0.38, size.height * 0.78);
    path1.lineTo(size.width * 0.45, size.height * 0.70);
    path1.close();

    // Top right connection symbol
    final path2 = Path();
    path2.moveTo(size.width * 0.70, size.height * 0.30);
    path2.lineTo(size.width * 0.78, size.height * 0.22);
    path2.lineTo(size.width * 0.62, size.height * 0.22);
    path2.lineTo(size.width * 0.55, size.height * 0.30);
    path2.close();

    canvas.drawPath(path1, pathPaint);
    canvas.drawPath(path2, pathPaint);

    // Draw connecting lines
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width * 0.08
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.42, size.height * 0.42),
      Offset(size.width * 0.58, size.height * 0.58),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DisconnectedIcon extends StatelessWidget {
  final double size;
  final Color color;

  const DisconnectedIcon({
    super.key,
    this.size = 24,
    this.color = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DisconnectedIconPainter(color),
    );
  }
}

class _DisconnectedIconPainter extends CustomPainter {
  final Color color;

  _DisconnectedIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw circle
    canvas.drawCircle(center, radius, paint);

    // Draw disconnected wifi/connection paths with slash
    final pathPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path1 = Path();
    // Bottom left connection symbol
    path1.moveTo(size.width * 0.30, size.height * 0.70);
    path1.lineTo(size.width * 0.22, size.height * 0.78);
    path1.lineTo(size.width * 0.38, size.height * 0.78);
    path1.lineTo(size.width * 0.45, size.height * 0.70);
    path1.close();

    // Top right connection symbol
    final path2 = Path();
    path2.moveTo(size.width * 0.70, size.height * 0.30);
    path2.lineTo(size.width * 0.78, size.height * 0.22);
    path2.lineTo(size.width * 0.62, size.height * 0.22);
    path2.lineTo(size.width * 0.55, size.height * 0.30);
    path2.close();

    canvas.drawPath(path1, pathPaint);
    canvas.drawPath(path2, pathPaint);

    // Draw diagonal slash line
    final slashPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width * 0.1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.75),
      Offset(size.width * 0.75, size.height * 0.25),
      slashPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
  final List<String> cameraRooms = ['Camera1'];

  /// room -> image bytes
  final Map<String, Uint8List> _frames = {};

  List<dynamic> _datatemp = [];

  /// room ที่กำลังดู
  String? selectedRoom;

  final String wsUrl = 'ws://192.168.1.124:8765'; // 🔥 เปลี่ยนเป็น IP server

  // =========================
  // SOCKET CONNECT
  // =========================
  void _connectSocket() {
    debugPrint('🔌 Connecting WebSocket...');
    _socket = WebSocketChannel.connect(Uri.parse(wsUrl));

    _socketSub = _socket!.stream.listen(
      _onMessage,
      onDone: () {
            debugPrint('🔌 Connected WebSocket');
      },
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
        isConnected = true; // Update connection status when receiving data
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
        debugPrint('🔌 Connecting WebSocket...');
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
    
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'ไลฟ์',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LIVE VIDEO CONTAINER
                    Container(
                      width: double.infinity,
                      height: maxwidth * 0.55,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB0B0B0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          // VIDEO FEED
                          selectedRoom == null || !_frames.containsKey(selectedRoom)
                              ? Center(
                                  child: Text(
                                    'กำลังรอสัญญาณ...',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.memory(
                                    _frames[selectedRoom]!,
                                    fit: BoxFit.cover,
                                    gaplessPlayback: true,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                          
                          // STATUS INDICATOR (TOP LEFT)
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isConnected 
                                    ? const Color(0xFF2D5F3F)
                                    : const Color(0xFF5A5A5A),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: isConnected ? Colors.green : Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isConnected ? 'ออนไลน์' : 'ออฟไลน์',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // CONNECTION STATUS
                    Row(
                      children: [
                        Icon(
                          isConnected ? Icons.check_circle : Icons.cancel,
                          color: isConnected ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isConnected ? 'เชื่อมต่อแล้ว' : 'ตัดการเชื่อมต่อ',
                          style: TextStyle(
                            color: isConnected ? Colors.green : Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // CAMERA SELECTOR
                    InkWell(
  onTap: () {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  Text(
                    'เลือกกล้อง',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey.shade600),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Camera list with icons
            ...cameraRooms.asMap().entries.map((entry) {
              // final index = entry.key;
              final room = entry.value;
              final isSelected = selectedRoom == room;
              
              // กำหนดไอคอนตามชื่อกล้อง
              IconData cameraIcon;
              if (room.toLowerCase().contains('living')) {
                cameraIcon = Icons.videocam;
              } else if (room.toLowerCase().contains('door') || room.toLowerCase().contains('front')) {
                cameraIcon = Icons.security;
              } else if (room.toLowerCase().contains('garage')) {
                cameraIcon = Icons.garage;
              } else {
                cameraIcon = Icons.camera_alt;
              }

              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        selectedRoom = room;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(0xFFFFF3E8) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? Color(0xFFFF9944) : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Camera icon
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? Color(0xFFFF9944) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              cameraIcon,
                              color: isSelected ? Colors.white : Colors.grey.shade700,
                              size: 24,
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Camera name
                          Expanded(
                            child: Text(
                              room,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected ? Color(0xFFFF9944) : Colors.black87,
                              ),
                            ),
                          ),
                          
                          // Check icon
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Color(0xFFFF9944),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  },
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          selectedRoom ?? 'เลือกกล้อง',
          style: TextStyle(
            color: selectedRoom == null ? Colors.grey : Colors.black,
            fontSize: 16,
          ),
        ),
        Icon(Icons.arrow_drop_down, color: Colors.grey),
      ],
    ),
  ),
),

                    const SizedBox(height: 20),

                    // TEMPERATURE DATA SECTION
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9944),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // HEADER
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.thermostat,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'อุณหภูมิจากกล้อง',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'เรียลไทม์',
                                    style: TextStyle(
                                      color: Color(0xFFFF9944),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // TABLE
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                            child: Column(
                              children: [
                                // TABLE HEADER
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Center(
                                          child: Text(
                                            'ชื่อ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Center(
                                          child: Text(
                                            'ตำแหน่ง',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Center(
                                          child: Text(
                                            'อุณหภูมิ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // TABLE ROWS
                                ..._datatemp.reversed.take(10).map((item) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade200,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Center(
                                            child: Text(
                                              item['class'] ?? '',
                                              style: TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Center(
                                            child: Text(
                                              item['bbox']?.toString() ?? '',
                                              style: TextStyle(fontSize: 13),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Center(
                                            child: Text(
                                              "${item['max_temp']?.toStringAsFixed(2) ?? ''} °C",
                                              style: TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),

                                if (_datatemp.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Text(
                                      'ไม่มีข้อมูล',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
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
            ),
          ),
        ],
      ),
    );
  }
}