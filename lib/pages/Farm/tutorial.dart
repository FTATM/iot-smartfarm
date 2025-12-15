import 'package:flutter/material.dart';
import 'package:iot_app/components/session.dart';

class TutorialPage extends StatefulWidget {

  const TutorialPage({super.key, });

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final maxwidth = MediaQuery.of(context).size.width;
    final maxheight = MediaQuery.of(context).size.height - kTextTabBarHeight;
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          width: maxwidth,
          height: maxheight ,
          child: SingleChildScrollView(
            child: Column(
              children: [

              ],
            ),
          ),
        ),
      ),
    );
  }
}
