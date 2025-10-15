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
          title: const Text("Buttons with Icons"),
          backgroundColor: Colors.blue,
        ),
        body: const ButtonDemo(),
      ),
    );
  }
}

class ButtonDemo extends StatelessWidget {
  const ButtonDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Nút 1: icon bên trái (Android)
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.android, color: Colors.white),
            label: const Text(
              "Button With Left Icon",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(280, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Nút 2: icon bên trái (Camera)
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            label: const Text(
              "Button With Left Icon",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              minimumSize: const Size(280, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Nút 3: icon bên phải (Upload)
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              minimumSize: const Size(280, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  "Button With Right Icon",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Icon(Icons.cloud_upload, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}