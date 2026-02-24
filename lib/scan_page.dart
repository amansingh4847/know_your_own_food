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
  //image file
  File? image;

  String calories = "";
  String protein = "";
  String fat = "";
  String carbs = "";

  //image picker
  final picker = ImagePicker();

  //pick image method
  Future<void> pickImage(ImageSource source) async {
    //pick image from cameraa or gallery
    final PickedFile = await picker.pickImage(source: source);

    //update selected image
    if (PickedFile != null) {
      setState(() {
        image = File(PickedFile!.path);
      });
    }
  }

  //list to store results
  List<String> detectedTags = [];

  //image converter
  Future<String> convertImageToBase64() async {
    final bytes = await image!.readAsBytes();
    return base64Encode(bytes);
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

    print("Status: ${response.statusCode}");
    print("Body: $responseBody");

    final data = jsonDecode(responseBody);

    List tags = data["result"]["tags"];

    detectedTags = tags
        .map<String>((tag) => tag["tag"]["en"].toString())
        .take(3) // top 5 tags only (optional)
        .toList();

    String mainFood = pickMainFood(detectedTags);
    print("Main Food: $mainFood");

    await getNutritionFromSpoonacular(mainFood);

    setState(() {});
  }

  //we need to pick main food

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
        return tag; // first valid food
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

    print("Nutrition Status: ${response.statusCode}");
    print("Nutrition Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      calories = data["calories"]["value"].toString();
      protein = data["protein"]["value"].toString();
      fat = data["fat"]["value"].toString();
      carbs = data["carbs"]["value"].toString();

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan Food")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          //image display
          SizedBox(
            height: 200,
            width: 200,
            child: image != null
                ?
                  //image selected
                  Image.file(image!)
                :
                  //no image slected
                  const Center(child: Text("NO Image selected")),
          ),

          //buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => pickImage(ImageSource.camera),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: Text("camera"),
              ),

              const SizedBox(width: 16),

              ElevatedButton(
                onPressed: () => pickImage(ImageSource.gallery),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: Text("Gallery"),
              ),
            ],
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: image == null ? null : sendToImagga,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text("OK"),
          ),

          const SizedBox(height: 20),

          detectedTags.isEmpty
              ? const Text("No tags detected yet")
              : Column(
                  children: [
                    const Text(
                      "Detected Tags",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: detectedTags.map((tag) {
                        return Chip(label: Text(tag));
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    calories.isEmpty
                        ? Container()
                        : Column(
                            children: [
                              Text("----> Per Serving <----"),
                              Text("Calories: $calories kcal"),
                              Text("Protein: $protein g"),
                              Text("Fat: $fat g"),
                              Text("Carbs: $carbs g"),
                            ],
                          ),
                  ],
                ),
        ],
      ),
    );
  }
}
