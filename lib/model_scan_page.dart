import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:flutter/services.dart';

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

  final List<String> labels = [
    "Aloo_Gobhi","Aloo_mattar","Biryani","Chapati","Banana",
    "Chutney","Dal","Dal","Dosa","dal",
    "Idli","Eggs","Orange","Naan","Paneer_curry",
    "Paratha","Puri","Pav","Rice"
  ];

  @override
  void initState() {
    super.initState();
    loadModel();
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

    interpreter.run(input.reshape([1,640,640,3]), output);

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

        // keep highest score only (no duplicates)
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              child: const Text("Model scan", style: TextStyle(color: Colors.white)),
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
          ],
        ),
      ),
    );
  }
}