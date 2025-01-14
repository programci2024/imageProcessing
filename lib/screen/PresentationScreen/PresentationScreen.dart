import 'package:flutter/material.dart';
import 'package:steganography/widgets/custom_drawer.dart';

class PresentationScreen extends StatefulWidget {
  final Map<String, List<Map<String, dynamic>>> topics; // Topics and their slides

  PresentationScreen({required this.topics});

  @override
  _PresentationScreenState createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen> {
  late List<Map<String, dynamic>> _currentSlides;
  late String _currentTopic;

  @override
  void initState() {
    super.initState();
    _currentTopic = widget.topics.keys.first;
    _currentSlides = widget.topics[_currentTopic]!;
  }

  void _changeTopic(String topic) {
    setState(() {
      _currentTopic = topic;
      _currentSlides = widget.topics[topic]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: Text("Dynamic Presentation"),
        actions: [
          PopupMenuButton<String>(
            onSelected: _changeTopic,
            itemBuilder: (context) {
              return widget.topics.keys
                  .map((topic) => PopupMenuItem<String>(
                value: topic,
                child: Text(topic),
              ))
                  .toList();
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Content Table Section
          Container(
            width: 250,
            color: Colors.grey[200],
            child: ListView(
              children: widget.topics.keys.map((topic) {
                return ListTile(
                  title: Text(
                    topic,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    _changeTopic(topic);
                  },
                );
              }).toList(),
            ),
          ),

          // Presentation Slides Section
          Expanded(
            child: Column(
              children: [
                // Current Topic Header
                Container(
                  padding: EdgeInsets.all(8.0),
                  color: Colors.grey[300],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Current Topic: $_currentTopic",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    itemCount: _currentSlides.length,
                    itemBuilder: (context, index) {
                      return _buildSlide(_currentSlides[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(Map<String, dynamic> slide) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slide["content"] ?? "",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (slide["image"] != null) // Check for image
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Image.asset(
                        slide["image"],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  if (slide["example"] != null) // Check for example
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        "Example: ${slide["example"]}",
                        style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
