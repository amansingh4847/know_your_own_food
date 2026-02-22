import 'package:flutter/material.dart';
import 'package:know_your_own_food/scan_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
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
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                ),
                child: Text("Scan your food", style: TextStyle(color: Colors.white),),
                ),
            ],
          ),
        ),
    );
  }
}
