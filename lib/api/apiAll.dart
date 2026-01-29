import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:iot_app/components/session.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ApiService {
  // 🔹 ใส่ URL ของ PHP API ที่คุณสร้างไว้
  static String baseUrl = CurrentUser['baseURL'];

  // ฟังก์ชันตรวจสอบการเข้าสู่ระบบ
  static Future<Map<String, dynamic>> checkLogin(String username, String password, String baseURL) async {
    try {
      final response = await http.post(
        Uri.parse("${baseURL}check-login.php"),
        body: {'username': username, 'password': password},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // ฟังก์ชันตรวจสอบผู้ใช้
  static Future<Map<String, dynamic>> checkUser(Map<String, dynamic> item) async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}check-user.php"),
        body: {'id': item['id'], 'username': item['username'], 'password': item['password']},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // fetch Data Weathers
  static Future<Map<String, dynamic>> fetchDataWeathers() async {
    try {
      final response = await http.post(Uri.parse("${baseUrl}fetch-data_weathers.php"));

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // update hardresetpasswordById
  static Future<Map<String, dynamic>> updateHardResetPasswordById(Map<String, dynamic> list) async {
    try {
      // print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}update-password_admin.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // fetch Dashboard
  static Future<Map<String, dynamic>> fetchDashboardBybranchId(String bid) async {
    try {
      final response = await http.post(Uri.parse("${baseUrl}fetch-dashboard.php"), body: {'bid': bid});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // fetch HomeBranch
  static Future<Map<String, dynamic>> fetchHomeBranch(String bid) async {
    try {
      final response = await http.post(Uri.parse("${baseUrl}fetch-homebranch.php"), body: {'bid': bid});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // fetch dashboard sub
  static Future<Map<String, dynamic>> fetchDashboardSub() async {
    try {
      final response = await http.post(Uri.parse("${baseUrl}fetch-dashboard_sub.php"));

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  //fetch MainBoard
  static Future<Map<String, dynamic>> fetchMainboard() async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}fetch-mainboard.php"),
        //  body: {'bid': bid}
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // fetch Configs
  static Future<Map<String, dynamic>> fetchConfigBybranchId(String bid) async {
    try {
      final response = await http.post(Uri.parse("${baseUrl}fetch-config.php"), body: {'bid': bid});

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // fetch Groups
  static Future<Map<String, dynamic>> fetchGroupsBybranchId(String bid) async {
    try {
      final response = await http.post(Uri.parse("${baseUrl}fetch-group.php"), body: {'bid': bid});

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  //fetch Device
  static Future<Map<String, dynamic>> fetchDevicesBybranchId(String bid) async {
    try {
      final response = await http.post(Uri.parse("${baseUrl}fetch-device.php"), body: {'bid': bid});

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // fetch types
  static Future<Map<String, dynamic>> fetchTypesBybranchId() async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}fetch-types.php"),
        //  body: {'bid': bid}
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // fetch Datax
  static Future<Map<String, dynamic>> fetchDataxBybranchId(String bid) async {
    try {
      final response = await http.post(Uri.parse("${baseUrl}fetch-datax.php"), body: {'bid': bid});

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // fetch types Dashboard
  static Future<Map<String, dynamic>> fetchDashboardType() async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}fetch-typesDashboard.php"),
        //  body: {'bid': bid}
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // fetch Icons
  static Future<Map<String, dynamic>> fetchIcons() async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}fetch-icons.php"),
        //  body: {'bid': bid}
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // update monitor
  static Future<Map<String, dynamic>> updateMonitorById(Map<String, dynamic> list) async {
    try {
      print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}update-monitor.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // Create monitor
  static Future<Map<String, dynamic>> createMonitorById(Map<String, dynamic> list) async {
    try {
      print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}create-monitor.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // Update dashboard
  static Future<Map<String, dynamic>> updateDashboardById(Map<String, dynamic> list) async {
    try {
      // print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}update-dashboard.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      if (response.statusCode == 200) {
        // print(response.body);  //ดู error sql
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // insert icons
  static Future<bool> uploadIconFile(String name, Uint8List bytes) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse("${baseUrl}create-icon.php"));

      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: name));

      var response = await request.send();

      // แปลง StreamedResponse เป็น String
      var responseBody = await response.stream.bytesToString();

      print("Status code: ${response.statusCode}");
      print("Body: $responseBody");
      return response.statusCode == 200;
    } catch (e) {
      print("Upload error: $e");
      return false;
    }
  }

  // Delete icons
  static Future<Map<String, dynamic>> deleteIconById(Map<String, dynamic> list) async {
    try {
      print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}delete-icon.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      if (response.statusCode == 200) {
        // print(response.body);  //ดู error sql
        final data = json.decode(response.body);

        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // Update mainboard
  static Future<Map<String, dynamic>> updateMainboardById(Map<String, dynamic> list) async {
    try {
      print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}update-mainboard.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // Create Dashboard
  static Future<Map<String, dynamic>> createDashboard(Map<String, dynamic> list) async {
    try {
      print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}create-dashboard.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // print(response.body);
      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // Create Dashboard
  static Future<Map<String, dynamic>> createSubDashboard(Map<String, dynamic> list) async {
    try {
      print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}create-sub-dashboard.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // print(response.body);
      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // update SubDashboard
  static Future<Map<String, dynamic>> updateSubDashboardById(Map<String, dynamic> list) async {
    try {
      print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}update-dashboard_sub.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // update SubDashboard
  static Future<Map<String, dynamic>> deleteSubDashboardById(Map<String, dynamic> list) async {
    try {
      print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}delete-sub_dashboard.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // Delete Dashboard
  static Future<Map<String, dynamic>> deleteDashboardById(Map<String, dynamic> list) async {
    try {
      print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}delete-dashboard.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      if (response.statusCode == 200) {
        // print(response.body);  //ดู error sql
        final data = json.decode(response.body);

        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  //fetch branch
  static Future<Map<String, dynamic>> fetchBranchAll() async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}fetch-branch.php"),
        //  body: {'bid': bid}
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // update branch
  static Future<Map<String, dynamic>> updateBranchById(Map<String, dynamic> list) async {
    try {
      print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}update-branch.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // update branch
  static Future<Map<String, dynamic>> deleteBranchById(Map<String, dynamic> list) async {
    try {
      print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}delete-branch.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // create branch
  static Future<Map<String, dynamic>> createBranch(Map<String, dynamic> list) async {
    try {
      print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}create-branch.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  //fetch groups
  static Future<Map<String, dynamic>> fetchGroupAll() async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}fetch-groups.php"),
        //  body: {'bid': bid}
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // update groups
  static Future<Map<String, dynamic>> updateGroupById(Map<String, dynamic> list) async {
    try {
      print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}update-group.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // update groups
  static Future<Map<String, dynamic>> deleteGroupById(Map<String, dynamic> list) async {
    try {
      print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}delete-group.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // create groups
  static Future<Map<String, dynamic>> createGroup(Map<String, dynamic> list) async {
    try {
      print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}create-group.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // fetch devices
  static Future<Map<String, dynamic>> fetchDeviceAll() async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}fetch-devices.php"),
        //  body: {'bid': bid}
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // update devices
  static Future<Map<String, dynamic>> updateDeviceById(Map<String, dynamic> list) async {
    try {
      print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}update-device.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // update devices
  static Future<Map<String, dynamic>> deleteDeviceById(Map<String, dynamic> list) async {
    try {
      print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}delete-device.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // create devices
  static Future<Map<String, dynamic>> createDevice(Map<String, dynamic> list) async {
    try {
      print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}create-device.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // fetch datax
  static Future<Map<String, dynamic>> fetchDataxAll() async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}fetch-dataxs.php"),
        //  body: {'bid': bid}
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // update datax
  static Future<Map<String, dynamic>> updateDataxById(Map<String, dynamic> list) async {
    try {
      print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}update-datax.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // update datax
  static Future<Map<String, dynamic>> deleteDataxById(Map<String, dynamic> list) async {
    try {
      print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}delete-datax.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // create datax
  static Future<Map<String, dynamic>> createDatax(Map<String, dynamic> list) async {
    try {
      print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}create-datax.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // fetch users
  static Future<Map<String, dynamic>> fetchUsersAll() async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}fetch-users.php"),
        //  headers: {'Content-Type': 'application/json'},
        // body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // fetch roles
  static Future<Map<String, dynamic>> fetchRolesAll() async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}fetch-roles.php"),
        //  headers: {'Content-Type': 'application/json'},
        // body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // update account
  static Future<Map<String, dynamic>> updateAccountById(Map<String, dynamic> list) async {
    try {
      print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}update-user_account.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // create User account
  static Future<Map<String, dynamic>> createUserAccount(Map<String, dynamic> list) async {
    try {
      print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}create-user_account.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // fetch PDFs
  static Future<Map<String, dynamic>> fetchPDFsById(String id) async {
    try {
      final response = await http.post(Uri.parse("${baseUrl}fetch-pdfs.php"), body: {'bid': id});

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // fetch pdf file
  static Future<File> loadPdfFromServer(String fileId, String bid) async {
    final url = Uri.parse('${baseUrl}get-pdf_view.php?id=$fileId&bid=$bid');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load PDF');
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/temp_$fileId.pdf');

    // ✅ ต้องใช้ bodyBytes เท่านั้น
    await file.writeAsBytes(response.bodyBytes, flush: true);

    return file;
  }

  // insert icons
  static Future<bool> uploadpdfFile(String name, String bid, Uint8List bytes) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse("${baseUrl}create-pdf.php"));

      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: name));
      request.fields['bid'] = bid;

      var response = await request.send();

      // แปลง StreamedResponse เป็น String
      var responseBody = await response.stream.bytesToString();

      print("Status code: ${response.statusCode}");
      print("Body: $responseBody");
      return response.statusCode == 200;
    } catch (e) {
      print("Upload error: $e");
      return false;
    }
  }

  // fetch Table Knowledge
  static Future<Map<String, dynamic>> fetchTablesknowledgeById(String id) async {
    try {
      final response = await http.post(Uri.parse("${baseUrl}fetch-tableknowledge.php"), body: {'bid': id});

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // update groups
  static Future<Map<String, dynamic>> updateScheduleAll(List<dynamic> list) async {
    try {
      // print(jsonEncode(list));
      final response = await http.post(Uri.parse("${baseUrl}update-schedule.php"), body: {'json': jsonEncode(list)});

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // delete column
  static Future<Map<String, dynamic>> deleteColumnById(Map<String, dynamic> list) async {
    try {
      // print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}delete-column.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // delete Row
  static Future<Map<String, dynamic>> deleteRowById(Map<String, dynamic> list) async {
    try {
      // print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}delete-row.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // delete Table
  static Future<Map<String, dynamic>> deleteTableById(Map<String, dynamic> list) async {
    try {
      // print(jsonEncode(list));
      final response = await http.post(
        Uri.parse("${baseUrl}delete-table.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // fetch Data Weathers
  static Future<Map<String, dynamic>> fetchWeathers() async {
    try {
      final response = await http.post(Uri.parse("${baseUrl}fetch-weathers.php"));

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // update Weathers
  static Future<Map<String, dynamic>> updateWeather(Map<String, dynamic> list) async {
    try {
      final response = await http.post(Uri.parse("${baseUrl}update-weathers.php"), body: {'json': jsonEncode(list)});

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // fetch Logo
  static Future<Map<String, dynamic>> fetchLogos() async {
    try {
      final response = await http.post(Uri.parse("${baseUrl}fetch-logos.php"));

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // insert icons
  static Future<bool> createLogo(String name, Uint8List bytes) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse("${baseUrl}create-logo.php"));

      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: name));

      var response = await request.send();

      // แปลง StreamedResponse เป็น String
      var responseBody = await response.stream.bytesToString();

      // print("Status code: ${response.statusCode}");
      print("Body: $responseBody");
      return response.statusCode == 200;
    } catch (e) {
      print("Upload error: $e");
      return false;
    }
  }

  // Delete icons
  static Future<Map<String, dynamic>> deleteLogoById(Map<String, dynamic> list) async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}delete-logo.php"),
        //  headers: {'Content-Type': 'application/json'},
        body: {'json': jsonEncode(list)},
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      if (response.statusCode == 200) {
        // print(response.body);  //ดู error sql
        final data = json.decode(response.body);

        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

  // Post Sensor
  static Future<Map<String, dynamic>> updateSensorById(Map<String, dynamic> list) async {
    try {
      // ✅ สร้าง JSON body ตามที่ API ต้องการ
      final bodyData = {
        "group_id": list["m_group_id"].toString(),
        "device_id": list["m_device_id"].toString(),
        "type_id": list["m_type_id"].toString(),
        "datax_id": list["m_datax_id"].toString(),
        "data_value": double.parse(list["m_value"].toString()),
      };
      final url = Uri.parse("http://${CurrentUser['IP']}/iotsf/api_push_data_by_hardware_process.php");

      final response = await http.post(
        url,
        body: jsonEncode(bodyData),
      );

      // 🔹 ตรวจสอบว่า HTTP status เป็น 200 หรือไม่
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🔹 ส่งผลลัพธ์กลับให้ login.dart ใช้งาน
        return data;
      } else {
        return {"status": "error", "message": "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${response.statusCode})"};
      }
    } catch (e) {
      // 🔹 จัดการกรณีเชื่อมต่อ API ไม่ได้ เช่น ไม่มีอินเทอร์เน็ต
      return {"status": "error", "message": "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e"};
    }
  }

}
