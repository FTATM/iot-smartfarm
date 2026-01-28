import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iot_app/api/apiAll.dart';
import 'package:iot_app/components/appbar.dart';
import 'package:iot_app/components/session.dart';

class HomeUpdatePage extends StatefulWidget {
  const HomeUpdatePage({super.key});

  @override
  State<HomeUpdatePage> createState() => _HomeUpdatePageState();
}

class _HomeUpdatePageState extends State<HomeUpdatePage> {
  bool isLoading = true;
  bool isEdit = false;
  String userString = "";
  Map<String, dynamic> user = {};
  Map<String, dynamic> weather = {};
  List<dynamic> data = [];
  List<dynamic> icons = [];
  List<dynamic> logos = [];
  List<dynamic> sensors = [];
  Map<String, dynamic> typeofValues = {"1": "Manual Value", "2": "Time Now", "3": "Time manual", "4": "Sensor"};

  List<TextEditingController> labelControllers = [];
  List<TextEditingController> manualController = [];

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  Future<void> _prepareData() async {
    await _fetchicons();
    await _fetchLogos();
    await _fetchmainBoard();
    await _fetchconfiguration();
    await _fetchWeathers();
    setState(() {
      user = CurrentUser;
      isLoading = false;
      labelControllers = data.map((item) => TextEditingController(text: item['label_text']?.toString() ?? '')).toList();
      manualController = data.map((item) => TextEditingController(text: item['value']?.toString() ?? '')).toList();
    });
  }

  Future<void> _fetchLogos() async {
    final response = await ApiService.fetchLogos();
    setState(() {
      logos = response['data'];
    });
  }

  Future<void> _fetchWeathers() async {
    final response = await ApiService.fetchWeathers();
    setState(() {
      weather = response['data'][0];
    });
  }

  Future<void> _fetchicons() async {
    final response = await ApiService.fetchIcons();
    setState(() {
      icons = response['data'] as List;
    });
  }

  Future<void> _fetchmainBoard() async {
    final response = await ApiService.fetchMainboard();
    setState(() {
      data = response['data'] as List;
    });
  }

  Future<void> _fetchconfiguration() async {
    final response = await ApiService.fetchConfigBybranchId(CurrentUser['branch_id']);
    setState(() {
      sensors = response['data'] as List;
    });
  }

  Widget _buildChildByCase(index, item, maxwidth) {
    switch (item['type_values_id']) {
      case "1":
        return TextField(
          controller: manualController[index],
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            labelText: "Value",
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF97316), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onChanged: (value) {
            setState(() {
              item['value'] = value;
            });
          },
        );

      case "2":
        String now = DateTime.now().toString().substring(0, 10);
        setState(() {
          item['value'] = now;
        });
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(now, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        );

      case "3":
        return Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  item['value'] ?? 'Select date',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  var pickedDate = "${picked.year}-${picked.month}-${picked.day}";
                  setState(() => item['value'] = pickedDate);
                }
              },
              child: const Text("Select"),
            ),
          ],
        );

      case "4":
        return DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF97316), width: 2),
            ),
          ),
          items: sensors.map<DropdownMenuItem<String>>((b) {
            return DropdownMenuItem(
              value: b['monitor_id'],
              child: Text("[${b['monitor_id']}] ${b['monitor_name']}", maxLines: 1, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (value) {
            item['value'] = value;
          },
        );

      default:
        return const Text("โปรดเลือกประเภท", style: TextStyle(color: Colors.grey));
    }
  }

  Widget _buildInputField({
    required String label,
    required String? initialValue,
    required Function(String) onChanged,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[600], letterSpacing: 0.5),
          ),
        ),
        TextFormField(
          initialValue: initialValue ?? "",
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF97316), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernCard({
    required String title,
    required IconData icon,
    required Widget child,
    bool showToggle = false,
    bool? toggleValue,
    Function(bool)? onToggleChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(top: BorderSide(color: Color(0xFFF97316), width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFF97316), size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (showToggle) ...[
                  Text(
                    "STATUS",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[400],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Transform.scale(
                    scale: 0.85,
                    child: Switch(
                      value: toggleValue ?? false,
                      activeColor: const Color(0xFFF97316),
                      onChanged: onToggleChanged,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFF97316))),
      );
    }

    final maxwidth = MediaQuery.of(context).size.width;

    var foundlogo = logos.where((i) => data[0]['icon_id'] == i['id']);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppbarWidget(txtt: "Edit Home"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Weather API Card
              _buildModernCard(
                title: "Weather TMD-API",
                icon: Icons.cloud,
                child: Column(
                  children: [
                    _buildInputField(
                      label: "API URL",
                      initialValue: weather['url_api'],
                      onChanged: (value) => weather['url_api'] = value,
                      hintText: "https://example.com/api",
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            label: "Latitude",
                            initialValue: weather['lat'],
                            onChanged: (value) => weather['lat'] = value,
                            hintText: "7.2021",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInputField(
                            label: "Longitude",
                            initialValue: weather['lon'],
                            onChanged: (value) => weather['lon'] = value,
                            hintText: "100.5972",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      label: "Token",
                      initialValue: weather['token'],
                      onChanged: (value) => weather['token'] = value,
                      hintText: "Enter token",
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF97316),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: const Color(0xFFF97316).withOpacity(0.3),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          // await ApiService.updateWeather(weather);
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save, size: 20),
                            SizedBox(width: 8),
                            Text("Save Changes", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              _buildModernCard(
                title: "${data[0]['id']} ${data[0]['name']}",
                icon: Icons.dashboard_customize,
                showToggle: false,
                toggleValue: data[0]['is_active'] == 't',
                onToggleChanged: (value) {
                  setState(() {
                    data[0]['is_active'] = value ? 't' : 'f';
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data[0]['icon_id'] != '0') ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                                  child: Text(
                                    "SELECT LOGO",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                DropdownButtonFormField<String>(
                                  value: data[0]['icon_id'] == '0' || foundlogo.isEmpty ? null : data[0]['icon_id'],
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFFF97316), width: 2),
                                    ),
                                  ),
                                  items: logos.map<DropdownMenuItem<String>>((logo) {
                                    return DropdownMenuItem(value: logo['id'], child: Text(logo['name']));
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() => data[0]['icon_id'] = value);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 100,
                            height: 120,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Image.network(
                                    "${user['baseURL']}../${logos.firstWhere((i) => i['id'] == data[0]['icon_id'], orElse: () => {"path": "img/logos/default.png"})['path']}",
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "PREVIEW",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[400],
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF97316),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: const Color(0xFFF97316).withOpacity(0.3),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          var response = await ApiService.updateMainboardById(data[0]);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'])));
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save, size: 20),
                            SizedBox(width: 8),
                            Text("Save Configuration", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Dynamic Data Cards
              ...data.sublist(1).asMap().entries.map((entry) {
                int index = entry.key;
                var item = entry.value;
                var foundIcon = icons.where((i) => item['icon_id'] == i['id']);

                return _buildModernCard(
                  title: "${item['id']} ${item['name']}",
                  icon: Icons.dashboard_customize,
                  showToggle: true,
                  toggleValue: item['is_active'] == 't',
                  onToggleChanged: (value) {
                    setState(() {
                      item['is_active'] = value ? 't' : 'f';
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField(
                        label: "Label",
                        initialValue: item['label_text'],
                        onChanged: (value) {
                          setState(() {
                            data[index + 1]['label_text'] = value;
                            labelControllers[index + 1].text = value;
                          });
                        },
                      ),
                      if (item['icon_id'] != '-1') ...[
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, bottom: 6),
                                    child: Text(
                                      "SELECT ICON",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[600],
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  DropdownButtonFormField<String>(
                                    value: item['icon_id'] == '-1' || foundIcon.isEmpty ? null : item['icon_id'],
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey[300]!),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey[300]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFF97316), width: 2),
                                      ),
                                    ),
                                    items: icons.map<DropdownMenuItem<String>>((icon) {
                                      return DropdownMenuItem(value: icon['id'], child: Text(icon['name']));
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() => item['icon_id'] = value);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 100,
                              height: 120,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Image.network(
                                      "${user['baseURL']}../${icons.firstWhere((i) => i['id'] == item['icon_id'], orElse: () => {"path": "img/icons/default.png"})['path']}",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "PREVIEW",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[400],
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (item['type_values_id'] != '0') ...[
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 6),
                              child: Text(
                                "TYPE",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            DropdownButtonFormField<String>(
                              value: item['type_values_id'] == "0" ? '1' : item['type_values_id'],
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFF97316), width: 2),
                                ),
                              ),
                              items: typeofValues.entries
                                  .map((entry) => DropdownMenuItem<String>(value: entry.key, child: Text(entry.value)))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  item['type_values_id'] = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 6),
                              child: Text(
                                "VALUE",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            _buildChildByCase(index + 1, item, maxwidth),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF97316),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: const Color(0xFFF97316).withOpacity(0.3),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            var response = await ApiService.updateMainboardById(item);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'])));
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save, size: 20),
                              SizedBox(width: 8),
                              Text("Save Configuration", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
