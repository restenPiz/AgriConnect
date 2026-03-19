import 'package:agri_connect/Buyer/Index.dart';
import 'package:agri_connect/Buyer/MainChat.dart';
import 'package:agri_connect/Buyer/Profile.dart';
import 'package:flutter/material.dart';

class Appbottombuyer extends StatefulWidget {
  const Appbottombuyer({super.key});

  @override
  State<Appbottombuyer> createState() => _AppbottombuyerState();
}

class _AppbottombuyerState extends State<Appbottombuyer> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const Index(),
    const MainChat(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 122,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey[50]!],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          child: SizedBox(
            height: 90,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home_outlined, Icons.home, "Inicio", 0),
                  _buildNavItem(
                    Icons.chat_bubble_outline,
                    Icons.chat_bubble,
                    "Chat",
                    1,
                  ),
                  _buildNavItem(
                    Icons.person_outline,
                    Icons.person,
                    "Perfil",
                    2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
  ) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? Colors.green : Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.green : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
