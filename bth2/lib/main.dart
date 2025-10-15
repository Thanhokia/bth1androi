// lib/main.dart
import 'package:flutter/material.dart';
import 'package:bth2/register_screen.dart';
import 'package:bth2/add_address_screen.dart';
import 'package:bth2/order_wizard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Đăng Ký',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const OrderWizardScreen(),
      //home: const RegisterPage(),// Bắt đầu với màn hình đăng ký
    );
  }
}
