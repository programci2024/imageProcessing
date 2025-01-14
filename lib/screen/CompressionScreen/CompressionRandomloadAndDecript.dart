import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:steganography/utils/Random/extractTextRandomly.dart';
import 'package:steganography/utils/Random/generateRandomDifferenceImage.dart';
import 'package:steganography/utils/Random/hideTextRandomly.dart';
import 'package:steganography/utils/saveImage.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'dart:io';

import 'package:steganography/widgets/custom_drawer.dart';
import 'ExtractRandomMessageCompressionPage.dart';

class HideTextRandomlyCompressionScreen extends StatefulWidget {
  @override
  _HideTextRandomlyCompressionScreenState createState() =>
      _HideTextRandomlyCompressionScreenState();
}

class _HideTextRandomlyCompressionScreenState
    extends State<HideTextRandomlyCompressionScreen> {
  Uint8List? _originalImageBytes;
  Uint8List? _modifiedImageBytes;
  Uint8List? _compressedImageBytes;
  String _hiddenText = "";
  final ImagePicker _picker = ImagePicker();
  final int _seed = 12345; // Random seed for position generation

  Future<void> _pickImage() async {
    final XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      setState(() {
        _originalImageBytes = imageBytes;
        _modifiedImageBytes = null;
        _compressedImageBytes = null;
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

  Future<void> _compressImageLossless() async {
    if (_modifiedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No image available for compression.")),
      );
      return;
    }

    try {
      final img.Image decodedImage = img.decodeImage(_modifiedImageBytes!)!;
      final Uint8List compressedBytes = Uint8List.fromList(img.encodePng(decodedImage));
      setState(() {
        _compressedImageBytes = compressedBytes;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image successfully compressed losslessly.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Compression failed: $e")),
      );
    }
  }

  Future<void> _saveCompressedImage() async {
    if (_compressedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No compressed image available to save.")),
      );
      return;
    }

    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String path = '${directory.path}/compressed_image.png';
      final File file = File(path);
      await file.writeAsBytes(_compressedImageBytes!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Compressed image saved at $path")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save compressed image: $e")),
      );
    }
  }

  void _showDifferences() {
    if (_originalImageBytes == null || _compressedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Both original and compressed images are required.")),
      );
      return;
    }

    final differenceImage = generateRandomDifferenceImage(
        _originalImageBytes!, _compressedImageBytes!, _seed);

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
      appBar: AppBar(title: Text("Hide Text Randomly with Compression")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _originalImageBytes != null
                        ? Column(
                      children: [
                        Image.memory(
                          _originalImageBytes!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                        Text(
                            "Size: ${_originalImageBytes!.lengthInBytes} bytes"),
                      ],
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
                    child: _compressedImageBytes != null
                        ? Column(
                      children: [
                        Image.memory(
                          _compressedImageBytes!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                        Text(
                            "Compressed Size: ${_compressedImageBytes!.lengthInBytes} bytes"),
                      ],
                    )
                        : Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey[300],
                      child: Center(child: Text("Compressed Image")),
                    ),
                  ),
                ],
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
              ElevatedButton(
                  onPressed: _compressImageLossless,
                  child: Text("Compress Image Losslessly")),
              ElevatedButton(
                  onPressed: _showDifferences, child: Text("Show Differences")),
              ElevatedButton(
                  onPressed: _saveCompressedImage,
                  child: Text("Save Compressed Image")),
            ],
          ),
        ),
      ),
    );
  }
}
