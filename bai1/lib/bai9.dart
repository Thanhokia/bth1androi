import 'package:flutter/material.dart';

void main() {
  runApp(const RichTextExampleApp());
}

class RichTextExampleApp extends StatelessWidget {
  const RichTextExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const RichTextPage(),
    );
  }
}

class RichTextPage extends StatelessWidget {
  const RichTextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Custom Rich Text Example"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 14, color: Colors.black),
                children: [
                  TextSpan(
                    text: "Flutter ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                      text:
                      "is an open-source UI software development kit created by Google. "
                          "It is used to develop cross platform applications for Android, iOS, "
                          "Linux, macOS, Windows, Google Fuchsia, and the web from a single codebase. "
                          "First described in 2015, "),
                  TextSpan(
                    text: "Flutter ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  TextSpan(
                      text:
                      "was released in May 2017.\n\nContact on "),
                  TextSpan(
                    text: "+910000210056",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ". Our email address is "),
                  TextSpan(
                    text: "test@examplemail.org",
                    style: TextStyle(color: Colors.blue),
                  ),
                  TextSpan(
                      text:
                      ".\n\nFor more details check "),
                  TextSpan(
                    text: "https://www.google.com",
                    style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                  ),
                  TextSpan(text: "\n\n"),
                  TextSpan(
                    text: "Read less",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
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