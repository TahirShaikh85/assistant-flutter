import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

class GoogleLensPage extends StatefulWidget {
  const GoogleLensPage({super.key});

  @override
  State<GoogleLensPage> createState() => _GoogleLensPageState();
}

class _GoogleLensPageState extends State<GoogleLensPage> {
  String extractedText = "";
  File? _imageFile;
  bool isProcessing = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    // Request necessary permissions
    if (source == ImageSource.camera) {
      await Permission.camera.request();
    } else {
      await Permission.photos.request();
    }

    final XFile? pickedImage = await _picker.pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
        extractedText = ""; // Reset
      });
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => Container(
            color: Colors.black,
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera, color: Colors.blue),
                  title: const Text(
                    "Camera",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo, color: Colors.blue),
                  title: const Text(
                    "Gallery",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _extractTextFromImage() async {
    if (_imageFile == null) return;

    setState(() => isProcessing = true);

    final inputImage = InputImage.fromFile(_imageFile!);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      await textRecognizer.close();

      print("🧠 Extracted Text: ${recognizedText.text}");

      setState(() {
        extractedText =
            recognizedText.text.isNotEmpty
                ? recognizedText.text
                : "⚠️ No text found in the image.";
      });
    } catch (e) {
      print("❌ Error during text recognition: $e");
      setState(() {
        extractedText = "❌ Error extracting text.";
      });
    } finally {
      setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Google Lens",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image section
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                    elevation: 3,
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            "Image",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.blue, fontSize: 22),
                          ),
                        ),
                        GestureDetector(
                          onTap: _showImageSourceOptions,
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            height: 448,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey),
                              image:
                                  _imageFile != null
                                      ? DecorationImage(
                                        image: FileImage(_imageFile!),
                                        fit: BoxFit.cover,
                                      )
                                      : null,
                            ),
                            child:
                                _imageFile == null
                                    ? const Center(
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 60,
                                        color: Colors.grey,
                                      ),
                                    )
                                    : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Show extracted text
                  if (extractedText.isNotEmpty || isProcessing) ...[
                    const Text(
                      "Extracted Text:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    isProcessing
                        ? const Center(child: CircularProgressIndicator())
                        : Text(
                          extractedText,
                          style: const TextStyle(fontSize: 16),
                        ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Button
          Padding(
            padding: const EdgeInsets.only(bottom: 37),
            child: SizedBox(
              width: 233,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  if (_imageFile != null) {
                    _extractTextFromImage();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select or capture an image"),
                      ),
                    );
                  }
                },
                child: const Text("Search"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
