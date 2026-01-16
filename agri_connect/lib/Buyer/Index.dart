import 'dart:convert';
import 'package:agri_connect/Buyer/Order.dart';
import 'package:agri_connect/Buyer/ProductDetails.dart';
import 'package:agri_connect/Buyer/chat.dart';
import 'package:agri_connect/Layouts/AppBottomBuyer.dart';
import 'package:agri_connect/Services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../Services/CartItem.dart';

class Index extends StatefulWidget {
  final int currentIndex;
  const Index({super.key, this.currentIndex = 0});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  List<Map<String, dynamic>> products = [];
  int? userId;
  bool _isLoading = true;
  String _selectedFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.71.207.12:8000/api/product'),
        headers: {'Accept': 'application/json'},
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          setState(() {
            products = List<Map<String, dynamic>>.from(
              (data['data'] as List).map(
                (item) => {
                  'id': item['id'],
                  'name': item['name'],
                  'description': item['description'] ?? '',
                  'quantity': double.parse(
                    item['available_quantity'].toString(),
                  ),
                  'unit': item['unit'],
                  'price': double.parse(item['price'].toString()),
                  'status': item['status'],
                  'category': item['category'],
                  'is_organic':
                      item['is_organic'] == 1 || item['is_organic'] == true,
                  'image_urls': item['image_urls'] is String
                      ? jsonDecode(item['image_urls'])
                      : item['image_urls'],
                  'harvest_date': item['harvest_date'],
                  'expiry_date': item['expiry_date'],
                  'rating': item['rating'] != null
                      ? double.parse(item['rating'].toString())
                      : null,
                  'review_count': item['review_count'] ?? 0,
                  'created_at': item['created_at'],
                },
              ),
            );
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Erro ao carregar produtos: ${response.body}');
      }
    } catch (e) {
      print('Erro ao buscar produtos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar produtos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
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
          "Productos Proximos",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        actions: [
          Consumer<CartManager>(
            builder: (context, cart, child) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Order()),
                    );
                  },
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // Search bar
                  ListTile(
                    title: TextField(
                      decoration: InputDecoration(
                        hintText: 'Pesquisar produtos',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Category filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.filter_list,
                            color: Colors.white,
                          ),
                          label: const Text('Filtrar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ...List.generate(
                          products.length > 5 ? 5 : products.length,
                          (index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  print(
                                    'Categoria: ${products[index]['category']}',
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[600],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                child: Text(
                                  products[index]['category'] ??
                                      'Item ${index + 1}',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Products list
                  products.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'Nenhum produto disponível',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: List.generate(products.length, (index) {
                            final product = products[index];
                            final imageUrls = product['image_urls'] as List?;
                            final imageUrl =
                                imageUrls != null && imageUrls.isNotEmpty
                                ? 'http://10.71.207.12:8000${imageUrls[0]}'
                                : null;

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetails(product: product),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Image container
                                    Container(
                                      width: double.infinity,
                                      height: 120,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF8FBF9F),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                        child: imageUrl != null
                                            ? Image.network(
                                                imageUrl,
                                                width: double.infinity,
                                                height: double.infinity,
                                                fit: BoxFit.cover,
                                                alignment: Alignment.center,
                                                loadingBuilder:
                                                    (
                                                      context,
                                                      child,
                                                      loadingProgress,
                                                    ) {
                                                      if (loadingProgress ==
                                                          null) {
                                                        return child;
                                                      }
                                                      return const Center(
                                                        child: SizedBox(
                                                          width: 24,
                                                          height: 24,
                                                          child:
                                                              CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => Container(
                                                      color: Colors.grey[200],
                                                      alignment:
                                                          Alignment.center,
                                                      child: Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        size: 40,
                                                        color: Colors.grey[400],
                                                      ),
                                                    ),
                                              )
                                            : Icon(
                                                Icons.image_not_supported,
                                                size: 50,
                                                color: Colors.grey[400],
                                              ),
                                      ),
                                    ),

                                    // Product info section
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Product name and price
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  product['name'] ?? 'Produto',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Text(
                                                '${product['price']} MT/${product['unit'] ?? 'kg'}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),

                                          // Category
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 8.0,
                                            ),
                                            child: Text(
                                              'Categoria: ${product['category'] ?? 'N/A'}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),

                                          // Availability and rating
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.inventory_2_outlined,
                                                size: 14,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Disponível: ${product['quantity']}${product['unit'] ?? 'kg'}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.star,
                                                size: 14,
                                                color: Colors.amber,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                '${product['rating'] ?? 0.0} (${product['review_count'] ?? 0} avaliações)',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),

                                          // Action buttons
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton.icon(
                                                  onPressed: () async {
                                                    // Mostrar loading
                                                    showDialog(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (context) =>
                                                          const Center(
                                                            child:
                                                                CircularProgressIndicator(),
                                                          ),
                                                    );

                                                    try {
                                                      // Buscar dados do agricultor
                                                      final apiService =
                                                          ApiService();
                                                      final farmer =
                                                          await apiService
                                                              .getFarmerByProduct(
                                                                product['id'],
                                                              );

                                                      // Fechar loading
                                                      if (mounted)
                                                        Navigator.pop(context);

                                                      if (farmer != null) {
                                                        // Navegar para o chat
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (_) => ChatScreen(
                                                              currentIndex: widget
                                                                  .currentIndex,
                                                              userId: farmer['id']
                                                                  .toString(),
                                                              userName:
                                                                  farmer['name'],
                                                              userRole:
                                                                  'Agricultor',
                                                              productId:
                                                                  product['id'], // Opcional: passar ID do produto
                                                              productName:
                                                                  product['name'], // Opcional: passar nome do produto
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        // Mostrar erro
                                                        if (mounted) {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                'Não foi possível encontrar o vendedor',
                                                              ),
                                                              backgroundColor:
                                                                  Colors.red,
                                                            ),
                                                          );
                                                        }
                                                      }
                                                    } catch (e) {
                                                      // Fechar loading
                                                      if (mounted)
                                                        Navigator.pop(context);

                                                      // Mostrar erro
                                                      if (mounted) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'Erro ao buscar vendedor: $e',
                                                            ),
                                                            backgroundColor:
                                                                Colors.red,
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  },
                                                  icon: const Icon(
                                                    Icons.chat_bubble_outline,
                                                    size: 18,
                                                  ),
                                                  label: const Text('Chat'),
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.green,
                                                    side: const BorderSide(
                                                      color: Colors.green,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () {
                                                    // Adicionar ao carrinho
                                                    context
                                                        .read<CartManager>()
                                                        .addItem(product);

                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .check_circle,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            const SizedBox(
                                                              width: 12,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                '${product['name']} adicionado ao carrinho',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        backgroundColor:
                                                            Colors.green,
                                                        duration:
                                                            const Duration(
                                                              seconds: 2,
                                                            ),
                                                        action: SnackBarAction(
                                                          label: 'VER CARRINHO',
                                                          textColor:
                                                              Colors.white,
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (_) =>
                                                                    const Order(),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  icon: const Icon(
                                                    Icons.shopping_cart,
                                                    size: 18,
                                                  ),
                                                  label: const Text('Pedir'),
                                                  style: ElevatedButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.white,
                                                    backgroundColor:
                                                        Colors.orange,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
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
                              ),
                            );
                          }),
                        ),
                ],
              ),
            ),
      bottomNavigationBar: AppBottomBuyer(currentIndex: widget.currentIndex),
    );
  }
}
