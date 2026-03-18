import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MpesaPaymentModal extends StatefulWidget {
  final double totalAmount;

  const MpesaPaymentModal({Key? key, required this.totalAmount})
    : super(key: key);

  @override
  State<MpesaPaymentModal> createState() => _MpesaPaymentModalState();
}

class _MpesaPaymentModalState extends State<MpesaPaymentModal> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu número';
    }

    // Remover espaços e caracteres especiais
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');

    // Validar formato moçambicano (9 dígitos)
    if (cleanPhone.length != 9) {
      return 'Número deve ter 9 dígitos';
    }

    // Verificar se começa com 82, 83, 84, 85, 86 ou 87
    if (![
      '82',
      '83',
      '84',
      '85',
      '86',
      '87',
    ].contains(cleanPhone.substring(0, 2))) {
      return 'Número inválido (use 82, 83, 84, 85, 86 ou 87)';
    }

    return null;
  }

  void _handleConfirm() {
    if (_formKey.currentState!.validate()) {
      // Limpar o número (remover espaços)
      final cleanPhone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');

      // Retornar número com prefixo 258
      final fullPhone = '258$cleanPhone';

      Navigator.pop(context, fullPhone);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícone M-Pesa
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phone_android,
                    size: 48,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 20),

                // Título
                const Text(
                  'Pagamento M-Pesa',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Valor total
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Total: ${widget.totalAmount.toStringAsFixed(2)} MT',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Instruções
                Text(
                  'Insira seu número M-Pesa para confirmar o pagamento',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),

                // Campo de telefone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  autofocus: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Número M-Pesa',
                    hintText: '84 123 4567',
                    prefixIcon: Icon(Icons.phone, color: Colors.red[700]),
                    prefixText: '+258 ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.red[700]!, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  validator: _validatePhone,
                  onFieldSubmitted: (_) => _handleConfirm(),
                ),
                const SizedBox(height: 24),

                // Botões
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey[400]!),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Confirmar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Aviso
                Row(
                  children: [
                    Icon(Icons.lock, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Você receberá uma notificação M-Pesa',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Função para mostrar o modal e retornar o número
Future<String?> showMpesaPaymentModal(
  BuildContext context,
  double totalAmount,
) async {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => MpesaPaymentModal(totalAmount: totalAmount),
  );
}
