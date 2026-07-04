import 'package:flutter/material.dart';
import 'package:iot_app/components/colorpicker.dart';
import 'package:iot_app/functions/function.dart';

class EditDashboardItemDialog extends StatefulWidget {
  final Map<String, dynamic> subItem;
  final List monitors;

  const EditDashboardItemDialog({super.key, required this.subItem, required this.monitors});

  @override
  State<EditDashboardItemDialog> createState() => _EditDashboardItemDialogState();
}

class _EditDashboardItemDialogState extends State<EditDashboardItemDialog> {
  late bool foundMonitor;
  late String monitorId;
  late Color chooseColor;

  @override
  void initState() {
    super.initState();
    monitorId = widget.subItem['monitor_id'].toString();
    chooseColor = hexToColor(widget.subItem['label_color_code']);
    foundMonitor = widget.monitors.any((m) => m['monitor_id'].toString() == monitorId);
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
      title: Text("แก้ไขข้อมูล Dashboard"),
      backgroundColor: Colors.white,
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // เลือก monitor
            DropdownButton<String>(
              value: foundMonitor ? monitorId : null,
              isExpanded: true,
              items: widget.monitors.map<DropdownMenuItem<String>>((m) {
                final id = m['monitor_id'].toString();

                return DropdownMenuItem(value: id, child: Text("[${m['monitor_id']}] ${m['monitor_name']}"));
              }).toList(),
              onChanged: (v) {
                setState(() {
                  monitorId = v!;
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
                  decoration: BoxDecoration(
                    color: chooseColor,
                    border: Border.all(color: Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.red,
                        Colors.orange,
                        Colors.yellow,
                        Colors.green,
                        Colors.blue,
                        Colors.indigo,
                        Colors.purple,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: () async {
                      final result = await showDialog(
                        context: context,
                        builder: (_) => ColorPickerDialog(initialColor: chooseColor),
                      );

                      if (result != null && result is Color) {
                        setState(() => chooseColor = result);
                      }
                    },
                    child: Text("เลือกสี", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red)),
              child: Text("ลบ", style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(context, {'delete': true}),
            ),

            Row(
              children: [
                TextButton(
                  style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.grey)),
                  child: Text("ยกเลิก", style: TextStyle(color: Colors.white)),
                  onPressed: () => Navigator.pop(context, null),
                ),
                SizedBox(width: 4),
                TextButton(
                  style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.green)),
                  child: Text("บันทึก", style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.pop(context, {
                      'monitor_id': monitorId,
                      'label_color_code': colorToHex(chooseColor),
                      'delete': false,
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
