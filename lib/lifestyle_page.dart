import 'package:flutter/material.dart';

class LifestylePage extends StatelessWidget {
  const LifestylePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text("Lifestyle",style: TextStyle(color: Colors.orange),),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text("Lifestyle Page (Login later)", style: TextStyle(color: Colors.orange),),
      ),
    );
  }
}