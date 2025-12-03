import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class addProduct extends StatefulWidget {
  final Map<String, dynamic>? product;

  const addProduct({super.key, this.product});

  @override
  State<addProduct> createState() => _addProductState();
}

class _addProductState extends State<addProduct> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _selectedUnit = 'kg';
  final List<Map<String, String>> _units = [
    {'value': 'kg', 'label': 'kg'},
    {'value': 'g', 'label': 'g'},
    {'value': 'piece', 'label': 'unidade'},
    {'value': 'bunch', 'label': 'molho'},
    {'value': 'bag', 'label': 'saco'},
    {'value': 'liter', 'label': 'litro'},
  ];

  String _selectedCategory = 'vegetables';
  final List<Map<String, String>> _categories = [
    {'value': 'vegetables', 'label': 'Vegetais'},
    {'value': 'fruits', 'label': 'Frutas'},
    {'value': 'grains', 'label': 'Grãos'},
    {'value': 'legumes', 'label': 'Legumes'},
    {'value': 'herbs', 'label': 'Ervas'},
    {'value': 'roots', 'label': 'Raízes'},
    {'value': 'dairy', 'label': 'Laticínios'},
    {'value': 'meat', 'label': 'Carne'},
  ];

  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isOrganic = false;
  DateTime? _harvestDate;
  DateTime? _expiryDate;
  bool _isLoading = false;

  // Replace with your Laravel API URL
  final String apiUrl = 'http://10.202.9.12:8000/api/storeProduct';
  final String apiUpdate = 'http://10.202.9.12:8000/api/productUpdate';
  int? userId; // Will be loaded from storage

  @override
  void initState() {
    super.initState();
    _loadUserId();

    //*To load the product data for editing
    if (widget.product != null) {
      _nameController.text = widget.product!['name'];
      _priceController.text = widget.product!['price'].toString();
      _quantityController.text = widget.product!['quantity'].toString();
      _descriptionController.text = widget.product!['description'] ?? '';
      _harvestDate = widget.product!['harvest_date'] != null
          ? DateTime.parse(widget.product!['harvest_date'])
          : null;
      _expiryDate = widget.product!['expiry_date'] != null
          ? DateTime.parse(widget.product!['expiry_date'])
          : null;
      _selectedCategory = widget.product!['category'] ?? 'vegetables';
      _selectedUnit = widget.product!['unit'] ?? 'kg';
      _isOrganic = widget.product!['is_organic'] == 1;
    }
  }

  Future<void> _loadUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        userId = prefs.getInt('user_id');
      });

      if (userId == null) {
        print('ERRO: User ID não encontrado no SharedPreferences');
      } else {
        print('User ID carregado: $userId');
      }
    } catch (e) {
      print("Erro ao carregar usuário: $e");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Máximo de 5 fotos permitido')),
      );
      return;
    }

    final List<XFile> images = await _picker.pickMultiImage();

    setState(() {
      for (var image in images) {
        if (_selectedImages.length < 5) {
          _selectedImages.add(File(image.path));
        }
      }
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context, bool isHarvestDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2E7D32)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isHarvestDate) {
          _harvestDate = picked;
        } else {
          _expiryDate = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Check if userId exists
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Erro: Usuário não autenticado. Faça login novamente.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        print('Sending request to: $apiUrl');
        print('User ID: $userId');

        var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

        // Add headers
        request.headers['Accept'] = 'application/json';

        // Add form fields including farmer_id
        request.fields['farmer_id'] = userId.toString();
        request.fields['name'] = _nameController.text;
        request.fields['description'] = _descriptionController.text;
        request.fields['price'] = _priceController.text;
        request.fields['unit'] = _selectedUnit;
        request.fields['available_quantity'] = _quantityController.text;
        request.fields['category'] = _selectedCategory;
        request.fields['is_organic'] = _isOrganic ? '1' : '0';

        if (_harvestDate != null) {
          request.fields['harvest_date'] = _harvestDate!
              .toIso8601String()
              .split('T')[0];
        }

        if (_expiryDate != null) {
          request.fields['expiry_date'] = _expiryDate!.toIso8601String().split(
            'T',
          )[0];
        }

        // Add images
        for (int i = 0; i < _selectedImages.length; i++) {
          var image = await http.MultipartFile.fromPath(
            'images[]',
            _selectedImages[i].path,
          );
          request.files.add(image);
        }

        // Send request
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200 || response.statusCode == 201) {
          var data = jsonDecode(response.body);

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Produto "${_nameController.text}" adicionado com sucesso!',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Clear form
          _nameController.clear();
          _descriptionController.clear();
          _quantityController.clear();
          _priceController.clear();
          setState(() {
            _selectedImages.clear();
            _selectedUnit = 'kg';
            _selectedCategory = 'vegetables';
            _isOrganic = false;
            _harvestDate = null;
            _expiryDate = null;
          });

          Navigator.pop(context, true); // Return to previous screen
        } else {
          // Detailed error logging
          print('Status Code: ${response.statusCode}');
          print('Response Body: ${response.body}');
          print('Response Headers: ${response.headers}');

          String errorMessage = 'Erro ao adicionar produto';
          try {
            var errorData = jsonDecode(response.body);
            if (errorData['message'] != null) {
              errorMessage = errorData['message'];
            }
            if (errorData['errors'] != null) {
              errorMessage += '\n${errorData['errors']}';
            }
          } catch (e) {
            errorMessage = 'Status ${response.statusCode}: ${response.body}';
          }

          throw Exception(errorMessage);
        }
      } catch (e) {
        print('Error details: $e');

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar produto: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> updateProduct() async {
    if (_formKey.currentState!.validate()) {
      // Check if userId exists
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Erro: Usuário não autenticado. Faça login novamente.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get product ID
      final productId = widget.product!['id'];

      setState(() {
        _isLoading = true;
      });

      try {
        print('Updating product ID: $productId');
        print('Sending request to: $apiUpdate/$productId');
        print('User ID: $userId');

        var request = http.MultipartRequest(
          'POST', // Alguns servidores não suportam PUT com multipart, use POST
          Uri.parse('$apiUpdate/$productId'),
        );

        // Add headers
        request.headers['Accept'] = 'application/json';

        // Para simular PUT request (se o Laravel precisar)
        request.fields['_method'] = 'POST';

        // Add form fields including farmer_id
        request.fields['farmer_id'] = userId.toString();
        request.fields['name'] = _nameController.text;
        request.fields['description'] = _descriptionController.text;
        request.fields['price'] = _priceController.text;
        request.fields['unit'] = _selectedUnit;
        request.fields['available_quantity'] = _quantityController.text;
        request.fields['category'] = _selectedCategory;
        request.fields['is_organic'] = _isOrganic ? '1' : '0';

        if (_harvestDate != null) {
          request.fields['harvest_date'] = _harvestDate!
              .toIso8601String()
              .split('T')[0];
        }

        if (_expiryDate != null) {
          request.fields['expiry_date'] = _expiryDate!.toIso8601String().split(
            'T',
          )[0];
        }

        // Add images only if new images were selected
        if (_selectedImages.isNotEmpty) {
          for (int i = 0; i < _selectedImages.length; i++) {
            var image = await http.MultipartFile.fromPath(
              'images[]',
              _selectedImages[i].path,
            );
            request.files.add(image);
          }
          print('New images added: ${_selectedImages.length}');
        } else {
          print('No new images to upload');
        }

        // Debug: print all fields being sent
        print('Fields being sent:');
        request.fields.forEach((key, value) {
          print('  $key: $value');
        });

        // Send request
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          var data = jsonDecode(response.body);

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Produto "${_nameController.text}" atualizado com sucesso!',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Return to previous screen with success flag
          Navigator.pop(context, true);
        } else {
          // Detailed error logging
          String errorMessage = 'Erro ao atualizar produto';
          try {
            var errorData = jsonDecode(response.body);
            if (errorData['message'] != null) {
              errorMessage = errorData['message'];
            }
            if (errorData['errors'] != null) {
              errorMessage += '\nErros: ${errorData['errors']}';
            }
          } catch (e) {
            errorMessage = 'Status ${response.statusCode}: ${response.body}';
          }

          throw Exception(errorMessage);
        }
      } catch (e) {
        print('Error details: $e');

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar produto: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
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
          'Adicionar Produto',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo Upload Section
                    _buildPhotoSection(),
                    const SizedBox(height: 24),

                    // Product Name
                    _buildTextField(
                      label: 'Nome do Produto',
                      controller: _nameController,
                      hint: 'Tomate Cereja',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o nome do produto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Description
                    _buildTextField(
                      label: 'Descrição (opcional)',
                      controller: _descriptionController,
                      hint: 'Descrição do produto',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    // Category
                    _buildDropdown(
                      label: 'Categoria',
                      value: _selectedCategory,
                      items: _categories,
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Quantity and Unit Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            label: 'Quantidade',
                            controller: _quantityController,
                            hint: '150',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Insira a quantidade';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: _buildDropdown(
                            label: 'Unidade',
                            value: _selectedUnit,
                            items: _units,
                            onChanged: (value) {
                              setState(() {
                                _selectedUnit = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Price
                    _buildTextField(
                      label: 'Preço por Unidade (MT)',
                      controller: _priceController,
                      hint: '22.00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o preço';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Harvest and Expiry Dates
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            label: 'Data de Colheita',
                            date: _harvestDate,
                            onTap: () => _selectDate(context, true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDateField(
                            label: 'Data de Validade',
                            date: _expiryDate,
                            onTap: () => _selectDate(context, false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Organic Checkbox
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CheckboxListTile(
                        title: const Text('Produto Orgânico'),
                        value: _isOrganic,
                        onChanged: (value) {
                          setState(() {
                            _isOrganic = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        // onPressed: _isLoading ? null : _submitForm,
                        onPressed: widget.product != null
                            ? _isLoading
                                  ? null
                                  : updateProduct
                            : _isLoading
                            ? null
                            : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5722),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFFFF5722).withOpacity(0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              widget.product != null
                                  ? 'Atualizar Produto'
                                  : 'Adicionar Produto',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 2),
      ),
      child: Column(
        children: [
          if (_selectedImages.isEmpty)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _pickImages,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 40,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Toque para adicionar fotos do produto',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Até 5 fotos',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount:
                        _selectedImages.length +
                        (_selectedImages.length < 5 ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < _selectedImages.length) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImages[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[400]!),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.grey[600],
                              size: 32,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<Map<String, String>> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item['value'],
              child: Text(item['label']!),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : 'Selecionar',
                  style: TextStyle(
                    color: date != null ? Colors.black : Colors.grey[600],
                  ),
                ),
                Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
