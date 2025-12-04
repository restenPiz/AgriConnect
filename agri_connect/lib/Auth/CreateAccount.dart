import 'package:agri_connect/Buyer/index.dart';
import 'package:flutter/material.dart';
import 'package:agri_connect/Services/api_service.dart';
import 'package:agri_connect/Farmer/index.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String selectedRole = "farmer"; // farmer or buyer
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  // Map Portuguese role to English for API
  String _mapRoleToApi(String role) {
    if (role == "agricultor") return "farmer";
    if (role == "comprador") return "buyer";
    return role;
  }

  Future<void> _handleCreateAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final result = await ApiService().register(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        phoneNumber: _phoneCtrl.text.trim(),
        userType: selectedRole,
        address: selectedRole == 'farmer' ? _addressCtrl.text.trim() : null,
      );

      setState(() => _loading = false);

      if (!mounted) return;

      if (result['success']) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Conta criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate based on user type
        if (selectedRole == 'farmer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const index()),
          );
        } else {
          // Navigate to buyer dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Index()),
          );
        }
      } else {
        // Show error message
        String errorMessage = result['message'] ?? 'Erro ao criar conta';

        // If there are validation errors, show them
        if (result['errors'] != null) {
          final errors = result['errors'] as Map<String, dynamic>;
          errorMessage = errors.values.first[0];
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro inesperado: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Criar Conta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.green[600],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selecione seu tipo de conta',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                /// Botões de seleção
                Row(
                  children: [
                    Expanded(
                      child: _buildRoleButton(
                        "farmer",
                        Icons.agriculture,
                        "Agricultor",
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildRoleButton(
                        "buyer",
                        Icons.store,
                        "Comprador",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                /// Form fields
                _buildTextFormField(
                  controller: _nameCtrl,
                  label: "Nome Completo",
                  hint: "João Machado",
                  icon: Icons.person,
                  enabled: !_loading,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Nome é obrigatório'
                      : null,
                ),
                const SizedBox(height: 15),

                _buildTextFormField(
                  controller: _emailCtrl,
                  label: "Email",
                  hint: "exemplo@email.com",
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_loading,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Email é obrigatório';
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(v.trim())) return 'Email inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                _buildTextFormField(
                  controller: _passwordCtrl,
                  label: "Senha",
                  hint: "Mínimo 6 caracteres",
                  icon: Icons.lock,
                  obscureText: _obscurePassword,
                  enabled: !_loading,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Senha é obrigatória';
                    if (v.length < 6)
                      return 'Senha deve ter pelo menos 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                _buildTextFormField(
                  controller: _phoneCtrl,
                  label: "Telefone",
                  hint: "+258 84 567 8901",
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  enabled: !_loading,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Telefone é obrigatório'
                      : null,
                ),

                if (selectedRole == "farmer") ...[
                  const SizedBox(height: 15),
                  _buildTextFormField(
                    controller: _addressCtrl,
                    label: "Localização",
                    hint: "Cidade da Beira",
                    icon: Icons.location_on,
                    enabled: !_loading,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Localização é obrigatória'
                        : null,
                  ),
                ],

                const SizedBox(height: 25),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _loading ? null : _handleCreateAccount,
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
                          "Criar Conta",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                const SizedBox(height: 15),

                Center(
                  child: TextButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    child: Text(
                      'Já tem uma conta? Faça login',
                      style: TextStyle(
                        color: Colors.green[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(String role, IconData icon, String label) {
    bool isSelected = selectedRole == role;
    return GestureDetector(
      onTap: _loading ? null : () => setState(() => selectedRole = role),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green[600]! : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? Colors.green[600] : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.green[600] : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool enabled = true,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.green[600]),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: enabled ? Colors.grey[50] : Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[600]!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      validator: validator,
    );
  }
}
