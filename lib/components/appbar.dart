import 'package:flutter/material.dart';
import 'package:iot_app/components/session.dart';

const Color brandOrange = Color(0xFFFF8021);

class AppbarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String txtt;

  const AppbarWidget({super.key, required this.txtt});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.black),
      title: Text(
        txtt,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 12),
          child: AdminBadge(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// ================= Admin Badge =================
class AdminBadge extends StatelessWidget {
  const AdminBadge({super.key});

  @override
  Widget build(BuildContext context) {
    // ถ้าต้องการเปลี่ยนข้อความจาก username เป็นอย่างอื่น
    // สามารถแก้ตรงนี้ได้
    final String roleText =
        CurrentUser['username']?.toString() ?? 'แอดมิน';

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE8DC), // พื้นหลังส้มอ่อน
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== Icon Circle =====
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

            // ===== Text =====
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
