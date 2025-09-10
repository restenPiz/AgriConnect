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
        title: const Text('Criar Conta'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
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

            /// Campos de texto comuns a todos
            _buildTextField("Nome Completo", "João Machado"),
            const SizedBox(height: 15),
            _buildTextField("Telefone", "+258 84 567 8901"),

            const SizedBox(height: 15),

            /// Campos diferentes dependendo do papel
            if (selectedRole == "agricultor") ...[
              _buildTextField("Localização da Fazenda", "Sofala, Beira"),
              const SizedBox(height: 15),
              _buildTextField("Tipo de Cultivo Principal", "Milho, Feijão"),
            ] else if (selectedRole == "comprador") ...[
              _buildTextField("Nome do Negócio", "Mercado Central"),
              const SizedBox(height: 15),
              _buildTextField("Localização do Negócio", "Beira, Sofala"),
            ],

            const SizedBox(height: 25),

            /// Botão criar conta
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Aqui podes capturar os dados e enviar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Conta criada como $selectedRole")),
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
            color: isSelected ? Colors.green : Colors.grey.shade300,
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
