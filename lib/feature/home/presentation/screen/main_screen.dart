import 'package:digiattend/core/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:digiattend/feature/home/presentation/screen/history_screen.dart';
import 'package:digiattend/feature/home/presentation/screen/home_screen.dart';
import 'package:digiattend/feature/profile/presentation/screen/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;
  final _pages = const [HomeScreen(), HistoryScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,

      // ================= BACKGROUND =================
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(color: AppColor.background),
          ),

          SafeArea(child: _pages[_index]),
        ],
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColor.card,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          backgroundColor: AppColor.card,
          selectedItemColor: AppColor.primary,
          unselectedItemColor: AppColor.subtitleText,

          elevation: 0,
          type: BottomNavigationBarType.fixed,

          onTap: (i) => setState(() => _index = i),

          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: "History",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
