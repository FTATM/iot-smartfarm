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
        child: SingleChildScrollView(child: Column(children: [

          ],
        )),
      ),
    )
    );
  }
}
