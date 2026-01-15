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
    required this.onValueChanged,
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

  // Helper method to build standard container
  Widget _buildStandardContainer(double sizewidth, double sizeheight, Widget content) {
    return Container(
      width: sizewidth,
      height: sizeheight,
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(25, 0, 0, 0),
              blurRadius: 1,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: content,
        ),
      ),
    );
  }

  // Helper method to build header with icon and title
  Widget _buildHeader(String title, String path, Color color, double size_) {
    return Row(
      children: [
        Image.network(
          path,
          width: size_ == 1 ? 28 : (size_ == 2 ? 24 : 20),
          height: size_ == 1 ? 28 : (size_ == 2 ? 24 : 20),
          color: color,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.dashboard,
              size: size_ == 1 ? 28 : (size_ == 2 ? 24 : 20),
              color: color,
            );
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: size_ == 1 ? 16 : (size_ == 2 ? 15 : 14),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Helper method to build center content with icon and value/control
  Widget _buildCenterContent(Widget icon, Widget valueWidget, double size_) {
    return Expanded(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(flex: 1, child: icon),
            SizedBox(width: size_ == 1 ? 16 : (size_ == 2 ? 12 : 10)),
            Flexible(flex: 2, child: valueWidget),
          ],
        ),
      ),
    );
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
    Color light = lighten(base, 0.25);
    Color textColor = isColorLight(base) ? Colors.black : Colors.white;
    List<Color> colorlist = [base, light];

    // Replace Type 1 section in DashboardblogById.dart (around line 50-120)

// Replace Type 1 section in DashboardblogById.dart (around line 50-120)

if (type == '1') {
  // Type 1: Simple value display - Humidity style layout
  return Container(
    width: sizewidth,
    height: sizeheight,
    padding: const EdgeInsets.all(4),
    child: LayoutBuilder(
      builder: (context, constraints) {
        // คำนวณขนาดตามพื้นที่ที่มี
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        
        // ใช้ scale factor เดียวสำหรับทุกอย่าง เพื่อคงสัดส่วน
        final scaleFactor = (availableHeight / 400).clamp(0.3, 1.5);
        
        // ขนาดพื้นฐาน (base size) ที่ออกแบบไว้สำหรับ 400px
        final smallIconSize = 55.0 * scaleFactor;
        final largeIconSize = 140.0 * scaleFactor;
        final titleFontSize = 30.0 * scaleFactor;
        final valueFontSize = 60.0 * scaleFactor;
        final contentPadding = 12.0 * scaleFactor;
        final spacing = 8.0 * scaleFactor;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(8 * scaleFactor),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(contentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Row: Small Icon (left) + Title (next to icon)
                Row(
                  children: [
                    // Small icon from database (left corner)
                    Image.network(
                      path,
                      width: smallIconSize,
                      height: smallIconSize,
                      color: color,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.thermostat,
                          size: smallIconSize,
                          color: color,
                        );
                      },
                    ),
                    SizedBox(width: spacing),
                    // Title next to icon
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // 2. Center Content: Large Icon (centered)
                Expanded(
                  child: Center(
                    child: Image.network(
                      path,
                      width: largeIconSize,
                      height: largeIconSize,
                      color: color,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.thermostat,
                          size: largeIconSize,
                          color: color,
                        );
                      },
                    ),
                  ),
                ),
                // 3. Bottom: Value (centered)
                Center(
                  child: Text(
                    '${value.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: valueFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(height: spacing),
              ],
            ),
          ),
        );
      },
    ),
  );

    } else if (type == '2') {
  // Type 2: Pie Chart
  final values = jsonDecode(valueJson) ?? [];
  if (values.isEmpty) {
    return const Center(child: Text("No data"));
  }
  final chartColors = [color, Colors.orange, Colors.purple, Colors.green, Colors.red];
  
  return Container(
    width: sizewidth,
    height: sizeheight,
    padding: const EdgeInsets.all(4),
    child: LayoutBuilder(
      builder: (context, constraints) {
        // คำนวณขนาดตามพื้นที่ที่มี - เหมือนเงื่อนไขที่ 1
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        
        // ใช้ scale factor เดียวสำหรับทุกอย่าง เพื่อคงสัดส่วน
        final scaleFactor = (availableHeight / 400).clamp(0.3, 1.5);
        
        // ขนาดพื้นฐาน (base size) ที่ออกแบบไว้สำหรับ 400px
        final smallIconSize = 55.0 * scaleFactor;
        final chartSize = 140.0 * scaleFactor;
        final titleFontSize = 30.0 * scaleFactor;
        final valueFontSize = 60.0 * scaleFactor;
        final contentPadding = 12.0 * scaleFactor;
        final spacing = 8.0 * scaleFactor;
        final chartRadius = 35.0 * scaleFactor;
        final centerSpaceRadius = 20.0 * scaleFactor;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(8 * scaleFactor),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(contentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Row: Small Icon (left) + Title (next to icon)
                Row(
                  children: [
                    // Small icon from database (left corner)
                    Image.network(
                      path,
                      width: smallIconSize,
                      height: smallIconSize,
                      color: color,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.pie_chart,
                          size: smallIconSize,
                          color: color,
                        );
                      },
                    ),
                    SizedBox(width: spacing),
                    // Title next to icon
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // 2. Center Content: Pie Chart (centered)
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: chartSize,
                      height: chartSize,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 1,
                          centerSpaceRadius: centerSpaceRadius,
                          sections: List.generate(values.length, (index) {
                            final double val = (double.tryParse(values[index].toString()) ?? 0.0);
                            final displayValue = val > 0 ? val : 1.0;
                            return PieChartSectionData(
                              value: displayValue,
                              color: chartColors[index % chartColors.length],
                              showTitle: false,
                              radius: chartRadius,
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
                // 3. Bottom: Value (centered)
                Center(
                  child: Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: valueFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(height: spacing),
              ],
            ),
          ),
        );
      },
    ),
  );

    } else if (type == '3') {
  // Type 3: Thermometer bar
  return Container(
    width: sizewidth,
    height: sizeheight,
    padding: const EdgeInsets.all(4),
    child: LayoutBuilder(
      builder: (context, constraints) {
        // คำนวณขนาดตามพื้นที่ที่มี - เหมือนเงื่อนไขที่ 1 และ 2
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        
        // ใช้ scale factor เดียวสำหรับทุกอย่าง เพื่อคงสัดส่วน
        final scaleFactor = (availableHeight / 400).clamp(0.3, 1.5);
        
        // ขนาดพื้นฐาน (base size) ที่ออกแบบไว้สำหรับ 400px
        final smallIconSize = 55.0 * scaleFactor;
        final largeIconSize = 100.0 * scaleFactor;
        final titleFontSize = 30.0 * scaleFactor;
        final valueFontSize = 48.0 * scaleFactor;
        final contentPadding = 12.0 * scaleFactor;
        final spacing = 8.0 * scaleFactor;
        final thermometerWidth = 40.0 * scaleFactor;
        final thermometerHeight = 200.0 * scaleFactor;
        final bottomBarHeight = 80.0 * scaleFactor;
        final bottomTitleFontSize = 24.0 * scaleFactor;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(8 * scaleFactor),
            ),
          ),
          child: Column(
            children: [
              // 1. Header Row: Small Icon (left) + Title (next to icon)
              Padding(
                padding: EdgeInsets.all(contentPadding),
                child: Row(
                  children: [
                    // Small icon from database (left corner)
                    Image.network(
                      path,
                      width: smallIconSize,
                      height: smallIconSize,
                      color: color,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.thermostat,
                          size: smallIconSize,
                          color: color,
                        );
                      },
                    ),
                    SizedBox(width: spacing),
                    // Title next to icon
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 2. Center Content: Thermometer bar + Icon + Value
              // 2. Center Content: Thermometer bar (centered) + Value (bottom)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: contentPadding),
                  child: Column(
                    children: [
                      // Thermometer bar ตรงกลาง
                      Expanded(
                        child: Center(
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              // กรอบ thermometer
                              Container(
                                width: thermometerWidth,
                                height: thermometerHeight,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                    width: 2 * scaleFactor,
                                  ),
                                  borderRadius: BorderRadius.circular(12 * scaleFactor),
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              // แถบสีที่เติม
                              Container(
                                width: thermometerWidth,
                                height: (value / 100 * thermometerHeight).clamp(0.0, thermometerHeight),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(12 * scaleFactor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // ค่าข้อมูลด้านล่าง
                      Center(
                        child: Text(
                          '${value.toStringAsFixed(1)}°C',
                          style: TextStyle(
                            fontSize: valueFontSize,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                      SizedBox(height: spacing),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

    } else if (type == '4') {
      // Type 4: CLOCK
      final clockService = ClockService();
      clockService.start();

      return ValueListenableBuilder<DateTime>(
        valueListenable: clockService.currentTime,
        builder: (context, now, _) {
          return Container(
            width: maxwidth,
            height: 150,
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(25, 0, 0, 0),
                    blurRadius: 1,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    clockService.formattedTime(now),
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    clockService.formattedDate(now),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (type == '5') {
  // Type 5: Linear Chart
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
    width: sizewidth,
    height: sizeheight,
    padding: const EdgeInsets.all(4),
    child: LayoutBuilder(
      builder: (context, constraints) {
        // คำนวณขนาดตามพื้นที่ที่มี - เหมือนเงื่อนไขอื่นๆ
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        
        // ใช้ scale factor เดียวสำหรับทุกอย่าง เพื่อคงสัดส่วน
        final scaleFactor = (availableHeight / 400).clamp(0.3, 1.5);
        
        // ขนาดพื้นฐาน (base size) ที่ออกแบบไว้สำหรับ 400px
        final smallIconSize = 55.0 * scaleFactor;
        final titleFontSize = 30.0 * scaleFactor;
        final contentPadding = 12.0 * scaleFactor;
        final spacing = 8.0 * scaleFactor;
        final chartLabelFontSize = 10.0 * scaleFactor;
        final reservedSizeBottom = 25.0 * scaleFactor;
        final reservedSizeLeft = 40.0 * scaleFactor;
        final lineWidth = 3.0 * scaleFactor;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(8 * scaleFactor),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(contentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Row: Small Icon (left) + Title (next to icon)
                Row(
                  children: [
                    // Small icon from database (left corner)
                    Image.network(
                      path,
                      width: smallIconSize,
                      height: smallIconSize,
                      color: color,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.show_chart,
                          size: smallIconSize,
                          color: color,
                        );
                      },
                    ),
                    SizedBox(width: spacing),
                    // Title next to icon
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: spacing),
                
                // 2. Center Content: Line Chart (centered)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: contentPadding),
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: ((10 + maxAll) * 1.2),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: reservedSizeBottom,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < labels.length) {
                                  return Text(
                                    labels[index],
                                    style: TextStyle(fontSize: chartLabelFontSize),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: reservedSizeLeft,
                              getTitlesWidget: (value, meta) => Text(
                                'V ${value.toStringAsFixed(0)}',
                                style: TextStyle(fontSize: chartLabelFontSize),
                              ),
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        lineBarsData: values.map((s) {
                          final lineColor = hexToColor((s['color'] ?? "#000000").toString());
                          final dataPoints = List<double>.from(
                            (s['data'] as List).map((v) => double.tryParse(v.toString()) ?? 0.0),
                          );

                          return LineChartBarData(
                            spots: dataPoints.asMap().entries.map((e) {
                              return FlSpot(e.key.toDouble(), e.value);
                            }).toList(),
                            isCurved: true,
                            color: lineColor,
                            barWidth: lineWidth,
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  lineColor.withOpacity(0.5),
                                  lineColor.withOpacity(0.0),
                                ],
                              ),
                            ),
                            dotData: const FlDotData(show: false),
                          );
                        }).toList(),
                        gridData: const FlGridData(
                          show: true,
                          drawVerticalLine: false,
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: spacing),
              ],
            ),
          ),
        );
      },
    ),
  );

    } else if (type == '6') {
  // Type 6: Scatter Chart
  final rawValue = jsonDecode(valueJson);

  if (rawValue.length != 2) {
    rawValue.add([0, 0, 0, 0, 0]);
  }

  List<Map<String, dynamic>> chartData = [];

  for (int i = 0; i < rawValue[0].length; i++) {
    chartData.add({"dx": (i * 5).toDouble(), "dy": int.parse(rawValue[0][i])});
  }
  final values = [
    {
      "name": "Oxygen",
      "data": chartData,
    },
  ];
  
  return Container(
    width: sizewidth,
    height: sizeheight,
    padding: const EdgeInsets.all(4),
    child: LayoutBuilder(
      builder: (context, constraints) {
        // คำนวณขนาดตามพื้นที่ที่มี - เหมือนเงื่อนไขอื่นๆ
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        
        // ใช้ scale factor เดียวสำหรับทุกอย่าง เพื่อคงสัดส่วน
        final scaleFactor = (availableHeight / 400).clamp(0.3, 1.5);
        
        // ขนาดพื้นฐาน (base size) ที่ออกแบบไว้สำหรับ 400px
        final smallIconSize = 55.0 * scaleFactor;
        final titleFontSize = 30.0 * scaleFactor;
        final contentPadding = 12.0 * scaleFactor;
        final spacing = 8.0 * scaleFactor;
        final chartLabelFontSize = 10.0 * scaleFactor;
        final reservedSizeBottom = 28.0 * scaleFactor;
        final reservedSizeLeft = 32.0 * scaleFactor;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(8 * scaleFactor),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(contentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Row: Small Icon (left) + Title (next to icon)
                Row(
                  children: [
                    // Small icon from database (left corner)
                    Image.network(
                      path,
                      width: smallIconSize,
                      height: smallIconSize,
                      color: color,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.scatter_plot,
                          size: smallIconSize,
                          color: color,
                        );
                      },
                    ),
                    SizedBox(width: spacing),
                    // Title next to icon
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: spacing),
                
                // 2. Center Content: Scatter Chart (centered)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: contentPadding),
                    child: ScatterChart(
                      ScatterChartData(
                        scatterSpots: (values).expand((s) {
                          final dataPoints = (s['data'] as List)
                              .map((p) => ScatterSpot(
                                    (p['dx'] as num).toDouble(),
                                    (p['dy'] as num).toDouble(),
                                  ))
                              .toList();
                          return dataPoints;
                        }).toList(),
                        minX: 0,
                        maxX: 40,
                        minY: 0,
                        maxY: 20,
                        gridData: const FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          drawHorizontalLine: true,
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: reservedSizeLeft,
                              getTitlesWidget: (value, meta) => Text(
                                value.toStringAsFixed(1),
                                style: TextStyle(fontSize: chartLabelFontSize),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: reservedSizeBottom,
                              getTitlesWidget: (value, meta) => Text(
                                value.toStringAsFixed(1),
                                style: TextStyle(fontSize: chartLabelFontSize),
                              ),
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: spacing),
              ],
            ),
          ),
        );
      },
    ),
  );

    } else if (type == '7') {
  // Type 7: Button
  bool isOn = value == 1 ? true : false;
  
  return Container(
    width: sizewidth,
    height: sizeheight,
    padding: const EdgeInsets.all(4),
    child: LayoutBuilder(
      builder: (context, constraints) {
        // คำนวณขนาดตามพื้นที่ที่มี - เหมือนเงื่อนไขอื่นๆ
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        
        // ใช้ scale factor เดียวสำหรับทุกอย่าง เพื่อคงสัดส่วน
        final scaleFactor = (availableHeight / 400).clamp(0.3, 1.5);
        
        // ขนาดพื้นฐาน (base size) ที่ออกแบบไว้สำหรับ 400px
        final smallIconSize = 55.0 * scaleFactor;
        final largeIconSize = 140.0 * scaleFactor;
        final titleFontSize = 30.0 * scaleFactor;
        final buttonFontSize = 36.0 * scaleFactor;
        final contentPadding = 12.0 * scaleFactor;
        final spacing = 8.0 * scaleFactor;
        final buttonBorderRadius = 28.0 * scaleFactor; // คูณกับ scaleFactor เพื่อรักษาสัดส่วน
        final buttonPaddingH = 48.0 * scaleFactor;
        final buttonPaddingV = 24.0 * scaleFactor;
        final buttonMinWidth = 140.0 * scaleFactor;
        final bottomSpacing = 20.0 * scaleFactor; // ระยะห่างด้านล่างเพิ่มขึ้น
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(8 * scaleFactor),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(contentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Row: Small Icon (left) + Title (next to icon)
                Row(
                  children: [
                    // Small icon from database (left corner)
                    Image.network(
                      path,
                      width: smallIconSize,
                      height: smallIconSize,
                      color: color,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.power_settings_new,
                          size: smallIconSize,
                          color: color,
                        );
                      },
                    ),
                    SizedBox(width: spacing),
                    // Title next to icon
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                // 2. Center Content: Large Icon (centered)
                Expanded(
                  child: Center(
                    child: Image.network(
                      path,
                      width: largeIconSize,
                      height: largeIconSize,
                      color: isOn ? color : Colors.grey[400],
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.power_settings_new,
                          size: largeIconSize,
                          color: isOn ? color : Colors.grey[400],
                        );
                      },
                    ),
                  ),
                ),
                
                SizedBox(height: spacing),
                
                // 3. Bottom: Button (centered)
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: buttonMinWidth,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOn ? color : Colors.grey[300],
                        foregroundColor: isOn ? Colors.white : Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(buttonBorderRadius),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: buttonPaddingH,
                          vertical: buttonPaddingV,
                        ),
                        minimumSize: Size(buttonMinWidth, 0),
                      ),
                      onPressed: () {
                        setState(() {
                          String x = isOn ? "0" : "1";
                          widget.onValueChanged('m_value', x);
                        });
                      },
                      child: Text(
                        isOn ? 'ON' : 'OFF',
                        style: TextStyle(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: bottomSpacing), // เพิ่มระยะห่างด้านล่าง
              ],
            ),
          ),
        );
      },
    ),
  );

    } else if (type == '8') {
  // Type 8: Slide Bar value - Humidity style layout
  return Container(
    width: sizewidth,
    height: sizeheight,
    padding: const EdgeInsets.all(4),
    child: LayoutBuilder(
      builder: (context, constraints) {
        // คำนวณขนาดตามพื้นที่ที่มี
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        
        // ใช้ scale factor เดียวสำหรับทุกอย่าง เพื่อคงสัดส่วน
        final scaleFactor = (availableHeight / 400).clamp(0.3, 1.5);
        
        // ขนาดพื้นฐาน (base size) ที่ออกแบบไว้สำหรับ 400px
        final smallIconSize = 55.0 * scaleFactor;
        final largeIconSize = 140.0 * scaleFactor;
        final titleFontSize = 30.0 * scaleFactor;
        final valueFontSize = 60.0 * scaleFactor;
        final contentPadding = 12.0 * scaleFactor;
        final spacing = 40.0 * scaleFactor;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(8 * scaleFactor),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(contentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Row: Small Icon (left) + Title (next to icon)
                Row(
                  children: [
                    // Small icon from database (left corner)
                    Image.network(
                      path,
                      width: smallIconSize,
                      height: smallIconSize,
                      color: color,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.tune,
                          size: smallIconSize,
                          color: color,
                        );
                      },
                    ),
                    SizedBox(width: spacing),
                    // Title next to icon
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                // 2. Center Content: Large Icon (centered)
                Expanded(
                  child: Center(
                    child: Image.network(
                      path,
                      width: largeIconSize,
                      height: largeIconSize,
                      color: color,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.tune,
                          size: largeIconSize,
                          color: color,
                        );
                      },
                    ),
                  ),
                ),
                
                // 3. Slider Section
                Container(
                  padding: EdgeInsets.symmetric(horizontal: spacing),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: Slider(
                          value: value,
                          min: 0,
                          max: 100,
                          divisions: 40,
                          activeColor: color,
                          inactiveColor: Colors.grey.shade300,
                          onChanged: (value) {},
                        ),
                      ),
                      SizedBox(width: spacing),
                      Container(
                        width: 80 * scaleFactor,
                        alignment: Alignment.center,
                        child: Text(
                          value.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: valueFontSize * 0.7,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 4. Range Label
                Center(
                  child: Text(
                    'Range 0 to 100',
                    style: TextStyle(
                      fontSize: 12 * scaleFactor,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: spacing),
              ],
            ),
          ),
        );
      },
    ),
  );

    } else if (type == '9') {
  // Type 9: Lamp
  return Container(
    width: sizewidth,
    height: sizeheight,
    padding: const EdgeInsets.all(4),
    child: LayoutBuilder(
      builder: (context, constraints) {
        // คำนวณขนาดตามพื้นที่ที่มี - เหมือนเงื่อนไขที่ 2
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        
        // ใช้ scale factor เดียวสำหรับทุกอย่าง เพื่อคงสัดส่วน
        final scaleFactor = (availableHeight / 400).clamp(0.3, 1.5);
        
        // ขนาดพื้นฐาน (base size) ที่ออกแบบไว้สำหรับ 400px
        final smallIconSize = 55.0 * scaleFactor;
        final lampSize = 140.0 * scaleFactor;
        final titleFontSize = 30.0 * scaleFactor;
        final statusFontSize = 36.0 * scaleFactor;
        final contentPadding = 12.0 * scaleFactor;
        final spacing = 8.0 * scaleFactor;
        final bottomSpacing = 30.0 * scaleFactor; // เพิ่มระยะห่างด้านล่าง
        
        return Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(8 * scaleFactor),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(contentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Header Row: Small Icon + Title
                  Row(
                    children: [
                      // Small icon from database
                      Image.network(
                        path,
                        width: smallIconSize,
                        height: smallIconSize,
                        color: color,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.lightbulb,
                            size: smallIconSize,
                            color: color,
                          );
                        },
                      ),
                      SizedBox(width: spacing),
                      // Title next to icon
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  // 2. Center Content: Lamp GIF + Status
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Lamp GIF อยู่ตรงกลาง
                        Image.asset(
                          'assets/images/Lamp-${value == 1 ? "2" : "4"}-1.gif',
                          width: lampSize,
                          height: lampSize,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.lightbulb_outline,
                              size: lampSize,
                              color: value == 1 ? Colors.yellow : Colors.grey,
                            );
                          },
                        ),
                        SizedBox(height: spacing * 2),
                        // Status Text อยู่ด้านล่าง
                        Text(
                          value == 1 ? "ON" : "OFF",
                          style: TextStyle(
                            color: value == 1 ? color : const Color(0xFF555555),
                            fontSize: statusFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: spacing), // ใช้ bottomSpacing แทน spacing
                ],
              ),
            ),
          ),
        );
      },
    ),
  );

    } else if (type == '10') {
  // Type 10: Switch
  bool isOn = value == 1 ? true : false;
  return Container(
    width: sizewidth,
    height: sizeheight,
    padding: const EdgeInsets.all(4),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        
        // ใช้ scale factor เดียวสำหรับทุกอย่าง เพื่อคงสัดส่วน
        final scaleFactor = (availableHeight / 400).clamp(0.3, 1.5);
        
        // ขนาดพื้นฐาน (base size) ที่ออกแบบไว้สำหรับ 400px
        final smallIconSize = 55.0 * scaleFactor;
        final largeIconSize = 140.0 * scaleFactor;
        final titleFontSize = 30.0 * scaleFactor;
        final statusFontSize = 60.0 * scaleFactor;
        final contentPadding = 12.0 * scaleFactor;
        final spacing = 8.0 * scaleFactor;
        final switchScale = 1.5 * scaleFactor;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(8 * scaleFactor),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(contentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Row: Small Icon (left) + Title (next to icon)
                Row(
                  children: [
                    // Small icon from database (left corner)
                    Image.network(
                      path,
                      width: smallIconSize,
                      height: smallIconSize,
                      color: color,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.power_settings_new,
                          size: smallIconSize,
                          color: color,
                        );
                      },
                    ),
                    SizedBox(width: spacing),
                    // Title next to icon
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // 2. Center Content: Switch (centered)
                Expanded(
                  child: Center(
                    child: Transform.scale(
                      scale: switchScale,
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
                ),
                // 3. Bottom: Status (centered)
                Center(
                  child: Text(
                    value == 1 ? 'ON' : 'OFF',
                    style: TextStyle(
                      fontSize: statusFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(height: spacing),
              ],
            ),
          ),
        );
      },
    ),
  );

    } else if (type == '11') {
  // Type 11: Blink blink - adjusted layout similar to Type 1
  return Container(
    width: sizewidth,
    height: sizeheight,
    padding: const EdgeInsets.all(4),
    child: LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available size for scaling
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        
        // Use the same scale factor for consistency
        final scaleFactor = (availableHeight / 400).clamp(0.3, 1.5);
        
        // Basic size values adjusted for scaling
        final smallIconSize = 55.0 * scaleFactor;
        final largeIconSize = 140.0 * scaleFactor;
        final titleFontSize = 30.0 * scaleFactor;
        final valueFontSize = 60.0 * scaleFactor; // Adjusted value font size
        final contentPadding = 12.0 * scaleFactor;
        final spacing = 8.0 * scaleFactor;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(8 * scaleFactor),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(contentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Row: Small Icon (left) + Title (next to icon)
                Row(
                  children: [
                    // Small icon from database (left corner)
                    Image.network(
                      path,
                      width: smallIconSize,
                      height: smallIconSize,
                      color: color,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.thermostat,
                          size: smallIconSize,
                          color: color,
                        );
                      },
                    ),
                    SizedBox(width: spacing),
                    // Title next to icon
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // 2. Center Content: Blink Image (centered)
                Expanded(
                  child: Center(
                    child: ColorFiltered(
                      colorFilter: value == 0
                          ? const ColorFilter.mode(Color.fromARGB(255, 255, 255, 255), BlendMode.saturation)
                          : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                      child: Image.asset(
                        'assets/images/blink_${value == 1 ? '1' : '0'}.gif',
                        width: largeIconSize,
                        height: largeIconSize,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                // 3. Bottom: Value (centered)
                Center(
                  child: Text(
                    value == 1 ? 'ON' : 'OFF',
                    style: TextStyle(
                      fontSize: valueFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(height: spacing),
              ],
            ),
          ),
        );
      },
    ),
  );

    } else if (type == '12') {
  // Type 12: Bar Chart to follow similar structure to Type 5 (Linear Chart)
  final rawLabel = jsonDecode(labelJson);
  final rawValue = jsonDecode(valueJson);

  final values = List.generate(rawValue.length, (index) {
    return safeParse(rawValue[index][0]);
  });

  final maxValue = values.reduce(max);

  return Container(
    width: sizewidth,
    height: sizeheight,
    padding: const EdgeInsets.all(4),
    child: LayoutBuilder(
      builder: (context, constraints) {
        // Calculate size factor based on available height and width
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;

        // Use scale factor for consistent sizing
        final scaleFactor = (availableHeight / 400).clamp(0.3, 1.5);

        // Basic size calculations
        final smallIconSize = 55.0 * scaleFactor;
        final titleFontSize = 30.0 * scaleFactor;
        final contentPadding = 12.0 * scaleFactor;
        final spacing = 8.0 * scaleFactor;
        final chartLabelFontSize = 10.0 * scaleFactor;
        final reservedSizeBottom = 25.0 * scaleFactor;
        final reservedSizeLeft = 40.0 * scaleFactor;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8 * scaleFactor)),
          ),
          child: Padding(
            padding: EdgeInsets.all(contentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row: Small Icon (left) + Title (next to icon)
                Row(
                  children: [
                    Image.network(
                      path,
                      width: smallIconSize,
                      height: smallIconSize,
                      color: color,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.show_chart,
                          size: smallIconSize,
                          color: color,
                        );
                      },
                    ),
                    SizedBox(width: spacing),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: spacing),

                // Center Content: Bar Chart (centered)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: contentPadding),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: reservedSizeBottom,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < rawLabel.length) {
                                  return Text(
                                    rawLabel[index],
                                    style: TextStyle(fontSize: chartLabelFontSize),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: reservedSizeLeft,
                              getTitlesWidget: (value, meta) => Text(
                                'V ${value.toStringAsFixed(0)}',
                                style: TextStyle(fontSize: chartLabelFontSize),
                              ),
                            ),
                          ),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        barGroups: List.generate(rawValue.length, (index) {
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: double.parse(rawValue[index][0]),
                                color: color,
                                width: 25,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
    } else {
      return const Text("Unknown type");
    }
  }
}