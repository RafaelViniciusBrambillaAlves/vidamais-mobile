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

  Future<void> saveLoginData(String token, String userId) async {
    final prefs = await _prefs;
    await prefs.setBool('isLoggedIn', true);
    await _secureStorage.write(key: 'authToken', value: token);
    await _secureStorage.write(key: 'userId', value: userId);
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

  Future<AuthResponse> fakeLogin(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email == '43432252838' && password == '123456') {
      final user = User(
        username: 'UserExemplo',
        birthdate: DateTime(1990, 1, 1),
        sex: 'M',
        cellphone: '+551799999999',
        cpf: email,
        password: password,
      );

      return AuthResponse(user: user, token: 'fake_jwt_token');
    }

    return AuthResponse(error: 'Credenciais inválidas');
  }

  Future<AuthResponse> fakeSMS(String sms) async {
    await Future.delayed(const Duration(seconds: 1));

    if (sms == '111111') {
      final user = User(
        username: 'UserExemplo',
        birthdate: DateTime(1990, 1, 1),
        sex: 'M',
        cellphone: '+551799999999',
        cpf: '43432252838',
        password: '123456',
      );

      return AuthResponse(user: user, token: 'fake_jwt_token');
    }

    return AuthResponse(error: 'Código SMS inválido');
  }

  Future<AuthResponse> fakeCreateUser({
    required String name,
    required String phone,
    required String cpf,
    required String password,
    required DateTime birthDate,
    required String gender,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    if (cpf.isNotEmpty && password.length >= 6) {
      final user = User(
        username: name,
        birthdate: birthDate,
        sex: gender,
        cellphone: phone,
        cpf: cpf,
        password: password,
      );
      return AuthResponse(user: user, token: 'fake_jwt_token');
    }
    return AuthResponse(error: 'Erro ao criar usuário');
  }
}