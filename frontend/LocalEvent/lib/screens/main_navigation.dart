import 'package:flutter/material.dart';
import 'event_list_screen.dart';
import 'map_screen.dart';
import '../utils/colors/app_colors.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const EventListScreen(),
    const MapScreen(),
    const Center(child: Text('Profil')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_activity_rounded,
                color: AppColors.primaryLight, size: 22),
            const SizedBox(width: 8),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.7),
                children: [
                  TextSpan(
                      text: "Local",
                      style: TextStyle(color: AppColors.primary)),
                  TextSpan(
                      text: "Event",
                      style: TextStyle(color: AppColors.primaryLight)),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Wydarzenia'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
