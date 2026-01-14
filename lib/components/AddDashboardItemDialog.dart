import 'package:flutter/material.dart';
import 'package:iot_app/components/colorpicker.dart';
import 'package:iot_app/functions/function.dart';

class AddDashboardItemDialog extends StatefulWidget {
  final List monitors;

  const AddDashboardItemDialog({super.key, required this.monitors});

  @override
  State<AddDashboardItemDialog> createState() => _AddDashboardItemDialogState();
}

class _AddDashboardItemDialogState extends State<AddDashboardItemDialog> {
  late String monitorId = "";
  late String monitorName;
  late Color chooseColor;

  @override
  void initState() {
    super.initState();
    chooseColor = hexToColor('#FFF2E6');
  }

  String colorToHex(Color color) {
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#${r + g + b}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("เพิ่มข้อมูล Dashboard"),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // เลือก monitor
            DropdownButton<String>(
              hint: Text("เลือกมิเตอร์ทีต้องการดึงข้อมูล"),
              value: (monitorId == "") ? null : "$monitorId,$monitorName",
              isExpanded: true,
              items: widget.monitors.map<DropdownMenuItem<String>>((m) {
                return DropdownMenuItem(
                  value: "${m['monitor_id']},${m['monitor_name']}",
                  child: Text("[${m['monitor_id']}] ${m['monitor_name']}"),
                );
              }).toList(),
              onChanged: (v) {
                if (v == null) return;
                final idname = v.split(',');
                setState(() {
                  monitorId = idname[0];
                  monitorName = idname[1];
                });
              },
            ),

            SizedBox(height: 16),

            // เลือกสี
            Row(
              children: [
                Container(
                  width: 40,
                  height: 25,
                  decoration: BoxDecoration(color: chooseColor, border: Border.all()),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    final result = await showDialog(
                      context: context,
                      builder: (_) => ColorPickerDialog(initialColor: chooseColor),
                    );

                    if (result != null && result is Color) {
                      setState(() => chooseColor = result);
                    }
                  },
                  child: Text("เลือกสี"),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(child: Text("ยกเลิก"), onPressed: () => Navigator.pop(context, null)),
        TextButton(
          child: Text("บันทึก"),
          onPressed: () {
            Navigator.pop(context, {
              'monitor_id': monitorId,
              'monitor_name': monitorName,
              'label_color_code': colorToHex(chooseColor),
            });
          },
        ),
      ],
    );
  }
}
