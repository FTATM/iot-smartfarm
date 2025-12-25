import 'package:flutter/material.dart';

class KnowledgePage extends StatefulWidget {
  const KnowledgePage({super.key});

  @override
  State<KnowledgePage> createState() => _KnowledgePageState();
}

class _KnowledgePageState extends State<KnowledgePage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    prepare();
  }

  Future<void> prepare() async {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final maxwidth = MediaQuery.of(context).size.width;
    final maxheight = MediaQuery.of(context).size.height - kTextTabBarHeight;
    return Scaffold(body: SafeArea(child: Text("Knowledge")));
  }
}
