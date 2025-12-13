import 'package:flutter/material.dart';
import 'dart:async';

/// ลดความสว่างของสี (darken) เช่น darken(Color.blue, 0.2)
Color darken(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return hslDark.toColor();
}

/// เพิ่มความสว่างของสี (lighten)
Color lighten(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
  return hslLight.toColor();
}

bool isColorLight(Color color) {
  // ความสว่างของสีจากค่า RGB
  final double luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;

  return luminance > 0.5; // มากกว่า 0.5 = อ่อน , น้อย = เข้ม
}

int safeParse(dynamic v) {
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

Color hexToColor(String hex) {
  hex = hex.replaceAll('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  return Color(int.parse(hex, radix: 16));
}

class ClockService {
  final ValueNotifier<DateTime> currentTime = ValueNotifier(DateTime.now());
  Timer? _timer;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      currentTime.value = DateTime.now(); // ✅ ใช้ ValueNotifier
    });
  }

  void stop() {
    _timer?.cancel();
  }

  // ฟังก์ชันจัดรูปแบบเวลา
  String formattedTime(DateTime now) {
    int hour = now.hour;
    int minute = now.minute;
    int second = now.second;
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}";
  }

  // ฟังก์ชันจัดรูปแบบวันที่
  String formattedDate(DateTime now) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    String dayOfWeek = days[now.weekday % 7];
    String month = months[now.month - 1];
    return "$dayOfWeek, ${now.day} $month ${now.year}";
  }
}
