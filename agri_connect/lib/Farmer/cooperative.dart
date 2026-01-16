import 'dart:convert';
import 'package:agri_connect/Farmer/addCooperative.dart';
import 'package:agri_connect/Farmer/cooperativeMembersScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Cooperative extends StatefulWidget {
  const Cooperative({super.key});

  @override
  State<Cooperative> createState() => _CooperativeState();
}

class _CooperativeState extends State<Cooperative> {
  List<Map<String, dynamic>> cooperatives = [];
  bool _isLoading = true;
  String _selectedFilter = 'Todos';
  final List<String> _filters = [
    'Todos',
    'forming',
    'active',
    'completed',
    'dissolved',
  ];
  int? userId;

  final String apiUrl = 'http://10.237.254.12:8000/api';

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        userId = prefs.getInt('user_id');
      });

      if (userId != null) {
        await _fetchCooperatives();
      }
    } catch (e) {
      print("Erro ao carregar usuário: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCooperatives() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$apiUrl/cooperative'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          cooperatives = List<Map<String, dynamic>>.from(data['data']);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao buscar cooperativas: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredCooperatives {
    if (_selectedFilter == 'Todos') {
      return cooperatives;
    }
    return cooperatives.where((c) => c['status'] == _selectedFilter).toList();
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'Todos':
        return 'Todos';
      case 'forming':
        return 'Em Formação';
      case 'active':
        return 'Ativa';
      case 'completed':
        return 'Concluída';
      case 'dissolved':
        return 'Dissolvida';
      default:
        return filter;
    }
  }

  String _getStatusLabel(String status) {
    return _getFilterLabel(status);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'forming':
        return Colors.blue;
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.purple;
      case 'dissolved':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getTypeLabel(String type) {
    return type == 'temporary' ? 'Temporária' : 'Permanente';
  }

  Future<void> _deleteCooperative(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Cooperativa'),
        content: const Text('Tem certeza que deseja excluir esta cooperativa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/cooperatives/$id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          cooperatives.removeWhere((c) => c['id'] == id);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cooperativa excluída com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('Erro ao excluir: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cooperativas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCooperatives,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
              ),
            )
          : Column(
              children: [
                // Statistics Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [const Color(0xFF2E7D32), Colors.green[700]!],
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'Total',
                            '${cooperatives.length}',
                            Icons.groups,
                          ),
                          _buildStatItem(
                            'Ativas',
                            '${cooperatives.where((c) => c['status'] == 'active').length}',
                            Icons.check_circle,
                          ),
                          _buildStatItem(
                            'Membros',
                            '${cooperatives.fold<int>(0, (sum, c) => sum + (c['member_count'] as int? ?? 0))}',
                            Icons.people,
                          ),
                          _buildStatItem(
                            'Pedidos',
                            '${cooperatives.fold<int>(0, (sum, c) => sum + (c['total_orders'] as int? ?? 0))}',
                            Icons.shopping_cart,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Filter Chips
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: Colors.white,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(_getFilterLabel(filter)),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            selectedColor: const Color(0xFF2E7D32),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[700],
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            backgroundColor: Colors.grey[200],
                            checkmarkColor: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Cooperatives List
                Expanded(
                  child: filteredCooperatives.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.groups_outlined,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhuma cooperativa encontrada',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: _fetchCooperatives,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Recarregar'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchCooperatives,
                          color: const Color(0xFF2E7D32),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredCooperatives.length,
                            itemBuilder: (context, index) {
                              final cooperative = filteredCooperatives[index];
                              return _buildCooperativeCard(cooperative);
                            },
                          ),
                        ),
                ),
              ],
            ),
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
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(32.5),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddCooperativeScreen(userId: userId),
                ),
              ).then((result) {
                if (result == true) {
                  _fetchCooperatives();
                }
              });
            },
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
        ),
      ],
    );
  }

  Widget _buildCooperativeCard(Map<String, dynamic> cooperative) {
    final statusColor = _getStatusColor(cooperative['status']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.groups, color: statusColor, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cooperative['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getStatusLabel(cooperative['status']),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getTypeLabel(cooperative['type']),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (cooperative['description'] != null &&
                    cooperative['description'].isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    cooperative['description'],
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.people,
                      '${cooperative['member_count']} membros',
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.shopping_bag,
                      '${cooperative['total_orders']} pedidos',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CooperativeMembersScreen(cooperative: cooperative),
                      ),
                    ).then((result) {
                      if (result == true) {
                        _fetchCooperatives();
                      }
                    });
                  },
                  icon: const Icon(Icons.people_alt, size: 18),
                  label: const Text('Membros'),
                  style: TextButton.styleFrom(foregroundColor: Colors.green),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddCooperativeScreen(
                          userId: userId,
                          cooperative: cooperative,
                        ),
                      ),
                    ).then((result) {
                      if (result == true) {
                        _fetchCooperatives();
                      }
                    });
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Editar'),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                ),
                TextButton.icon(
                  onPressed: () => _deleteCooperative(cooperative['id']),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Excluir'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
