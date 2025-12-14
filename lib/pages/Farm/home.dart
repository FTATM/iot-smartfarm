import 'package:flutter/material.dart';
import 'package:iot_app/components/session.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Map<String, dynamic> user;

  @override
  void initState() {
    super.initState();
    user = CurrentUser;
  }

  @override
  Widget build(BuildContext context) {
    final maxwidth = MediaQuery.of(context).size.width;
    final maxheight = MediaQuery.of(context).size.height - kTextTabBarHeight;
    return Scaffold(
      floatingActionButton: Visibility(
        visible: int.parse(CurrentUser['role_id']) >= 88,
        child: FloatingActionButton(
          onPressed: () {
            // Navigator.push(context, MaterialPageRoute(builder: (context) => MainboardCreatePage())).then((_) {
            // });
          },
          backgroundColor: Colors.white,
          child: Icon(Icons.edit),
        ),
      ),
      body: SafeArea(
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Colors.amber,
                  width: maxwidth,
                  height: 200,
                  child: Center(
                    child: Container(
                      width: maxwidth * 0.8,
                      height: 200 * 0.7,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text("Temperature"),
                    ),
                  ),
                ),
                Container(
                  color: Colors.purple,
                  width: maxwidth,
                  height: maxheight * 0.7,
                  child: Align(
                    alignment: AlignmentGeometry.bottomCenter,
                    child: Container(
                      width: maxwidth,
                      decoration: BoxDecoration(color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24))
                      ),
                      height: maxheight * 0.6,
                      child: Text("data"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
