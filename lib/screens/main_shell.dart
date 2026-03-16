import 'package:flutter/material.dart';
import '../home_page.dart';
import 'movies_page.dart';
import 'offline_page.dart';
import 'profile_page.dart';
import 'series_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    SeriesPage(),
    MoviesPage(),
    OfflinePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0D14),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFF1A2030)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.30),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BottomNavigationBar(
                    currentIndex: _currentIndex,
                    onTap: (index) => setState(() => _currentIndex = index),
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: const Color(0xFF0A0D14),
                    elevation: 0,
                    selectedItemColor: const Color(0xFFE3BA4E),
                    unselectedItemColor: Colors.white60,
                    selectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                    unselectedLabelStyle: const TextStyle(fontSize: 11),
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_rounded),
                        label: 'الرئيسية',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.tv_rounded),
                        label: 'المسلسلات',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.movie_creation_outlined),
                        activeIcon: Icon(Icons.movie_creation_rounded),
                        label: 'الأفلام',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.download_done_outlined),
                        activeIcon: Icon(Icons.download_done_rounded),
                        label: 'الأوفلاين',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline_rounded),
                        activeIcon: Icon(Icons.person_rounded),
                        label: 'البروفايل',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
