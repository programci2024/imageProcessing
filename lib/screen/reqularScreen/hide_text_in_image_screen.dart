import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:steganography/utils/image_difference.dart';
import 'package:steganography/utils/regular/image_processing.dart';
import 'package:steganography/utils/saveImage.dart';
import 'dart:typed_data';

import 'package:steganography/widgets/custom_drawer.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
class HideTextInImageScreen extends StatefulWidget {
  @override
  _HideTextInImageScreenState createState() => _HideTextInImageScreenState();
}

class _HideTextInImageScreenState extends State<HideTextInImageScreen> {
  Uint8List? _originalImageBytes;
  Uint8List? _modifiedImageBytes;
  String _hiddenText = "";
   String? _savedImagePath;


  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);
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

    // Decode the original image
    final img.Image? originalImage = img.decodeImage(_originalImageBytes!);
    if (originalImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to decode image.")),
      );
      return;
    }

    // Function to check if the image is grayscale
    bool isGrayscale(img.Image image) {
      for (int y = 0; y < image.height; y += 10) {
        for (int x = 0; x < image.width; x += 10) {
          int pixel = image.getPixel(x, y);
          int red = img.getRed(pixel);
          int green = img.getGreen(pixel);
          int blue = img.getBlue(pixel);

          if (red != green || red != blue) {
            return false; // Not grayscale
          }
        }
      }
      return true; // Grayscale
    }

    // Check if the image is grayscale
    final bool grayscale = isGrayscale(originalImage);

    // Convert the text to binary
    List<int> textBinary = [];
    int textLength = _hiddenText.length;

    // Add the text length in 32 bits
    String binaryLength = textLength.toRadixString(2).padLeft(32, '0');
    textBinary.addAll(binaryLength.split('').map((e) => int.parse(e)));

    // Add the text in binary (8 bits per character)
    for (int char in _hiddenText.codeUnits) {
      String binaryChar = char.toRadixString(2).padLeft(8, '0');
      textBinary.addAll(binaryChar.split('').map((e) => int.parse(e)));
    }

    int dataIndex = 0;
    for (int y = 0; y < originalImage.height; y++) {
      for (int x = 0; x < originalImage.width; x++) {
        if (dataIndex >= textBinary.length) break;

        if (grayscale) {
          // Handle Grayscale image
          int pixel = originalImage.getPixel(x, y);
          int grayValue = img.getRed(pixel); // In Grayscale, R = G = B = Intensity

          // Modify LSB
          grayValue = (grayValue & ~1) | textBinary[dataIndex];
          dataIndex++;

          // Update the pixel
          originalImage.setPixel(x, y, img.getColor(grayValue, grayValue, grayValue));
        } else {
          // Handle RGB image (Red channel only)
          int pixel = originalImage.getPixel(x, y);
          int red = img.getRed(pixel);
          int green = img.getGreen(pixel);
          int blue = img.getBlue(pixel);

          // Modify LSB of the red channel
          red = (red & ~1) | textBinary[dataIndex];
          dataIndex++;

          // Update the pixel
          originalImage.setPixel(x, y, img.getColor(red, green, blue));
        }
      }
      if (dataIndex >= textBinary.length) break;
    }

    if (dataIndex < textBinary.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Text too long to fit in the image!")),
      );
      return;
    }

    // Encode the modified image
    final Uint8List? result = Uint8List.fromList(img.encodePng(originalImage));

    setState(() {
      _modifiedImageBytes = result;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Text successfully hidden in the image.")),
    );
  }


  Future<void> _saveImage() async {
    if (_modifiedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No encrypted image to save.")),
      );
      return;
    }

    final path = await saveImageReq(_modifiedImageBytes!);
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
  }void _showDifferencesWithDetailsUsingLSB() {
    if (_originalImageBytes == null || _modifiedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Both original and modified images are required.")),
      );
      return;
    }

    final img.Image originalImage = img.decodeImage(_originalImageBytes!)!;
    final img.Image modifiedImage = img.decodeImage(_modifiedImageBytes!)!;
    List<Map<String, dynamic>> changedPixels = [];

    // Function to check if the image is grayscale
    bool isGrayscale(img.Image image) {
      for (int y = 0; y < image.height; y += 10) {
        for (int x = 0; x < image.width; x += 10) {
          int pixel = image.getPixel(x, y);
          int red = img.getRed(pixel);
          int green = img.getGreen(pixel);
          int blue = img.getBlue(pixel);
          if (red != green || red != blue) {
            return false; // Not grayscale
          }
        }
      }
      return true; // Grayscale
    }

    final bool grayscale = isGrayscale(originalImage);

    for (int y = 0; y < originalImage.height; y++) {
      for (int x = 0; x < originalImage.width; x++) {
        int originalPixel = originalImage.getPixel(x, y);
        int modifiedPixel = modifiedImage.getPixel(x, y);

        int originalLSB;
        int modifiedLSB;

        if (grayscale) {
          // For grayscale, LSB is extracted from the single intensity value
          int originalGray = img.getRed(originalPixel); // Red = Gray in Grayscale
          int modifiedGray = img.getRed(modifiedPixel);

          originalLSB = originalGray & 1;
          modifiedLSB = modifiedGray & 1;
        } else {
          // For RGB, extract LSB from the red channel
          int originalRed = img.getRed(originalPixel);
          int modifiedRed = img.getRed(modifiedPixel);

          originalLSB = originalRed & 1;
          modifiedLSB = modifiedRed & 1;
        }

        if (originalLSB != modifiedLSB) {
          changedPixels.add({
            "x": x,
            "y": y,
            "originalLSB": originalLSB,
            "modifiedLSB": modifiedLSB,
          });

          // Limit the number of displayed changes for performance
          if (changedPixels.length >= 100) break;
        }
      }
      if (changedPixels.length >= 100) break;
    }

    if (changedPixels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No LSB differences found.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Modified Pixels (LSB Changes)"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: changedPixels.length,
              itemBuilder: (context, index) {
                final pixel = changedPixels[index];
                return ListTile(
                  title: Text(
                      "Pixel (${pixel['x']}, ${pixel['y']}): Original LSB = ${pixel['originalLSB']}, Modified LSB = ${pixel['modifiedLSB']}"),
                );
              },
            ),
          ),
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

  void _showDifferences() {
    if (_originalImageBytes == null || _modifiedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Both original and modified images are required.")),
      );
      return;
    }

    final differenceImage = generateDifferenceImage(_originalImageBytes!, _modifiedImageBytes!);

    if (differenceImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to generate difference image.")),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Difference Image"),
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(title: Text("Hide Text in Image")),
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
                onPressed: _showDifferences,
                child: Text("Show Differences"),
              ),
              ElevatedButton(
                onPressed: _showDifferencesWithDetailsUsingLSB,
                child: Text("Show Changed Pixels"),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
