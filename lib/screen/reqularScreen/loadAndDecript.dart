import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:steganography/utils/regular/extractTextFromImage.dart';
 import 'package:steganography/widgets/custom_drawer.dart';
import '../../utils/regular/image_decryption.dart';

class ImportAndDecryptPage extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();

  Future<void> _importAndDecrypt(BuildContext context) async {
    final XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Use the utility function to decrypt the message
      String? extractedMessage = extractTextFromImage(imageBytes);

      if (extractedMessage == null || extractedMessage.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No valid text found in the image or corrupted data.")),
        );
        return;
      }

      // Show the extracted message in a dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Extracted Message"),
            content: Text(extractedMessage),
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
      appBar: AppBar(title: Text("Import and Decrypt")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _importAndDecrypt(context),
          child: Text("Import Image and Decrypt"),
        ),
      ),
    );
  }
}
