// FULL UPDATED CODE (ONLY CHANGED PARTS MARKED 🔥)

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'dart:convert';

class ModelScanPage extends StatefulWidget {
  const ModelScanPage({super.key});

  @override
  State<ModelScanPage> createState() => _ModelScanPageState();
}

class Detection {
  final String label;
  final double score;

  Detection(this.label, this.score);
}

class _ModelScanPageState extends State<ModelScanPage> {
  File? image;
  final picker = ImagePicker();

  late Interpreter interpreter;
  bool isModelLoaded = false;

  List<Detection> detections = [];

  List<dynamic> nutritionData = [];
  Map<String, Map<String, dynamic>?> nutritionMap = {};

  // 🔥 NEW
  bool showSheet = false;

  final List<String> labels = [
    "Aloo_Gobhi","Aloo_mattar","Biryani","Chapati","Banana","Chutney",
    "Dal","Dal","Dosa","Dal","Idli","Eggs","Orange","Naan",
    "Paneer_curry","Paratha","Puri","Pav","Rice",
  ];

  @override
  void initState() {
    super.initState();
    loadModel();
    loadNutrition();
  }

  Future<void> loadNutrition() async {
    final String jsonString =
        await rootBundle.loadString('assets/nutrition.json');
    nutritionData = json.decode(jsonString);
  }

  Map<String, dynamic>? getNutrition(String foodName) {
    for (var item in nutritionData) {
      if (item["name"] == foodName) return item;
    }
    return null;
  }

  Future<void> loadModel() async {
    final data = await rootBundle.load('assets/model/best.tflite');
    interpreter = Interpreter.fromBuffer(data.buffer.asUint8List());
    setState(() => isModelLoaded = true);
  }

  Future<void> pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      setState(() {
        image = File(picked.path);
        detections.clear();
        nutritionMap.clear();
        showSheet = false; // 🔥 reset sheet
      });
    }
  }

  Float32List preprocess(img.Image image) {
    final resized = img.copyResize(image, width: 640, height: 640);
    final input = Float32List(1 * 640 * 640 * 3);

    int i = 0;
    for (int y = 0; y < 640; y++) {
      for (int x = 0; x < 640; x++) {
        final p = resized.getPixel(x, y);
        input[i++] = p.r / 255.0;
        input[i++] = p.g / 255.0;
        input[i++] = p.b / 255.0;
      }
    }
    return input;
  }

  Future<void> runModel() async {
    if (image == null || !isModelLoaded) return;

    final bytes = await image!.readAsBytes();
    final original = img.decodeImage(bytes)!;

    final input = preprocess(original);

    var output = List.generate(
      1,
      (_) => List.generate(23, (_) => List.filled(8400, 0.0)),
    );

    interpreter.run(input.reshape([1, 640, 640, 3]), output);

    Map<String, double> uniqueResults = {};

    for (int i = 0; i < 8400; i++) {
      int cls = -1;
      double best = 0;

      for (int c = 5; c < 23; c++) {
        if (output[0][c][i] > best) {
          best = output[0][c][i];
          cls = c - 5;
        }
      }

      if (best > 0.5) {
        String label = labels[cls];

        if (!uniqueResults.containsKey(label) ||
            uniqueResults[label]! < best) {
          uniqueResults[label] = best;
        }
      }
    }

    List<Detection> results = uniqueResults.entries
        .map((e) => Detection(e.key, e.value))
        .toList();

    results.sort((a, b) => b.score.compareTo(a.score));

    setState(() {
      detections = results;

      nutritionMap.clear();
      for (var d in detections) {
        nutritionMap[d.label] = getNutrition(d.label);
      }

      showSheet = true; // 🔥 SHOW SHEET AFTER MODEL RUN
    });
  }

  Widget nutrientTile(String title, String value) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Text(
        value,
        style: const TextStyle(color: Colors.orange),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Model Scan"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),

      // 🔥 STACK (IMPORTANT)
      body: Stack(
        children: [

          // MAIN UI
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(image!, fit: BoxFit.cover),
                        )
                      : const Center(child: Text("No image selected")),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => pickImage(ImageSource.camera),
                      child: const Text("Camera"),
                    ),
                    ElevatedButton(
                      onPressed: () => pickImage(ImageSource.gallery),
                      child: const Text("Gallery"),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: runModel,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: const Text("Model Scan",
                      style: TextStyle(color: Colors.white)),
                ),

                const SizedBox(height: 20),

                detections.isEmpty
                    ? const Text("No food detected")
                    : Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: detections.map((d) {
                          return Chip(
                            label: Text(
                                "${d.label} (${d.score.toStringAsFixed(2)})"),
                          );
                        }).toList(),
                      ),
              ],
            ),
          ),

          // 🔥 PERSISTENT BOTTOM SHEET
          if (showSheet)
            DraggableScrollableSheet(
              initialChildSize: 0.15,
              minChildSize: 0.15,
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

                      // drag handle
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
                          color: Colors.orange,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // if (image != null)
                      //   ClipRRect(
                      //     borderRadius: BorderRadius.circular(15),
                      //     child: Image.file(image!, height: 150, fit: BoxFit.cover),
                      //   ),

                      const SizedBox(height: 20),

                      // 🔥 MULTI FOOD NUTRITION
                      ...detections.map((d) {
                        final n = nutritionMap[d.label];

                        if (n == null) {
                          return Text("${d.label}: No data",
                              style: TextStyle(color: Colors.white));
                        }

                        return Card(
                          color: Colors.grey[900],
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(d.label,
                                    style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold)),

                                nutrientTile("Calories", "${n["calories"]}"),
                                nutrientTile("Protein", "${n["protein"]}g"),
                                nutrientTile("Carbs", "${n["carbs"]}g"),
                                nutrientTile("Fat", "${n["fat"]}g"),
                              ],
                            ),
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 20),

                      const Text(
                        "⚠️ Values are estimated per 100g",
                        style: TextStyle(color: Colors.grey),
                      ),
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