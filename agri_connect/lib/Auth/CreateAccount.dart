import 'package:agri_connect/Farmer/index.dart';
import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  String selectedRole = "agricultor"; // padrão: Agricultor

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
            color: Colors.green[400],
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Botões de seleção
              Row(
                children: [
                  Expanded(
                    child: _buildRoleButton(
                      "agricultor",
                      Icons.agriculture,
                      "Agricultor",
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildRoleButton(
                      "comprador",
                      Icons.store,
                      "Comprador",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              /// Campos diferentes dependendo do papel
              if (selectedRole == "agricultor") ...[
                const SizedBox(height: 15),
                _buildTextField("Nome Completo", "João Machado"),
                const SizedBox(height: 15),
                _buildTextField("Email", "mauropeniel7@gmail.com"),
                const SizedBox(height: 15),
                _buildTextField("Password", "*********"),
                const SizedBox(height: 15),
                _buildTextField("Telefone", "+258 84 567 8901"),
                const SizedBox(height: 15),
                _buildTextField("Localização", "Cidade da Beira"),
              ] else if (selectedRole == "comprador") ...[
                const SizedBox(height: 15),
                _buildTextField("Nome Completo", "João Machado"),
                const SizedBox(height: 15),
                _buildTextField("Email", "mauropeniel7@gmail.com"),
                const SizedBox(height: 15),
                _buildTextField("Password", "*********"),
              ],

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const index()),
                  );
                },
                child: const Text(
                  "Criar Conta",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Botão de seleção de papel
  Widget _buildRoleButton(String role, IconData icon, String label) {
    bool isSelected = selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => selectedRole = role),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.lightGreen : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.green : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Campo de texto reutilizável
  Widget _buildTextField(String label, String hint) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
