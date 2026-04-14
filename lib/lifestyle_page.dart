import 'package:flutter/material.dart';

class LifestylePage extends StatelessWidget {
  const LifestylePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lifestyle"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text("Lifestyle Page (Login later)"),
      ),
    );
  }
}