import 'package:digiattend/feature/home/presentation/screen/history_screen.dart';
import 'package:digiattend/feature/home/presentation/screen/home_screen.dart';
import 'package:digiattend/feature/home/presentation/screen/map_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;
  final _pages = const [HomeScreen(), MapScreen(), HistoryScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade300,
              // gradient: LinearGradient(colors: [Colors.yellow, Colors.blue]),
            ),
          ),

          // Page content
          SafeArea(child: _pages[_index]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        backgroundColor: Colors.yellow,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        ],
      ),
    );
  }
}
