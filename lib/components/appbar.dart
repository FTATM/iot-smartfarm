import 'package:flutter/material.dart';
import 'package:iot_app/components/session.dart';

class AppbarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String txtt;

  const AppbarWidget({super.key, required this.txtt});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(txtt),
      centerTitle: true,
      backgroundColor: Colors.white,
      actions: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(CurrentUser['username'].toString()),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
