import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class ImageTypeDetectorScreen extends StatefulWidget {
  @override
  _ImageTypeDetectorScreenState createState() => _ImageTypeDetectorScreenState();
}

class _ImageTypeDetectorScreenState extends State<ImageTypeDetectorScreen> {
  Uint8List? _originalImageBytes;
  String _imageType = "Unknown";

  Future<void> _pickImage() async {
    // Simulating picking an image (replace with your image picker logic)
    // For example, you can use `ImagePicker` to pick an image from the gallery.
    // final XFile? imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    // if (imageFile != null) {
    //   final Uint8List imageBytes = await imageFile.readAsBytes();
    //   setState(() {
    //     _originalImageBytes = imageBytes;
    //     _imageType = _detectImageType(imageBytes);
    //   });
    // }
  }

  String _detectImageType(Uint8List imageBytes) {
    final img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      return "Invalid Image";
    }

    bool isGrayscale = true;
    bool isBlackAndWhite = true;

    for (int y = 0; y < image.height; y += 10) {
      for (int x = 0; x < image.width; x += 10) {
        int pixel = image.getPixel(x, y);
        int red = img.getRed(pixel);
        int green = img.getGreen(pixel);
        int blue = img.getBlue(pixel);

        // Check if the pixel is grayscale (R == G == B)
        if (red != green || red != blue) {
          isGrayscale = false;
        }

        // Check if the pixel is black or white (R, G, B are either 0 or 255)
        if (!(red == 0 || red == 255) || !(green == 0 || green == 255) || !(blue == 0 || blue == 255)) {
          isBlackAndWhite = false;
        }

        // If it's neither grayscale nor black and white, it's RGB
        if (!isGrayscale && !isBlackAndWhite) {
          return "RGB";
        }
      }
    }

    if (isBlackAndWhite) {
      return "Black and White";
    } else if (isGrayscale) {
      return "Grayscale";
    } else {
      return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Type Detector"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _originalImageBytes != null
                ? Image.memory(
              _originalImageBytes!,
              height: 200,
              width: 200,
              fit: BoxFit.contain,
            )
                : Container(
              height: 200,
              width: 200,
              color: Colors.grey[300],
              child: Center(child: Text("No Image Selected")),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Pick Image"),
            ),
            SizedBox(height: 20),
            Text(
              "Image Type: $_imageType",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
