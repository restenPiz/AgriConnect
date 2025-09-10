import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  String selectedRole = "agricultor"; // guarda a seleção

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedRole = "agricultor"),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: selectedRole == "agricultor"
                            ? Colors.green[50]
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedRole == "agricultor"
                              ? Colors.green
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.agriculture,
                            size: 40,
                            color: selectedRole == "agricultor"
                                ? Colors.green
                                : Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Agricultor",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedRole == "agricultor"
                                  ? Colors.green
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedRole = "comprador"),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: selectedRole == "comprador"
                            ? Colors.green[50]
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedRole == "comprador"
                              ? Colors.green
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.store,
                            size: 40,
                            color: selectedRole == "comprador"
                                ? Colors.green
                                : Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Comprador",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedRole == "comprador"
                                  ? Colors.green
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            /// Campos de texto
            _buildTextField("Nome Completo", "João Machado"),
            const SizedBox(height: 15),
            _buildTextField("Telefone", "+258 84 567 8901"),
            const SizedBox(height: 15),
            _buildTextField("Localização da Fazenda", "Sofala, Beira"),
            const SizedBox(height: 15),
            _buildTextField("Tipo de Cultivo Principal", "Milho, Feijão"),
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
                // ação de criar conta
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

  /// Função para gerar textfields padronizados
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
