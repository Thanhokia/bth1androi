import 'package:flutter/material.dart';
import 'screens/survey_station_screen.dart';
import 'screens/data_map_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trạm Khảo sát',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const SurveyStationScreen(),
    const DataMapScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sensors),
            label: 'Trạm Khảo sát',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Bản đồ Dữ liệu',
          ),
        ],
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[600],
      ),
    );
  }
}


