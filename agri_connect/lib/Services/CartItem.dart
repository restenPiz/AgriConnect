import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartItem {
  final int productId;
  final String name;
  final double price;
  final String unit;
  final String? imageUrl;
  int quantity;
  final double availableQuantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.unit,
    this.imageUrl,
    this.quantity = 1,
    required this.availableQuantity,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'unit': unit,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'availableQuantity': availableQuantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'],
      name: json['name'],
      price: json['price'].toDouble(),
      unit: json['unit'],
      imageUrl: json['imageUrl'],
      quantity: json['quantity'],
      availableQuantity: json['availableQuantity'].toDouble(),
    );
  }
}

class CartManager extends ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Carregar carrinho do SharedPreferences
  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString('cart');

      if (cartData != null) {
        final List<dynamic> decoded = jsonDecode(cartData);
        _items = decoded.map((item) => CartItem.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Erro ao carregar carrinho: $e');
    }
  }

  // Salvar carrinho no SharedPreferences
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = jsonEncode(_items.map((item) => item.toJson()).toList());
      await prefs.setString('cart', cartData);
    } catch (e) {
      print('Erro ao salvar carrinho: $e');
    }
  }

  // Adicionar item ao carrinho
  void addItem(Map<String, dynamic> product) {
    final existingIndex = _items.indexWhere(
      (item) => item.productId == product['id'],
    );

    if (existingIndex >= 0) {
      if (_items[existingIndex].quantity <
          _items[existingIndex].availableQuantity) {
        _items[existingIndex].quantity++;
      }
    } else {
      // Novo produto
      final imageUrls = product['image_urls'] as List?;
      final imageUrl = imageUrls != null && imageUrls.isNotEmpty
          ? 'http://10.154.5.12:8000${imageUrls[0]}'
          : null;

      _items.add(
        CartItem(
          productId: product['id'],
          name: product['name'],
          price: product['price'].toDouble(),
          unit: product['unit'],
          imageUrl: imageUrl,
          quantity: 1,
          availableQuantity: product['quantity'].toDouble(),
        ),
      );
    }

    _saveCart();
    notifyListeners();
  }

  // Remover item do carrinho
  void removeItem(int productId) {
    _items.removeWhere((item) => item.productId == productId);
    _saveCart();
    notifyListeners();
  }

  // Aumentar quantidade
  void increaseQuantity(int productId) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0 &&
        _items[index].quantity < _items[index].availableQuantity) {
      _items[index].quantity++;
      _saveCart();
      notifyListeners();
    }
  }

  // Diminuir quantidade
  void decreaseQuantity(int productId) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      _saveCart();
      notifyListeners();
    }
  }

  // Limpar carrinho
  void clear() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }

  // Verificar se produto está no carrinho
  bool isInCart(int productId) {
    return _items.any((item) => item.productId == productId);
  }

  // Obter quantidade de um produto no carrinho
  int getQuantity(int productId) {
    final item = _items.firstWhere(
      (item) => item.productId == productId,
      orElse: () => CartItem(
        productId: 0,
        name: '',
        price: 0,
        unit: '',
        quantity: 0,
        availableQuantity: 0,
      ),
    );
    return item.quantity;
  }
}
