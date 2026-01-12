import 'dart:convert';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:iot_app/components/session.dart';
import 'package:iot_app/functions/function.dart';

class DashboardBlogByIdWidget extends StatefulWidget {
  final String type;
  final String size;
  final String title;
  final String value;
  final bool isDialog;
  final String pathImage;
  final Color color;
  final String labelJson;
  final String valueJson;
  final Function(String key, String newValue) onValueChanged;

  const DashboardBlogByIdWidget({
    super.key,
    required this.type,
    required this.size,
    required this.title,
    required this.value,
    required this.isDialog,
    required this.pathImage,
    required this.color,
    required this.labelJson,
    required this.valueJson,
    required this.onValueChanged, // <-- required
  });

  @override
  State<DashboardBlogByIdWidget> createState() => _DashboardBlogByIdWidgetState();
}

class _DashboardBlogByIdWidgetState extends State<DashboardBlogByIdWidget> {
  late String currentValue;
  late String keyValue = "m_value";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.type;
    final title = widget.title;
    final double value = double.parse(widget.value);
    final color = widget.color;
    final labelJson = widget.labelJson;
    final valueJson = widget.valueJson;

    final path = "${CurrentUser['baseURL']}../${widget.pathImage}";
    double maxwidth = MediaQuery.of(context).size.width;
    maxwidth = widget.isDialog ? maxwidth * 0.75 - 5 : maxwidth;
    final double size_ = double.parse(widget.size);
    final double sizewidth = (maxwidth / size_);
    final double sizeheight = (250 / size_);

    Color base = widget.color;
    Color light = lighten(base, 0.25); // อ่อนลง 25%
    // Color lighter = lighten(light, 0.25); // อ่อนลง 25%
    // Color dark = darken(base, 0.25); // เข้มขึ้น 25%

    Color textColor = isColorLight(base) ? Colors.black : Colors.white;

    List<Color> colorlist = [base, light];

    if (type == '1') {
      // Tempurature pie circle
      // Nothing
      return Container(
        width: sizewidth,
        height: sizeheight,
        padding: EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(25, 0, 0, 0),
                blurRadius: 1, // ความฟุ้งของเงา
                spreadRadius: 1, // การกระจายของเงา
                offset: Offset(0, 4), // เงาแนวตั้ง (x,y)
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: (sizeheight * 0.8) - 8,
                child: Row(
                  children: [
                    SizedBox(
                      width: sizewidth * 0.5 - 4,
                      child: Center(
                        child: CircularProgressIndicator(
                          padding: EdgeInsets.all(6),
                          value: (value / 100).clamp(0, 1),
                          strokeWidth: 20 / size_,
                          backgroundColor: Colors.grey[200],
                          color: color,
                        ),
                      ),
                    ),
                    Container(
                      width: sizewidth * 0.5 - 4,
                      child: Center(
                        child: Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: Container(
                                  width: (sizewidth * 0.5 - 4) * 0.5,
                                  child: Image.network(path, width: sizewidth * 0.45, height: sizeheight * 0.45),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "${value.toStringAsFixed(1)}°C",
                                  style: TextStyle(
                                    fontSize: 30 / size_,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
                  gradient: LinearGradient(colors: colorlist, begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
                width: sizewidth,
                height: sizeheight * 0.2,
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(color: textColor, fontSize: 24 / size_, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      );


    } else if (type == '2') {
      // Pie Chart
      // final labels = jsonDecode(labelJson) ?? [];
      final values = jsonDecode(valueJson) ?? [];

      if (values.isEmpty) {
        return const Center(child: Text("No data"));
      }

      final chartColors = [color, Colors.orange, Colors.purple, Colors.green, Colors.red];
      return Container(
        width: sizewidth,
        height: sizeheight,
        padding: EdgeInsets.all(4),
        child: Container(
          // padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(25, 0, 0, 0),
                blurRadius: 1, // ความฟุ้งของเงา
                spreadRadius: 1, // การกระจายของเงา
                offset: Offset(0, 4), // เงาแนวตั้ง (x,y)
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                width: sizewidth,
                height: (sizeheight * 0.8) - 8,
                child: Row(
                  children: [
                    Container(
                      width: (sizewidth * 0.5) - 4,
                      child: Center(
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 1,
                            centerSpaceRadius: (sizewidth * 0.1),
                            sections: List.generate(values.length, (index) {
                              final double val = (double.tryParse(values[index].toString()) ?? 0.0);
                              // ถ้า value เป็น 0 ให้ใส่ 1 เพื่อให้แท่งแสดง
                              final displayValue = val > 0 ? val : 1.0;
                              return PieChartSectionData(
                                // value: (double.tryParse(values[index].toString()) ?? 1.0),
                                value: displayValue,
                                color: chartColors[index],
                                // title: labels[index],
                                showTitle: false,
                                radius: 25 / size_,
                                // titleStyle: TextStyle(
                                //   fontSize: 14,
                                //   fontWeight: FontWeight.bold,
                                //   color: Colors.white,
                                // ),
                              );
                            }),
                            // borderData: FlBorderData(show: true),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: (sizewidth * 0.5) - 4,
                      height: sizeheight,
                      child: Column(
                        children: [
                          SizedBox(
                            height: (sizeheight * 0.8) * 0.6,
                            child: Center(
                              child: Image.network(path, width: sizewidth * 0.25, height: sizeheight * 0.25),
                            ),
                          ),
                          Expanded(
                            child: Text(value.toString(), style: TextStyle(fontSize: sizeheight * 0.15)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
                  gradient: LinearGradient(colors: colorlist, begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
                width: sizewidth,
                height: sizeheight * 0.2,
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(color: textColor, fontSize: 24 / size_, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (type == '3') {
      // Thermometer bar
      //
      return Container(
        width: sizewidth,
        height: sizeheight,
        padding: EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(25, 0, 0, 0),
                blurRadius: 1, // ความฟุ้งของเงา
                spreadRadius: 1, // การกระจายของเงา
                offset: Offset(0, 4), // เงาแนวตั้ง (x,y)
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                width: sizewidth,
                height: (sizeheight * 0.8) - 8,
                child: Row(
                  children: [
                    SizedBox(
                      width: (sizewidth * 0.5) - 4,
                      height: sizeheight * 0.6,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            width: 40 / size_,
                            height: sizeheight * 0.7 - 8,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400, width: 2),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade200,
                            ),
                          ),
                          Container(
                            width: 40 / size_,
                            height: value.clamp(0, sizeheight * 0.7 - 8),
                            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: (sizewidth * 0.5) - 4,
                      height: sizeheight * 0.8,
                      child: Column(
                        children: [
                          SizedBox(
                            height: sizeheight * 0.4 - 4,
                            child: Center(
                              child: Image.network(path, width: sizewidth * 0.25, height: sizeheight * 0.25),
                            ),
                          ),
                          SizedBox(
                            height: sizeheight * 0.4 - 4,
                            child: Center(
                              child: Text(
                                '${value.toStringAsFixed(1)} °C',
                                style: TextStyle(fontSize: 30 / size_, fontWeight: FontWeight.bold, color: color),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
                  gradient: LinearGradient(colors: colorlist, begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
                width: sizewidth,
                height: sizeheight * 0.2,
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(color: textColor, fontSize: 24 / size_, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (type == '4') {
      // CLOCK
      // CLOCK
      final clockService = ClockService();
      clockService.start();

      return ValueListenableBuilder<DateTime>(
        valueListenable: clockService.currentTime,
        builder: (context, now, _) {
          return Container(
            width: maxwidth,
            height: 150,
            padding: EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(8)),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(25, 0, 0, 0),
                    blurRadius: 1, // ความฟุ้งของเงา
                    spreadRadius: 1, // การกระจายของเงา
                    offset: Offset(0, 4), // เงาแนวตั้ง (x,y)
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    clockService.formattedTime(now), // ✅ ใช้ now ที่ส่งมา
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    clockService.formattedDate(now), // ✅ ใช้ now ที่ส่งมา
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (type == '5') {
      // linear Chart
      // final labels = jsonDecode(labelJson);
      final rawValue = jsonDecode(valueJson);

      if (rawValue.length != 2) {
        rawValue.add([0, 0, 0, 0, 0]);
      }
      final list1 = List.generate(rawValue[0].length, (index) {
        return safeParse(rawValue[0][index]);
      });

      final list2 = List.generate(rawValue[1].length, (index) {
        return safeParse(rawValue[1][index]);
      });
      final maxAll = [...list1, ...list2].reduce(max);

      final labels = ["00:00", "06:00", "12:00", "18:00", "24:00"];
      final values = [
        {"data": rawValue[0], "color": "#FF0000"},
        {"data": rawValue[1], "color": "#00BFFF"},
      ];
      return Container(
        width: maxwidth,
        height: 250,
        padding: EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(25, 0, 0, 0),
                blurRadius: 1, // ความฟุ้งของเงา
                spreadRadius: 1, // การกระจายของเงา
                offset: Offset(0, 4), // เงาแนวตั้ง (x,y)
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                      gradient: LinearGradient(
                        colors: colorlist,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    width: maxwidth,
                    height: 250 * 0.2 - 4,
                    child: Center(
                      child: Text(
                        title,
                        style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: maxwidth,
                    height: 250 * 0.8 - 4,
                    child: Container(
                      width: maxwidth * 0.8 - 4,
                      padding: EdgeInsets.all(12),
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: ((10 + maxAll) * 1.2),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 25,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index >= 0 && index < labels.length) {
                                    return Text(labels[index], style: const TextStyle(fontSize: 10));
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) =>
                                    Text('V ${value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10)),
                              ),
                            ),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          lineBarsData: values.map((s) {
                            final color = hexToColor((s['color'] ?? "#000000").toString());
                            final dataPoints = List<double>.from(
                              (s['data'] as List).map((v) => double.tryParse(v.toString()) ?? 0.0),
                            );

                            return LineChartBarData(
                              spots: dataPoints.asMap().entries.map((e) {
                                return FlSpot(e.key.toDouble(), e.value);
                              }).toList(),
                              isCurved: true,
                              color: color,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [color.withOpacity(0.5), color.withOpacity(0.0)],
                                ),
                              ),
                              dotData: const FlDotData(show: false),
                            );
                          }).toList(),
                          gridData: const FlGridData(show: true, drawVerticalLine: false),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                child: Image.network(path, width: 250 * 0.15, height: 250 * 0.15),
              ),
            ],
          ),
        ),
      );
    } else if (type == '6') {
      // Scatter Chart
      final rawValue = jsonDecode(valueJson);

      if (rawValue.length != 2) {
        rawValue.add([0, 0, 0, 0, 0]);
      }
      ;

      List<Map<String, dynamic>> chartData = [];

      for (int i = 0; i < rawValue[0].length; i++) {
        chartData.add({"dx": (i * 5).toDouble(), "dy": int.parse(rawValue[0][i])});
      }
      final values = [
        {
          "name": "Oxygen",
          // "color": "#FF0000",
          "data": chartData,
        },
        // {
        //   "name": "Wind Speed",
        //   "color": "#00BFFF",
        //   "data": [
        //     {"dx": 2.0, "dy": 7.0},
        //     {"dx": 6.0, "dy": 12.0},
        //     {"dx": 11.0, "dy": 4.0},
        //   ],
        // },
      ];
      return Container(
        width: maxwidth,
        height: 250,
        padding: EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(25, 0, 0, 0),
                blurRadius: 1, // ความฟุ้งของเงา
                spreadRadius: 1, // การกระจายของเงา
                offset: Offset(0, 4), // เงาแนวตั้ง (x,y)
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                      gradient: LinearGradient(
                        colors: colorlist,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    width: maxwidth,
                    height: 250 * 0.2 - 8,
                    child: Center(
                      child: Text(
                        title,
                        style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(12),
                    width: maxwidth,
                    height: 250 * 0.8,
                    child: SizedBox(
                      width: maxwidth * 0.8 - 4,
                      child: ScatterChart(
                        ScatterChartData(
                          scatterSpots: (values).expand((s) {
                            final dataPoints = (s['data'] as List)
                                .map((p) => ScatterSpot((p['dx'] as num).toDouble(), (p['dy'] as num).toDouble()))
                                .toList();
                            return dataPoints;
                          }).toList(),
                          minX: 0,
                          maxX: 40,
                          minY: 0,
                          maxY: 20,
                          gridData: const FlGridData(show: true, drawVerticalLine: true, drawHorizontalLine: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                getTitlesWidget: (value, meta) =>
                                    Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 10)),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                getTitlesWidget: (value, meta) =>
                                    Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 10)),
                              ),
                            ),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                child: Image.network(path, width: 250 * 0.15, height: 250 * 0.15),
              ),
            ],
          ),
        ),
      );
    } else if (type == '7') {
      // Button
      //
      bool isOn = value == 1 ? true : false;
      return Container(
        width: sizewidth,
        height: sizeheight,
        padding: EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(25, 0, 0, 0),
                blurRadius: 1, // ความฟุ้งของเงา
                spreadRadius: 1, // การกระจายของเงา
                offset: Offset(0, 4), // เงาแนวตั้ง (x,y)
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: sizewidth,
                height: (sizeheight * 0.8),
                child: Row(
                  children: [
                    Container(
                      width: (sizewidth * 0.5) - 4,
                      child: Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isOn ? color : Colors.grey[300], // เปลี่ยนสีตามสถานะ
                            foregroundColor: isOn ? Colors.white : Colors.black87,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24 / size_)),
                            padding: EdgeInsets.symmetric(horizontal: 36 / size_, vertical: 24 / size_),
                          ),
                          onPressed: () {
                            setState(() {
                              String x = isOn ? "0" : "1";
                              widget.onValueChanged('m_value', x);
                            });
                          },
                          child: Text(
                            isOn ? 'ON' : 'OFF',
                            style: TextStyle(fontSize: 30 / size_, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: (sizewidth * 0.5) - 4,
                      child: Center(
                        child: Image.network(path, width: sizewidth * 0.45, height: sizeheight * 0.45),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
                  gradient: LinearGradient(colors: colorlist, begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
                width: sizewidth,
                height: sizeheight * 0.2 - 8,
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(color: textColor, fontSize: 24 / size_, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (type == '8') {
      // Slide Bar value
      //

      return Container(
        width: maxwidth,
        height: 250,
        padding: EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(25, 0, 0, 0),
                blurRadius: 1, // ความฟุ้งของเงา
                spreadRadius: 1, // การกระจายของเงา
                offset: Offset(0, 4), // เงาแนวตั้ง (x,y)
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                  gradient: LinearGradient(colors: colorlist, begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
                width: maxwidth,
                height: 250 * 0.2 - 8,
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 12),
                width: maxwidth,
                height: 250 * 0.8,
                child: Column(
                  children: [
                    SizedBox(
                      height: 250 * 0.3,
                      child: Image.network(path, width: maxwidth * 0.25, height: maxwidth * 0.25),
                    ),
                    SizedBox(
                      height: 250 * 0.3,
                      child: Row(
                        children: [
                          Container(
                            width: (maxwidth * 0.8) - 4,
                            child: Center(
                              child: Slider(
                                value: value,
                                min: 0,
                                max: 9999,
                                divisions: 40,
                                activeColor: color,
                                inactiveColor: Colors.grey.shade300,
                                onChanged: (value) {},
                              ),
                            ),
                          ),
                          Container(
                            width: (maxwidth * 0.2) - 4,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                value.toString(),
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 250 * 0.1,
                      child: const Text(
                        'Range 0 to 9,999',
                        style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else if (type == '9') {
      // Lamp
      //
      return Container(
        width: sizewidth,
        height: sizeheight,
        padding: EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(25, 0, 0, 0),
                blurRadius: 1, // ความฟุ้งของเงา
                spreadRadius: 1, // การกระจายของเงา
                offset: Offset(0, 4), // เงาแนวตั้ง (x,y)
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: sizewidth,
                height: sizeheight * 0.8 - 8,
                child: Row(
                  children: [
                    SizedBox(
                      child: Image.asset(
                        'assets/images/Lamp-${value == 1 ? "2" : "4"}-1.gif',
                        width: sizewidth * 0.5 - 4,
                        height: sizeheight * 0.5 - 4,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(
                      width: sizewidth * 0.5 - 4,
                      child: Column(
                        children: [
                          Container(
                            width: (sizewidth * 0.5) - 4,
                            height: (sizeheight * 0.8 - 8) * 0.5,
                            child: Center(
                              child: Image.network(path, width: sizewidth * 0.25, height: sizeheight * 0.25),
                            ),
                          ),
                          // รูปภาพ Lamp
                          // สถานะ
                          SizedBox(
                            width: sizewidth * 0.5 - 4,
                            height: (sizeheight * 0.8 - 8) * 0.5,
                            child: Center(
                              child: Text(
                                value == 1 ? "ON" : "OFF",
                                style: const TextStyle(
                                  color: Color(0xFF555555),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
                  gradient: LinearGradient(colors: colorlist, begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
                width: sizewidth,
                height: sizeheight * 0.2,
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(color: textColor, fontSize: 24 / size_, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (type == '10') {
      // Switch
      //
      bool isOn = value == 1 ? true : false;
      return Container(
        width: sizewidth,
        height: sizeheight,
        padding: EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(25, 0, 0, 0),
                blurRadius: 1,
                spreadRadius: 1,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: sizewidth,
                height: sizeheight * 0.8 - 8,
                child: Row(
                  children: [
                    Container(
                      width: (sizewidth * 0.5) - 4,
                      child: Center(
                        child: Switch(
                          value: isOn,
                          activeThumbColor: color,
                          activeTrackColor: light,
                          onChanged: (value) {
                            setState(() {
                              isOn = value;
                            });
                            String x = isOn ? "1" : "0";
                            widget.onValueChanged('m_value', x);
                          },
                        ),
                      ),
                    ),
                    Container(
                      width: sizewidth * 0.5 - 4,
                      child: Column(
                        children: [
                          Container(
                            height: (sizeheight * 0.8 - 8) * 0.5,
                            child: Center(
                              child: Image.network(path, width: sizewidth * 0.25, height: sizeheight * 0.25),
                            ),
                          ),
                          Container(
                            height: (sizeheight * 0.8 - 8) * 0.5,
                            child: Center(
                              child: Text(
                                value == 1 ? 'ON' : 'OFF',
                                style: TextStyle(
                                  fontSize: 36 / size_,
                                  color: Color(0xFF555555),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
                  gradient: LinearGradient(colors: colorlist, begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
                width: sizewidth,
                height: sizeheight * 0.2,
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(color: textColor, fontSize: 24 / size_, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (type == '11') {
      // Blink blink
      //
      return Container(
        width: sizewidth,
        height: sizeheight,
        padding: EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(25, 0, 0, 0),
                blurRadius: 1, // ความฟุ้งของเงา
                spreadRadius: 1, // การกระจายของเงา
                offset: Offset(0, 4), // เงาแนวตั้ง (x,y)
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: sizewidth,
                height: sizeheight * 0.8 - 8,
                child: Row(
                  children: [
                    Container(
                      width: (sizewidth * 0.5) - 4,

                      child: Center(
                        child: ColorFiltered(
                          colorFilter: value == 0
                              ? const ColorFilter.mode(Color.fromARGB(255, 255, 255, 255), BlendMode.saturation)
                              : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                          child: Image.asset(
                            'assets/images/blink_${value == 1 ? '1' : '0'}.gif',
                            width: sizewidth * 0.45,
                            height: sizeheight * 0.45,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: sizewidth * 0.5 - 4,
                      child: Column(
                        children: [
                          Container(
                            height: (sizeheight * 0.8 - 8) * 0.5,
                            child: Center(
                              child: Image.network(path, width: sizewidth * 0.25, height: sizeheight * 0.25),
                            ),
                          ),
                          Container(
                            height: (sizeheight * 0.8 - 8) * 0.5,
                            child: Center(
                              child: Text(
                                value == 1 ? 'ON' : 'OFF',
                                style: TextStyle(
                                  color: Color(0xFF555555),
                                  fontSize: 36 / size_,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
                  gradient: LinearGradient(colors: colorlist, begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
                width: sizewidth,
                height: sizeheight * 0.2,
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(color: textColor, fontSize: 24 / size_, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (type == '12') {
      //bar Chart
      final rawLabel = jsonDecode(labelJson);
      final rawValue = jsonDecode(valueJson);
      final values = List.generate(rawValue.length, (index) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: double.parse(rawValue[index][0]), // ใช้ค่าจาก rawValue
              color: color,
              width: 25,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        );
      });
      return Container(
        width: maxwidth,
        height: 250,
        padding: EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(25, 0, 0, 0),
                blurRadius: 1, // ความฟุ้งของเงา
                spreadRadius: 1, // การกระจายของเงา
                offset: Offset(0, 4), // เงาแนวตั้ง (x,y)
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                      gradient: LinearGradient(
                        colors: colorlist,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    width: maxwidth,
                    height: 250 * 0.2 - 8,
                    child: Center(
                      child: Text(
                        title,
                        style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 12),
                    width: maxwidth,
                    height: (250 * 0.8),
                    // Bar Chart
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    rawLabel[value.toInt()],
                                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        barGroups: values,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                child: Image.network(path, width: 250 * 0.15, height: 250 * 0.15),
              ),
            ],
          ),
        ),
      );
    } else {
      return const Text("Unknown type");
    }
  }
}
