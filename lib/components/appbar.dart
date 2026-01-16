import 'package:flutter/material.dart';
import 'package:iot_app/components/session.dart';

const Color brandOrange = Color(0xFFFF8021);
const Color whiteColor = Colors.white;
const Color blackColor = Colors.black;

class AppbarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String txtt;

  const AppbarWidget({super.key, required this.txtt});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(_getResponsiveAppBarHeight(context)),
      child: Container(
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(_getResponsiveBorderRadius(context)),
          ),
          border: Border(bottom: BorderSide(width: 3.0, color: Color.fromARGB(255, 255, 131, 0))),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 255, 131, 0).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 6),
              spreadRadius: -8,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(_getResponsiveBorderRadius(context)),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.black),
            title: Text(
              txtt,
              style: TextStyle(
                color: blackColor,
                fontSize: _getResponsiveFontSize(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: AdminBadge(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ขนาดตัวอักษร
  double _getResponsiveFontSize(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    
    // ถ้าเป็นแนวนอน ลดขนาดลง 20%
    double multiplier = isLandscape ? 0.8 : 1.0;
    
    // มือถือเล็ก (< 360px)
    if (screenWidth < 360) {
      return 14 * multiplier;
    }
    // มือถือปกติ (360px - 414px)
    else if (screenWidth >= 360 && screenWidth < 414) {
      return 15 * multiplier;
    }
    // มือถือใหญ่ (414px - 600px)
    else if (screenWidth >= 414 && screenWidth < 600) {
      return 17 * multiplier;
    }
    // แท็บเล็ต (600px - 900px)
    else if (screenWidth >= 600 && screenWidth < 900) {
      return 20 * multiplier;
    }
    // แท็บเล็ตใหญ่/Desktop เล็ก (900px - 1200px)
    else if (screenWidth >= 900 && screenWidth < 1200) {
      return 23 * multiplier;
    }
    // Desktop ใหญ่ (>= 1200px)
    else {
      return 28 * multiplier;
    }
  }

  // ความสูง AppBar
  double _getResponsiveAppBarHeight(BuildContext context) {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    double screenHeight = MediaQuery.of(context).size.height;
    
    // แนวนอน: ใช้ความสูงน้อยกว่า
    if (isLandscape) {
      return screenHeight * 0.09; // 9% ของความสูงหน้าจอ
    }
    // แนวตั้ง: ใช้ความสูงปกติ
    else {
      return screenHeight * 0.08; // 8% ของความสูงหน้าจอ
    }
  }

  // ความโค้งมุม
  double _getResponsiveBorderRadius(BuildContext context) {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    double screenWidth = MediaQuery.of(context).size.width;
    
    // แนวนอน: ลดความโค้งลง
    if (isLandscape) {
      return screenWidth * 0.03; // 3% ของความกว้างหน้าจอ
    }
    // แนวตั้ง: ความโค้งปกติ
    else {
      return screenWidth * 0.05; // 5% ของความกว้างหน้าจอ
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

/// ================= Admin Badge =================
class AdminBadge extends StatelessWidget {
  const AdminBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final String roleText =
        CurrentUser['username']?.toString() ?? 'แอดมิน';

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE8DC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: brandOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              roleText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: brandOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}