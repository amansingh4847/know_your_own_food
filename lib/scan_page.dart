import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:know_your_own_food/secrets/api_keys.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File? image;

  String calories = "";
  String protein = "";
  String fat = "";
  String carbs = "";

  bool showSheet = false;

  final picker = ImagePicker();
  List<String> detectedTags = [];

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);

        // reset old data
        detectedTags.clear();
        calories = protein = fat = carbs = "";
        showSheet = false;
      });
    }
  }

  Future<void> sendToImagga() async {
    if (image == null) return;

    const apiKey = ApiKeys.imaggaApiKey;
    const apiSecret = ApiKeys.imaggaApiSecret;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("https://api.imagga.com/v2/tags"),
    );

    request.headers['Authorization'] =
        'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}';

    request.files.add(await http.MultipartFile.fromPath('image', image!.path));

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    final data = jsonDecode(responseBody);

    List tags = data["result"]["tags"];

    detectedTags = tags
        .map<String>((tag) => tag["tag"]["en"].toString())
        .take(3)
        .toList();

    String mainFood = pickMainFood(detectedTags);

    await getNutritionFromSpoonacular(mainFood);

    setState(() {});
  }

  String pickMainFood(List<String> tags) {
    List<String> ignoreWords = [
      "food",
      "meal",
      "dish",
      "lunch",
      "dinner",
      "snack",
      "plate",
      "delicious",
      "fresh",
    ];

    for (String tag in tags) {
      bool isIgnored = ignoreWords.any((word) => tag.contains(word));
      if (!isIgnored) {
        return tag;
      }
    }
    return tags.isNotEmpty ? tags.first : "food";
  }

  Future<void> getNutritionFromSpoonacular(String food) async {
    const apiKey = ApiKeys.spoonacularApi;

    final encodedFood = Uri.encodeComponent(food);

    final url =
        "https://api.spoonacular.com/recipes/guessNutrition?title=$encodedFood&apiKey=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      calories = data["calories"]["value"].toString();
      protein = data["protein"]["value"].toString();
      fat = data["fat"]["value"].toString();
      carbs = data["carbs"]["value"].toString();

      // 🔥 SHOW SHEET (persistent)
      setState(() {
        showSheet = true;
      });
    }
  }

  Widget nutrientTile(String title, String value) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: Text(
          value,
          style: const TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Scan Food"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.orange,
      ),

      body: Stack(
        children: [

          // 🔹 MAIN UI
          Column(
            children: [
              const SizedBox(height: 20),

              SizedBox(
                height: 200,
                width: 200,
                child: image != null
                    ? Image.file(image!)
                    : const Center(child: Text("NO Image selected",
                    style: TextStyle(color: Colors.white),)),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => pickImage(ImageSource.camera),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.orange,
                    ),
                    child: const Text("Camera"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => pickImage(ImageSource.gallery),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.orange,
                    ),
                    child: const Text("Gallery"),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: image == null ? null : sendToImagga,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                ),
                child: const Text("Scan"),
              ),

              const SizedBox(height: 20),

              detectedTags.isEmpty
                  ? const Text("No tags detected yet",
                  style: TextStyle(color: Colors.white),)
                  : Wrap(
                      spacing: 8,
                      children: detectedTags.map((tag) {
                        return Chip(label: Text(tag,style: TextStyle(color: Colors.black),),
                        backgroundColor: Colors.orange,
                        side: BorderSide.none,
                        );
                      }).toList(),
                    ),
            ],
          ),

          // 🔥 PERSISTENT DRAGGABLE BOTTOM SHEET
          if (showSheet)
            DraggableScrollableSheet(
              initialChildSize: 0.15, // always visible
              minChildSize: 0.15,     // cannot close
              maxChildSize: 0.85,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [

                      // Drag handle
                      Center(
                        child: Container(
                          width: 50,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const Text(
                        "Nutrients",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // if (image != null)
                      //   ClipRRect(
                      //     borderRadius: BorderRadius.circular(15),
                      //     child: Image.file(image!, height: 150, fit: BoxFit.cover),
                      //   ),

                      const SizedBox(height: 20),

                      nutrientTile("Calories", "$calories kcal"),
                      nutrientTile("Protein", "$protein g"),
                      nutrientTile("Fat", "$fat g"),
                      nutrientTile("Carbs", "$carbs g"),

                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}