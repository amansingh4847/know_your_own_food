import 'package:flutter/material.dart';
import 'package:know_your_own_food/scan_page.dart';
import 'package:know_your_own_food/model_scan_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text("KYOF"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.orange,
        actions: [
    IconButton(
      icon: Icon(Icons.info_outline),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("About KYOF", style: TextStyle(color: Colors.orange),),
              backgroundColor: Color(0xFF121212),

              content: Text(
                "This app detects food and shows nutritional values, There are 2 main aproaches.\n\n1. API handels all functions\n2. Our Custom ML Model Handels all Function\n\nFor Feedback and Queries\nContact: amansingh484748@gmail.com",
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      },
    ),
  ],
        ),

        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40,),
              ElevatedButton(onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> ScanPage()));
              },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                ),
                child: Text("Scan Food Using API", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                ),

                const SizedBox(height: 40,),

                ElevatedButton(onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> ModelScanPage()));
              },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                ),
                child: Text("Scan Food using Model", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                ),
            ],
          ),
        ),
    );
  }
}
