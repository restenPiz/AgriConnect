import 'package:flutter/material.dart';
import 'package:agri_connect/services/api_service.dart';
import 'package:agri_connect/Farmer/index.dart';

class login extends StatefulWidget {
  const login({Key? key}) : super(key: key);

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;
  bool _obscure = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email é obrigatório';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(v.trim())) return 'Digite um email válido';
    return null;
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Senha é obrigatória';
    if (v.length < 6) return 'Senha deve ter pelo menos 6 caracteres';
    return null;
  }

  Future<void> _handleLogin() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) return;

    // Start loading
    setState(() {
      _loading = true;
    });

    try {
      print('=== LOGIN DEBUG ===');
      print('Email: ${_emailCtrl.text.trim()}');
      print('Attempting login...');

      // Call API
      final result = await ApiService().login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      // Stop loading
      setState(() {
        _loading = false;
      });

      if (!mounted) return;

      print('Login result: $result');

      if (result['success']) {
        // Get user data
        final userData = result['data']['user'];
        final userType = userData['user_type'];

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Login realizado com sucesso!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate based on user type
        await Future.delayed(const Duration(milliseconds: 500));

        if (userType == 'farmer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const index()),
          );
        } else if (userType == 'buyer') {
          // Navigate to buyer dashboard
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (_) => const BuyerIndex()),
          // );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tela do comprador ainda não implementada'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // Show error message
        setState(() {
          _errorMessage = result['message'] ?? 'Erro ao fazer login';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Credenciais inválidas'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Login error: $e');

      setState(() {
        _loading = false;
        _errorMessage = 'Erro ao conectar ao servidor';
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro de conexão: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[600],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Logo/Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[400],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.agriculture,
                  size: 60,
                  color: Colors.amber[700],
                ),
              ),
              const SizedBox(height: 20),

              // App Name
              const Text(
                "AgriConnect",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),

              // Welcome message
              const Text(
                "Bem-vindo de volta!",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 40),

              // Login Form Card
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email Field
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_loading,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(
                            Icons.email,
                            color: Colors.green[600],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.green[600]!,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: _loading
                              ? Colors.grey[200]
                              : Colors.grey[50],
                        ),
                        validator: _emailValidator,
                        autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        enabled: !_loading,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Colors.green[600],
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey[600],
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.green[600]!,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: _loading
                              ? Colors.grey[200]
                              : Colors.grey[50],
                        ),
                        validator: _passwordValidator,
                        autofillHints: const [AutofillHints.password],
                      ),
                      const SizedBox(height: 12),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _loading
                              ? null
                              : () {
                                  // TODO: Implement forgot password
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Funcionalidade em desenvolvimento',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                },
                          child: Text(
                            'Esqueceu a senha?',
                            style: TextStyle(
                              color: Colors.green[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Error Message
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Login Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: _loading ? null : _handleLogin,
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Entrar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'ou',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Create Account Button
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.green[600]!, width: 2),
                          foregroundColor: Colors.green[600],
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _loading
                            ? null
                            : () {
                                Navigator.pop(context);
                              },
                        child: const Text(
                          'Criar nova conta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Back Button
              TextButton.icon(
                onPressed: _loading
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                label: const Text(
                  'Voltar',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
