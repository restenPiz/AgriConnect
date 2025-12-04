import 'package:flutter/material.dart';

class Order extends StatefulWidget {
  const Order({Key? key}) : super(key: key);

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          OrderCard(
            orderId: '#001',
            productName: 'Fresh Tomatoes',
            quantity: '5 kg',
            status: 'Delivered',
            price: '\$25.00',
          ),
          OrderCard(
            orderId: '#002',
            productName: 'Organic Lettuce',
            quantity: '2 kg',
            status: 'In Transit',
            price: '\$12.00',
          ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final String orderId;
  final String productName;
  final String quantity;
  final String status;
  final String price;

  const OrderCard({
    Key? key,
    required this.orderId,
    required this.productName,
    required this.quantity,
    required this.status,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(orderId, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Text(productName),
            const SizedBox(height: 4.0),
            Text('Quantity: $quantity'),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Chip(label: Text(status)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
