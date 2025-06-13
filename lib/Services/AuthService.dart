import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidamais/models/User.dart';

class AuthResponse {
  final User? user;
  final String? token;
  final String? error;

  AuthResponse({this.user, this.token, this.error});
}

class AuthService {
  final _secureStorage = const FlutterSecureStorage();
  final _prefs = SharedPreferences.getInstance();

  Future<void> saveLoginData(String token, int userId) async {
    final prefs = await _prefs;
    await prefs.setBool('isLoggedIn', true);
    await _secureStorage.write(key: 'authToken', value: token);
    await _secureStorage.write(key: 'userId', value: userId.toString());
  }

  Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'authToken');
  }

  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.remove('isLoggedIn');
    await _secureStorage.delete(key: 'authToken');
    await _secureStorage.delete(key: 'userId');
  }

  Future<AuthResponse> login(String cpf, String password) async {  
    var response = await http.post(
      Uri.parse('https://fa08-177-95-133-194.ngrok-free.app' + '/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cpf': cpf, 'password': password}),
    );

    var body = jsonDecode(response.body);
    User user = User.fromJson(body['user']);

    return AuthResponse(user: user, token: body['access_token']);
  }

  Future<AuthResponse> requestSms(String code, String phone) async {
    final response = await http.post(
      Uri.parse('https://fa08-177-95-133-194.ngrok-free.app' + '/api/auth/sms/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': code, 'phone': phone}),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode != 201) {
      final errorMsg = body['message'] ?? 'Código inválido ou expirado';
      return AuthResponse(error: errorMsg);
    }

    return AuthResponse(
      user: User.fromJson(body['user']),
      token: body['token'],
    );
  }

  Future<void> resendSms(String phone) async {
    await http.post(
      Uri.parse('https://fa08-177-95-133-194.ngrok-free.app' + '/api/auth/sms/resend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user': phone}),
    );

    return;
  }

  Future<AuthResponse> createUser({
    required String name,
    required String phone,
    required String cpf,
    required String password,
    required String birthDate,  
    required String gender,
  }) async {
    final response = await http.post(
      Uri.parse('https://fa08-177-95-133-194.ngrok-free.app' + '/api/auth/logon'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'fullName': name, 'phone': phone, 'cpf': cpf, 'password': password, 'birthDate': birthDate, 'gender': gender}),
    );
    var body = jsonDecode(response.body);
    User user = User.fromJson(body['user']);
    return AuthResponse(user: user, token: body['access_token']);
  }
}