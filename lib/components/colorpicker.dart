import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  const ColorPickerDialog({super.key, required this.initialColor});

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color currentColor;

  @override
  void initState() {
    super.initState();
    currentColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("เลือกสี"),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: currentColor,
          onColorChanged: (color) {
            setState(() => currentColor = color);
          },
        ),
      ),
      actions: [
        TextButton(
          child: Text("ยกเลิก"),
          onPressed: () => Navigator.pop(context, null),
        ),
        TextButton(
          child: Text("เลือก"),
          onPressed: () => Navigator.pop(context, currentColor),
        ),
      ],
    );
  }
}
