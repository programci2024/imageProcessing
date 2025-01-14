import 'package:flutter/material.dart';
import 'package:steganography/utils/Random/extractTextRandomly.dart';
import 'dart:typed_data';

class ExtractRandomMessageCompressionPage extends StatelessWidget {
  final Uint8List imageBytes;
  final int _seed = 12345; // Random seed for extraction

  ExtractRandomMessageCompressionPage({required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    final String? message = extractTextRandomly(imageBytes, _seed);

    return Scaffold(
      appBar: AppBar(title: Text("Extract Hidden Message")),
      body: Center(
        child: message != null
            ? Text("Extracted Message: $message")
            : Text("No valid message found or corrupted data."),
      ),
    );
  }
}
