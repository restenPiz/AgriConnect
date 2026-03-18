import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  // ⚠️ IMPORTANTE: Altere para o IP da sua máquina
  // Para Android Emulator: use 10.0.2.2
  // Para dispositivo real: use o IP local da sua máquina (ex: 192.168.1.100)
  static const String baseUrl = 'http://172.28.223.12:8000/api';

  // Obter token de autenticação
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    print('🔑 Token: ${token != null ? "Existe" : "Não encontrado"}');
    return token;
  }

  // Headers com autenticação
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Iniciar pagamento M-Pesa
  Future<Map<String, dynamic>> initiateMpesaPayment({
    required String phoneNumber,
    required double amount,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      print('💳 Iniciando pagamento M-Pesa...');
      print('📱 Telefone: $phoneNumber');
      print('💰 Valor: $amount MT');
      print('📦 Itens: ${items.length}');

      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/orders/mpesa-payment');

      final body = jsonEncode({
        'phone_number': phoneNumber,
        'amount': amount,
        'items': items,
      });

      print('📡 URL: $url');
      print('📋 Headers: $headers');
      print('📦 Body: $body');

      final response = await http.post(url, headers: headers, body: body);

      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          print('✅ Pagamento iniciado com sucesso');
          return {
            'success': true,
            'message': jsonData['message'] ?? 'Pagamento iniciado com sucesso',
            'data': jsonData['data'],
          };
        } else {
          print('⚠️ Resposta de falha do backend');
          return {
            'success': false,
            'message': jsonData['message'] ?? 'Erro ao processar pagamento',
          };
        }
      } else if (response.statusCode == 401) {
        print('❌ Não autenticado');
        return {
          'success': false,
          'message': 'Não autenticado. Faça login novamente.',
        };
      } else if (response.statusCode == 400) {
        final jsonData = json.decode(response.body);
        print('❌ Erro de validação');
        return {
          'success': false,
          'message': jsonData['message'] ?? 'Dados inválidos',
        };
      } else {
        print('❌ Erro HTTP: ${response.statusCode}');
        return {
          'success': false,
          'message':
              'Erro ao processar pagamento. Código: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Exceção no pagamento M-Pesa: $e');
      return {
        'success': false,
        'message': 'Erro ao conectar com o servidor: $e',
      };
    }
  }

  // Verificar status do pagamento (opcional)
  Future<Map<String, dynamic>> checkPaymentStatus(String orderId) async {
    try {
      print('🔍 Verificando status do pedido: $orderId');

      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/orders/$orderId/status');

      final response = await http.get(url, headers: headers);

      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return {
          'success': true,
          'status': jsonData['payment_status'],
          'data': jsonData,
        };
      }

      return {'success': false, 'message': 'Erro ao verificar status'};
    } catch (e) {
      print('❌ Erro ao verificar status: $e');
      return {'success': false, 'message': 'Erro: $e'};
    }
  }
}
