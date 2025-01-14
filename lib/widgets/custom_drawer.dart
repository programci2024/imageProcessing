import 'package:flutter/material.dart';
import 'package:steganography/screen/CompressionScreen/CompressionRandomloadAndDecript.dart';
import 'package:steganography/screen/CompressionScreen/LoadRandomCompression.dart';
import 'package:steganography/screen/PresentationScreen/PresentationScreen.dart';
  import 'package:steganography/screen/RandomScreen/HideTextRandomlyScreen.dart';
import 'package:steganography/screen/RandomScreen/RandomloadAndDecript.dart';
import 'package:steganography/screen/TransformationDemoScreen/TransformationDemoScreen.dart';
import 'package:steganography/screen/reqularScreen/hide_text_in_image_screen.dart';

import 'package:steganography/screen/reqularScreen/loadAndDecript.dart';
import 'package:steganography/widgets/constant.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Steganography App",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                Text(
                  "Hide & Extract Messages",
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),

          // List of Drawer Items
          Expanded(
            child: ListView(
              children: [
                // Main Page Navigation
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text("Main Page"),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HideTextInImageScreen(),
                      ),
                    );
                  },
                ),

                // Import & Decrypt Page
                ListTile(
                  leading: Icon(Icons.lock_open),
                  title: Text("Import & Decrypt"),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImportAndDecryptPage(),
                      ),
                    );
                  },
                ),


                ListTile(
                  leading: Icon(Icons.shuffle),
                  title: Text("Random Page"),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HideTextRandomlyScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.lock_open),
                  title: Text("Random Import & Decrypt"),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RandomloadAndDecript(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.compress),
                  title: Text("Random Compression"),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HideTextRandomlyCompressionScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.compress),
                  title: Text("Load random Compression"),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoadRandomCompression(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.transform),
                  title: Text("TransformationDemoScreen"),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScalingProblemScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.transform),
                  title: Text("Presentation"),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PresentationScreen(topics: topics
                          ,),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
