import 'package:flutter/material.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan Food")),
      body: Center(
        child: Text(
          "Camera / Scanner will open here",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
