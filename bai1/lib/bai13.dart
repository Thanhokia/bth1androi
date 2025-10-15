import 'package:flutter/material.dart';

void main() {
  runApp(const MyPopMenuApp());
}

class MyPopMenuApp extends StatelessWidget {
  const MyPopMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pop Menu List',
      home: const PopMenuListScreen(),
    );
  }
}

class PopMenuListScreen extends StatelessWidget {
  const PopMenuListScreen({super.key});

  final List<String> names = const ["Liam", "Noah", "Oliver", "William", "Elijah"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pop Menu with List"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("You selected: $value")),
              );
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: "Profile", child: Text("Profile")),
              const PopupMenuItem(value: "Settings", child: Text("Settings")),
              const PopupMenuItem(value: "Logout", child: Text("Logout")),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: names.length,
        itemBuilder: (context, index) {
          final name = names[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[400],
              child: Text(
                name[0],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(name),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Clicked on $name")),
              );
            },
          );
        },
      ),
    );
  }
}