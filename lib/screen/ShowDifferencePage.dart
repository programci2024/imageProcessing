import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../utils/image_difference.dart';

class ShowDifferencePage extends StatelessWidget {
  final Uint8List originalImage;
  final Uint8List modifiedImage;

  ShowDifferencePage({required this.originalImage, required this.modifiedImage});

  @override
  Widget build(BuildContext context) {
    Uint8List? differenceImage = generateDifferenceImage(originalImage, modifiedImage);

    if (differenceImage == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Show Differences")),
        body: Center(
          child: Text("Error: Images must have the same dimensions."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Show Differences")),
      body: Center(
        child: Image.memory(differenceImage),
      ),
    );
  }
}
