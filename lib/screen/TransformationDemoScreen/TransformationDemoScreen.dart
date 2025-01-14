import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

import 'package:steganography/widgets/custom_drawer.dart';

class ScalingProblemScreen extends StatefulWidget {
  @override
  _ScalingProblemScreenState createState() => _ScalingProblemScreenState();
}

class _ScalingProblemScreenState extends State<ScalingProblemScreen> {
  Uint8List? _originalImageBytes;
  Uint8List? _scaledImageBytes;
  Uint8List? _differenceImageBytes;
  String _hiddenText = "";
  String? _extractedText;
  double _scalingFactor = 50.0; // Default scaling percentage
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      setState(() {
        _originalImageBytes = imageBytes;
        _scaledImageBytes = null;
        _differenceImageBytes = null;
        _extractedText = null;
      });
    }
  }

  void _applyScaling(bool withRedundancy) {
    if (_originalImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an image first.")),
      );
      return;
    }

    final img.Image originalImage = img.decodeImage(_originalImageBytes!)!;
    final int newWidth = (originalImage.width * _scalingFactor / 100).toInt();
    final int newHeight = (originalImage.height * _scalingFactor / 100).toInt();

    final img.Image scaledImage = img.copyResize(originalImage, width: newWidth, height: newHeight);

    setState(() {
      _scaledImageBytes = Uint8List.fromList(img.encodePng(scaledImage));
    });

    if (withRedundancy) {
      // Simulate extracting hidden text successfully
      _extractedText = _hiddenText;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Text retrieved successfully using redundancy.")),
      );
    } else {
      _extractedText = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hidden text could not be retrieved due to scaling.")),
      );
    }
  }

  void _showDifference() {
    if (_originalImageBytes == null || _scaledImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select and scale an image first.")),
      );
      return;
    }

    final img.Image originalImage = img.decodeImage(_originalImageBytes!)!;
    final img.Image scaledImage = img.decodeImage(_scaledImageBytes!)!;
    final img.Image diffImage = img.Image(originalImage.width, originalImage.height);

    for (int y = 0; y < originalImage.height; y++) {
      for (int x = 0; x < originalImage.width; x++) {
        int originalPixel = originalImage.getPixel(x, y);
        int scaledPixel = scaledImage.getPixel(x % scaledImage.width, y % scaledImage.height);
        int diff = (originalPixel - scaledPixel).abs();
        diffImage.setPixel(x, y, diff);
      }
    }

    setState(() {
      _differenceImageBytes = Uint8List.fromList(img.encodePng(diffImage));
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Difference Image"),
        content: _differenceImageBytes != null
            ? Image.memory(_differenceImageBytes!)
            : Text("No difference image available."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showHiddenMessage() {
    if (_extractedText != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hidden message: $_extractedText")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No hidden message retrieved.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: Text("Scaling Problem and Solution"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _originalImageBytes != null
                            ? Image.memory(_originalImageBytes!, height: 150, fit: BoxFit.contain)
                            : Container(
                          width: double.infinity,
                          height: 150,
                          color: Colors.grey[300],
                          child: Center(child: Text("Original Image")),
                        ),
                        SizedBox(height: 8),
                        Text("Original Image"),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: [
                        _scaledImageBytes != null
                            ? Image.memory(_scaledImageBytes!, height: 150, fit: BoxFit.contain)
                            : Container(
                          width: double.infinity,
                          height: 150,
                          color: Colors.grey[300],
                          child: Center(child: Text("Scaled Image")),
                        ),
                        SizedBox(height: 8),
                        Text("Scaled Image"),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text("Select Image"),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(labelText: "Enter text to hide"),
                onChanged: (text) {
                  setState(() {
                    _hiddenText = text;
                  });
                },
              ),
              SizedBox(height: 10),
              Text("Choose Scaling Factor"),
              Slider(
                value: _scalingFactor,
                min: 10,
                max: 100,
                divisions: 9,
                label: "${_scalingFactor.toInt()}%",
                onChanged: (value) {
                  setState(() {
                    _scalingFactor = value;
                  });
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _applyScaling(false),
                child: Text("Apply Scaling Without Redundancy"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _applyScaling(true),
                child: Text("Apply Scaling With Redundancy"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showDifference,
                child: Text("View Differences"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _showHiddenMessage,
                child: Text("Show Hidden Message"),
              ),
              SizedBox(height: 20),
              _extractedText != null
                  ? Text("Extracted Text: $_extractedText")
                  : Text("No text extracted."),
            ],
          ),
        ),
      ),
    );
  }
}
