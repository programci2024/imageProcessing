import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:steganography/utils/Random/generateRandomDifferenceImage.dart';
import 'package:steganography/utils/Random/hideTextRandomly.dart';
import 'package:steganography/utils/saveImage.dart';
import 'dart:typed_data';

import 'package:steganography/widgets/custom_drawer.dart';

class HideTextRandomlyScreen extends StatefulWidget {
  @override
  _HideTextRandomlyScreenState createState() => _HideTextRandomlyScreenState();
}

class _HideTextRandomlyScreenState extends State<HideTextRandomlyScreen> {
  Uint8List? _originalImageBytes;
  Uint8List? _modifiedImageBytes;
  String _hiddenText = "";
  String? _savedImagePath;
  final ImagePicker _picker = ImagePicker();
  final int _seed = 12345; // Random seed for position generation

  Future<void> _pickImage() async {
    final XFile? imageFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      setState(() {
        _originalImageBytes = imageBytes;
        _modifiedImageBytes = null;
      });
    }
  }

  void _hideText() {
    if (_originalImageBytes == null || _hiddenText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please load an image and enter text to hide.")),
      );
      return;
    }

    final result = hideTextRandomly(_originalImageBytes!, _hiddenText, _seed);
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Text too long to fit in the image!")),
      );
    } else {
      setState(() {
        _modifiedImageBytes = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Text successfully hidden in the image.")),
      );
    }
  }

  Future<void> _saveImage() async {
    if (_modifiedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No encrypted image to save.")),
      );
      return;
    }

    final path = await saveImageRandom(_modifiedImageBytes!);
    if (path != null) {
      setState(() {
        _savedImagePath = path;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image saved to $path")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save the image.")),
      );
    }
  }

  void _showDifferences() {
    if (_originalImageBytes == null || _modifiedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Both original and modified images are required.")),
      );
      return;
    }

    final differenceImage = generateRandomDifferenceImage(
        _originalImageBytes!, _modifiedImageBytes!, _seed);

    if (differenceImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to generate difference image.")),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Random Differences"),
            content: Image.memory(differenceImage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Close"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(title: Text("Hide Text Randomly")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                child: Row(
                  children: [
                    Expanded(
                      child: _originalImageBytes != null
                          ? Image.memory(
                              _originalImageBytes!,
                              width: 200,
                              height: 200,
                              fit: BoxFit.contain,
                            )
                          : Container(
                              width: 200,
                              height: 200,
                              color: Colors.grey[300],
                              child: Center(child: Text("Original Image")),
                            ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _modifiedImageBytes != null
                          ? Image.memory(
                              _modifiedImageBytes!,
                              width: 200,
                              height: 200,
                              fit: BoxFit.contain,
                            )
                          : Container(
                              width: 200,
                              height: 200,
                              color: Colors.grey[300],
                              child: Center(child: Text("Modified Image")),
                            ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(onPressed: _pickImage, child: Text("Add Image")),
              TextField(
                decoration: InputDecoration(labelText: "Enter Text to Hide"),
                onChanged: (text) {
                  _hiddenText = text;
                },
              ),
              SizedBox(height: 15),
              ElevatedButton(onPressed: _hideText, child: Text("Encrypt")),
              ElevatedButton(onPressed: _saveImage, child: Text("Save Image")),
              ElevatedButton(
                  onPressed: _showDifferences, child: Text("Show Differences")),
            ],
          ),
        ),
      ),
    );
  }
}
