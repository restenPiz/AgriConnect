import 'package:agri_connect/Farmer/addProduct.dart';
import 'package:agri_connect/Farmer/cooperative.dart';
import 'package:agri_connect/Farmer/finances.dart';
import 'package:agri_connect/Farmer/myProduct.dart';
import 'package:agri_connect/Layouts/AppBottom.dart';
import 'package:agri_connect/Services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class index extends StatefulWidget {
  final int currentIndex;
  const index({super.key, this.currentIndex = 0});

  @override
  State<index> createState() => _indexState();
}

class _indexState extends State<index> with TickerProviderStateMixin {
  late AnimationController _animationController;
  dynamic user;
  int? userId;
  bool _isLoading = true;

  // Dados de estatísticas (podem vir da API depois)
  Map<String, dynamic> stats = {
    'products': 12,
    'orders': 45,
    'rating': 4.8,
    'revenue': 'R\$ 2.450',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    loadUser();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getInt('user_id');

      if (userId == null) {
        print("Erro: user_id não encontrado no SharedPreferences");
        setState(() => _isLoading = false);
        return;
      }

      final result = await ApiService().getProfile(userId!);

      if (result['success'] == true) {
        setState(() {
          user = result['data']['user'];
          _isLoading = false;
        });
        _animationController.forward();
      } else {
        print("Erro ao buscar perfil: ${result['message']}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Erro ao carregar usuário: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // App Bar com gradiente
                SliverAppBar(
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.green[700],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.green[600]!, Colors.green[800]!],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.eco,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.notifications_outlined,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                "Olá, ${user?['name']?.split(' ')[0] ?? 'Agricultor'} 👋",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Bem-vindo de volta!",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Conteúdo
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cards de estatísticas
                        _buildStatsCards(),
                        const SizedBox(height: 28),

                        // Seção de ações rápidas
                        const Text(
                          "Ações Rápidas",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildQuickActions(),
                        const SizedBox(height: 28),

                        // Seção principal
                        const Text(
                          "Gestão",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildMainOptions(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),

      // FAB moderno
      floatingActionButton: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green[400]!, Colors.green[700]!],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(35),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const addProduct()),
              );
            },
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Appbottom(currentIndex: widget.currentIndex),
    );
  }

  Widget _buildStatsCards() {
    return SizedBox(
      height: 120,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              "${stats['products']}",
              "Produtos",
              Icons.inventory_2_outlined,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              "${stats['orders']}",
              "Pedidos",
              Icons.shopping_bag_outlined,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              "${stats['rating']}★",
              "Avaliação",
              Icons.star_outline,
              Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            "Adicionar Produto",
            Icons.add_circle_outline,
            Colors.green,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const addProduct()),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            "Ver Finanças",
            Icons.trending_up,
            Colors.blue,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Finances()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainOptions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildOptionCard(
                "Meus Produtos",
                "Gerenciar estoque",
                Icons.inventory_2_outlined,
                LinearGradient(
                  colors: [Colors.purple[400]!, Colors.purple[600]!],
                ),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const myProduct()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOptionCard(
                "Finanças",
                "Receitas e vendas",
                Icons.attach_money,
                LinearGradient(
                  colors: [Colors.green[400]!, Colors.green[600]!],
                ),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Finances()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildOptionCard(
                "Cooperativas",
                "Minhas cooperativas",
                Icons.handshake_outlined,
                LinearGradient(
                  colors: [Colors.orange[400]!, Colors.orange[600]!],
                ),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Cooperative()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOptionCard(
                "Relatórios",
                "Análises e insights",
                Icons.analytics_outlined,
                LinearGradient(colors: [Colors.blue[400]!, Colors.blue[600]!]),
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Em breve!'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionCard(
    String title,
    String subtitle,
    IconData icon,
    Gradient gradient,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Padrão de fundo
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Conteúdo
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
