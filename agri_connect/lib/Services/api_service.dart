import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.153.126.12:8000/api';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  // Initialize token from storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // Save token to storage
  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear token from storage
  Future<void> _clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  bool get isAuthenticated => _token != null;

  Map<String, String> _getHeaders({bool requiresAuth = false}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // Register user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String userType,
    String? address,
  }) async {
    try {
      print('Sending registration request to: $baseUrl/register');

      final body = {
        'name': name,
        'email': email,
        'password': password,
        'phone_number': phoneNumber,
        'user_type': userType,
        if (address != null) 'address': address,
      };

      print('Request body: $body');

      final response = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: _getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Save token if returned
        if (data['token'] != null) {
          await _saveToken(data['token']);
        }
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? 'Conta criada com sucesso',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erro ao criar conta',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      print('Error during registration: $e');
      return {'success': false, 'message': 'Erro de conexão: ${e.toString()}'};
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('Sending login request to: $baseUrl/login');

      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: _getHeaders(),
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save token
        if (data['token'] != null) {
          await _saveToken(data['token']);
        }
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? 'Login realizado com sucesso',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Credenciais inválidas',
        };
      }
    } catch (e) {
      print('Error during login: $e');
      return {'success': false, 'message': 'Erro de conexão: ${e.toString()}'};
    }
  }

  // Logout user
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/logout'),
            headers: _getHeaders(requiresAuth: true),
          )
          .timeout(const Duration(seconds: 10));

      await _clearToken();

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Logout realizado com sucesso'};
      } else {
        return {'success': false, 'message': 'Erro ao fazer logout'};
      }
    } catch (e) {
      await _clearToken();
      return {'success': true, 'message': 'Logout realizado localmente'};
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/user'),
            headers: _getHeaders(requiresAuth: true),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Erro ao buscar perfil'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão'};
    }
  }
}
