import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'dart:convert'; // ✅ ADDED

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

  // ✅ ADDED
  List<dynamic> nutritionData = [];
  Map<String, Map<String, dynamic>?> nutritionMap = {};

  final List<String> labels = [
    "Aloo_Gobhi",
    "Aloo_mattar",
    "Biryani",
    "Chapati",
    "Banana",
    "Chutney",
    "Dal",
    "Dal",
    "Dosa",
    "Dal",
    "Idli",
    "Eggs",
    "Orange",
    "Naan",
    "Paneer_curry",
    "Paratha",
    "Puri",
    "Pav",
    "Rice",
  ];

  @override
  void initState() {
    super.initState();
    loadModel();
    loadNutrition(); // ✅ ADDED
  }

  // ✅ ADDED
  Future<void> loadNutrition() async {
    final String jsonString = await rootBundle.loadString(
      'assets/nutrition.json',
    );
    nutritionData = json.decode(jsonString);
  }

  // ✅ ADDED
  Map<String, dynamic>? getNutrition(String foodName) {
    for (var item in nutritionData) {
      if (item["name"] == foodName) {
        return item;
      }
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
        nutritionMap.clear(); // ✅ ADDED
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

        if (!uniqueResults.containsKey(label) || uniqueResults[label]! < best) {
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

      // ✅ ADDED
      nutritionMap.clear();
      for (var d in detections) {
        nutritionMap[d.label] = getNutrition(d.label);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Model Scan"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // IMAGE
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

            // BUTTONS
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
              child: const Text(
                "Model scan",
                style: TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 20),

            // RESULTS
            detections.isEmpty
                ? const Text("No food detected")
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: detections.map((d) {
                      return Chip(
                        label: Text(
                          "${d.label} (${d.score.toStringAsFixed(2)})",
                        ),
                        backgroundColor: Colors.green.shade100,
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 20),

            // ✅ ADDED NUTRITION UI
            Expanded(
              child: ListView(
                children: detections.map((d) {
                  final nutrition = nutritionMap[d.label];

                  if (nutrition == null) {
                    return Text("${d.label}: No data");
                  }

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        Text(
                          "⚠️ Values are estimated and based on 100g serving.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          d.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          "Calories: ${nutrition["calories"]}",
                          style: const TextStyle(color: Colors.white),
                        ),

                        Text(
                          "Protein: ${nutrition["protein"]}g",
                          style: const TextStyle(color: Colors.white),
                        ),

                        Text(
                          "Carbs: ${nutrition["carbs"]}g",
                          style: const TextStyle(color: Colors.white),
                        ),

                        Text(
                          "Fat: ${nutrition["fat"]}g",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
