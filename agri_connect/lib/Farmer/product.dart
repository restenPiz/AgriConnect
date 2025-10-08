import 'package:agri_connect/Layouts/AppBottom.dart';
import 'package:flutter/material.dart';

class product extends StatefulWidget {
  final int currentIndex;
  const product({
    super.key,
    this.currentIndex = 1,
    required this.productName,
    required this.price,
    required this.seller,
    required this.location,
    required this.availability,
    required this.rating,
    required this.reviewCount,
    required this.imageEmoji,
  });

  final String productName;
  final String price;
  final String seller;
  final String location;
  final String availability;
  final double rating;
  final int reviewCount;
  final String imageEmoji;

  @override
  State<product> createState() => _productState();
}

class _productState extends State<product> {
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
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        scrollDirection: Axis.vertical,
        //*start with the product list
        child: Column(
          children: [
            Container(
              child: ListTile(
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
                // trailing: const Icon(Icons.search, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                child: Row(
                  children: [
                    //*Start with the filter button
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      label: const Text('Filtrar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),

                    // Adicionar espaçamento
                    const SizedBox(width: 8),

                    // Laço for para adicionar múltiplos botões/widgets
                    ...List.generate(5, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            print('Botão ${index + 1} pressionado');
                          },
                          child: Text('Item ${index + 1}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[400],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ...List.generate(10, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: product(
                          productName: 'Produto ${index + 1}',
                          price: '${(index + 1) * 10} MT/kg',
                          seller: 'João Machado',
                          location: 'Beira, Sofala',
                          availability: 'Disponível: 250kg',
                          rating: 4.8,
                          reviewCount: 23,
                          imageEmoji: '🍅',
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Adicionar novo produto'),
                  duration: Duration(seconds: 2),
                ),
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
}
