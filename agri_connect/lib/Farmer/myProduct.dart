import 'package:agri_connect/Farmer/addProduct.dart';
import 'package:flutter/material.dart';

class myProduct extends StatefulWidget {
  const myProduct({super.key});

  @override
  State<myProduct> createState() => _myProductState();
}

class _myProductState extends State<myProduct> {
  // Sample product data
  List<Map<String, dynamic>> products = [
    {
      'id': 1,
      'name': 'Tomate Cereja',
      'quantity': 250,
      'unit': 'kg',
      'price': 30.00,
      'status': 'Ativo',
      'views': 145,
      'sales': 23,
      'image':
          'https://cdn.wizard.com.br/wp-content/uploads/2017/01/05115936/aprenda-os-nomes-das-frutas-em-ingles.jpg',
    },
    {
      'id': 2,
      'name': 'Alface Romana',
      'quantity': 180,
      'unit': 'kg',
      'price': 25.00,
      'status': 'Ativo',
      'views': 98,
      'sales': 15,
      'image':
          'https://cdn.wizard.com.br/wp-content/uploads/2017/01/05115936/aprenda-os-nomes-das-frutas-em-ingles.jpg',
    },
    {
      'id': 3,
      'name': 'Cenoura',
      'quantity': 320,
      'unit': 'kg',
      'price': 18.00,
      'status': 'Ativo',
      'views': 210,
      'sales': 45,
      'image':
          'https://cdn.wizard.com.br/wp-content/uploads/2017/01/05115936/aprenda-os-nomes-das-frutas-em-ingles.jpg',
    },
    {
      'id': 4,
      'name': 'Batata Doce',
      'quantity': 150,
      'unit': 'kg',
      'price': 22.00,
      'status': 'Pausado',
      'views': 67,
      'sales': 8,
      'image':
          'https://cdn.wizard.com.br/wp-content/uploads/2017/01/05115936/aprenda-os-nomes-das-frutas-em-ingles.jpg',
    },
    {
      'id': 5,
      'name': 'Abóbora',
      'quantity': 200,
      'unit': 'kg',
      'price': 15.00,
      'status': 'Ativo',
      'views': 132,
      'sales': 28,
      'image':
          'https://cdn.wizard.com.br/wp-content/uploads/2017/01/05115936/aprenda-os-nomes-das-frutas-em-ingles.jpg',
    },
  ];

  String _selectedFilter = 'Todos';
  final List<String> _filters = ['Todos', 'Ativo', 'Pausado', 'Esgotado'];

  List<Map<String, dynamic>> get filteredProducts {
    if (_selectedFilter == 'Todos') {
      return products;
    }
    return products.where((p) => p['status'] == _selectedFilter).toList();
  }

  void _deleteProduct(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Produto'),
        content: const Text('Tem certeza que deseja excluir este produto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                products.removeWhere((p) => p['id'] == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Produto excluído com sucesso'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleProductStatus(int id) {
    setState(() {
      final product = products.firstWhere((p) => p['id'] == id);
      product['status'] = product['status'] == 'Ativo' ? 'Pausado' : 'Ativo';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status do produto atualizado'),
        backgroundColor: Colors.green,
      ),
    );
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
          'Meus Produtos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Buscar produtos')));
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Statistics Card
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
                      '${products.length}',
                      Icons.inventory_2,
                    ),
                    _buildStatItem(
                      'Ativos',
                      '${products.where((p) => p['status'] == 'Ativo').length}',
                      Icons.check_circle,
                    ),
                    _buildStatItem(
                      'Vendas',
                      '${products.fold(0, (sum, p) => sum + (p['sales'] as int))}',
                      Icons.shopping_cart,
                    ),
                    _buildStatItem(
                      'Visualizações',
                      '${products.fold(0, (sum, p) => sum + (p['views'] as int))}',
                      Icons.visibility,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      selectedColor: const Color(0xFF2E7D32),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
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

          // Products List
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum produto encontrado',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _buildProductCard(product);
                    },
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

  Widget _buildProductCard(Map<String, dynamic> product) {
    final isActive = product['status'] == 'Ativo';

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
          // Product Header with Image and Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Product Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8FBF9F),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.green[50]
                                  : Colors.orange[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              product['status'],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${product['quantity']} ${product['unit']}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.attach_money,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          Text(
                            '${product['price'].toStringAsFixed(2)} MT/${product['unit']}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.visibility,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${product['views']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.shopping_cart,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${product['sales']} vendas',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: Colors.grey[200]),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Editar ${product['name']}')),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Editar'),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                ),
                TextButton.icon(
                  onPressed: () => _toggleProductStatus(product['id']),
                  icon: Icon(
                    isActive
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                    size: 18,
                  ),
                  label: Text(isActive ? 'Pausar' : 'Ativar'),
                  style: TextButton.styleFrom(
                    foregroundColor: isActive ? Colors.orange : Colors.green,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _deleteProduct(product['id']),
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
}
