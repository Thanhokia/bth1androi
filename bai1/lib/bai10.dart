import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const WorkoutScreen(),
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
    );
  }
}

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  final List<Map<String, dynamic>> workouts = const [
    {
      'title': 'Yoga',
      'exercises': 3,
      'minutes': 12,
      'image': 'https://cellphones.com.vn/sforum/wp-content/uploads/2023/02/trang-phuc-lien-quan-1.jpg',
      'color': Color(0xFFe9e9f5),
    },
    {
      'title': 'Pilates',
      'exercises': 4,
      'minutes': 14,
      'image': 'https://cellphones.com.vn/sforum/wp-content/uploads/2023/02/trang-phuc-lien-quan-1.jpg',
      'color': Color(0xFF6d4ca2),
    },
    {
      'title': 'Full body',
      'exercises': 3,
      'minutes': 12,
      'image': 'https://cellphones.com.vn/sforum/wp-content/uploads/2023/02/trang-phuc-lien-quan-1.jpg',
      'color': Color(0xFF69a9d0),
    },
    {
      'title': 'Stretching',
      'exercises': 5,
      'minutes': 16,
      'image': 'https://cellphones.com.vn/sforum/wp-content/uploads/2023/02/trang-phuc-lien-quan-1.jpg',
      'color': Color(0xFFe7b6c3),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: workouts.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final workout = workouts[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              title: Text(workout['title'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text(
                  '${workout['exercises']} Exercises\n${workout['minutes']} Minutes',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    height: 1.5,
                  )),
              trailing: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: workout['color'],
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(workout['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // chọn Workouts
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_fire_department),
            label: 'Workouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}