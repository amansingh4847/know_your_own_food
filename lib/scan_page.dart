import 'package:flutter/material.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

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