import 'package:agri_connect/Farmer/addProduct.dart';
import 'package:agri_connect/Farmer/myProduct.dart';
import 'package:agri_connect/Layouts/AppBottom.dart';
import 'package:agri_connect/Services/api_service.dart';
import 'package:flutter/material.dart';

class index extends StatefulWidget {
  final int currentIndex;
  const index({super.key, this.currentIndex = 0});

  @override
  State<index> createState() => _indexState();
}

class _indexState extends State<index> with TickerProviderStateMixin {
  int _selectedindex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    loadUser();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedindex = index;
    });
    _animationController.reset();
    _animationController.forward();
  }

  dynamic user;

  void loadUser() async {
    try {
      final result = await ApiService().getProfile;
      setState(() {
        user = result;
      });
    } catch (e) {
      print("Erro: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "AgriConnect",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            /// Card de boas-vindas
            Container(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
              decoration: BoxDecoration(
                color: Colors.green[600],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    "Olá, ${user['name']} ! 🌿",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Seus produtos estão gerando mais lucro!",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// Estatísticas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard("12", "PRODUTOS ATIVOS"),
                _buildStatCard("45", "PEDIDOS MÊS"),
                _buildStatCard("4.8★", "AVALIAÇÃO"),
              ],
            ),
            const SizedBox(height: 20),

            /// Grid de opções
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildOptionCard(
                  Icons.inventory,
                  "Meus Produtos",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const myProduct()),
                    );
                  },
                ),
                _buildOptionCard(
                  Icons.assignment,
                  "Pedidos",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pedidos em desenvolvimento'),
                      ),
                    );
                  },
                ),
                _buildOptionCard(
                  Icons.attach_money,
                  "Finanças",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Finanças em desenvolvimento'),
                      ),
                    );
                  },
                ),
                _buildOptionCard(
                  Icons.handshake,
                  "Cooperativas",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cooperativas em desenvolvimento'),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 100), // Espaço extra para o FAB
          ],
        ),
      ),

      /// Floating Action Button Customizado
      floatingActionButton: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green[400]!,
              Colors.green[600]!,
              Colors.green[800]!,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.green.withOpacity(0.2),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(32.5),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const addProduct()),
              );
            },
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /// Bottom Navigation Bar Moderno
      bottomNavigationBar: Appbottom(currentIndex: widget.currentIndex),
    );
  }

  /// Estatísticas
  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  /// Opções com navegação
  Widget _buildOptionCard(IconData icon, String label, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.green),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
