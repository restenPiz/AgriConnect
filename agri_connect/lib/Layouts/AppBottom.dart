import 'package:agri_connect/Farmer/chat.dart';
import 'package:agri_connect/Farmer/index.dart';
import 'package:agri_connect/Farmer/myProduct.dart';
import 'package:agri_connect/Farmer/profile.dart';
import 'package:flutter/material.dart';

class Appbottom extends StatefulWidget {
  final int currentIndex;

  const Appbottom({super.key, this.currentIndex = 0});

  @override
  State<Appbottom> createState() => _AppbottomState();
}

class _AppbottomState extends State<Appbottom> {
  final List<Widget> _screens = [
    const index(currentIndex: 0),
    const myProduct(),
    const chat(),
    const profile(),
  ];

  void _onItemTapped(int index) {
    if (index == widget.currentIndex) return; // evita recarregar mesma página

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => _screens[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          notchMargin: 8,
          shape: const CircularNotchedRectangle(),
          child: SizedBox(
            height: 90,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavItem(
                    Icons.home_outlined,
                    Icons.home,
                    "Início",
                    0,
                  ),
                  _buildBottomNavItem(
                    Icons.inventory_2_outlined,
                    Icons.inventory_2,
                    "Produtos",
                    1,
                  ),
                  const SizedBox(width: 40),
                  _buildBottomNavItem(
                    Icons.chat_bubble_outline,
                    Icons.chat_bubble,
                    "Chat",
                    2,
                  ),
                  _buildBottomNavItem(
                    Icons.person_outline,
                    Icons.person,
                    "Perfil",
                    3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
  ) {
    bool isSelected = widget.currentIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
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
