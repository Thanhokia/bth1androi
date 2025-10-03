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
          title: const Text("My Gradient Buttons"),
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GradientButton(
                text: "Click me 1",
                gradient: const LinearGradient(
                  colors: [Colors.teal, Colors.green],
                ),
              ),
              const SizedBox(height: 16),
              GradientButton(
                text: "Click me 2",
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.red],
                ),
              ),
              const SizedBox(height: 16),
              GradientButton(
                text: "Click me 3",
                gradient: const LinearGradient(
                  colors: [Colors.lightBlue, Colors.blue],
                ),
              ),
              const SizedBox(height: 16),
              GradientButton(
                text: "Click me 4",
                gradient: const LinearGradient(
                  colors: [Colors.black54, Colors.grey],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final LinearGradient gradient;

  const GradientButton({
    super.key,
    required this.text,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(30),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () {},
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
