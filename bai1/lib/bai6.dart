import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("RichText"),
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Hello World (dòng 1)
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                        text: "Hello ",
                        style: TextStyle(
                            color: Colors.green, fontSize: 28)),
                    TextSpan(
                        text: "World",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 30,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              SizedBox(height: 15),

              /// Hello World 👋 (dòng 2)
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                        text: "Hello ",
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: "World ",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    WidgetSpan(
                        child: Text("👋",
                            style: TextStyle(fontSize: 24))),
                  ],
                ),
              ),

              SizedBox(height: 25),

              /// Contact me via: 📧 Email
              RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 18),
                  children: [
                    TextSpan(text: "Contact me via: "),
                    WidgetSpan(
                        child: Icon(Icons.email,
                            color: Colors.blue, size: 20)),
                    TextSpan(
                        text: " Email",
                        style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline)),
                  ],
                ),
              ),

              SizedBox(height: 20),

              /// Call Me
              RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 18),
                  children: [
                    TextSpan(
                        text: "Call Me: ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: "+1234987654321",
                        style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline)),
                  ],
                ),
              ),

              SizedBox(height: 20),

              /// Read My Blog HERE
              RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 18),
                  children: [
                    TextSpan(
                        text: "Read My Blog ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: "HERE",
                        style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
