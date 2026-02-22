import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {

  //image file
  File? image;

  //image picker
  final picker = ImagePicker();


  //pick image method
  Future<void> pickImage(ImageSource source) async {

    //pick image from cameraa or gallery
    final PickedFile = await picker.pickImage(source: source);

    //update selected image
    if(PickedFile != Null){
      setState(() {
        image = File(PickedFile!.path);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan Food")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //image display
            SizedBox(
              height: 300,
              width: 300,
              child: image != null ?

              //image selected
              Image.file(image!)
              :
              //no image slected
              const Center(child: Text("NO Image selected"))
            ),


            //buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ElevatedButton(onPressed: () => pickImage(ImageSource.camera),
                child: Text("camera")),

                const SizedBox(width: 16,),

                ElevatedButton(onPressed: () => pickImage(ImageSource.gallery),
                child: Text("Gallery")),

              ],
            ),
          ],
        )
      ),
    );
  }
}
