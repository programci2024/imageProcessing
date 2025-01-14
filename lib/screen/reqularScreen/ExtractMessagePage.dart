import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../utils/regular/image_decryption.dart';

class ExtractMessagePage extends StatelessWidget {
  final Uint8List imageBytes;

  ExtractMessagePage({required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    String? message = decryptTextFromImage(imageBytes);

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
