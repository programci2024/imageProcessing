import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class AnalyzeImageScreen extends StatelessWidget {
  final Uint8List imageBytes;

  AnalyzeImageScreen({required this.imageBytes});

  String? _extractText(Uint8List imageBytes) {
    final img.Image image = img.decodeImage(imageBytes)!;

    List<int> bits = [];
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        int pixel = image.getPixel(x, y);
        int red = img.getRed(pixel);
        bits.add(red & 1);
      }
    }

    // Ensure we have a full byte (8 bits) for each character
    if (bits.length % 8 != 0) {
      return null; // Incomplete data, cannot extract
    }

    List<int> charCodes = [];
    for (int i = 0; i <= bits.length - 8; i += 8) {
      // Form a byte from 8 bits
      String byte = bits.sublist(i, i + 8).join();
      try {
        charCodes.add(int.parse(byte, radix: 2));
      } catch (e) {
        return null; // Corrupted data
      }
    }

    return String.fromCharCodes(charCodes);
  }

  @override
  Widget build(BuildContext context) {
    final extractedText = _extractText(imageBytes);

    return Scaffold(
      appBar: AppBar(title: Text("Analyze Image")),
      body: Center(
        child: extractedText != null
            ? Text("Extracted Text: $extractedText")
            : Text("Failed to extract text or image corrupted."),
      ),
    );
  }
}
