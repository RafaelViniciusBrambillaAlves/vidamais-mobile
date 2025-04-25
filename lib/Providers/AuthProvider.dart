import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userId;
  String _userPhone = '';

  String get userPhone => _userPhone;
  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;

  void setUserPhone(String phone) {
    _userPhone = phone;
    notifyListeners();
  }


  void login(String userId) {
    _isLoggedIn = true;
    _userId = userId;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userId = null;
    notifyListeners();
  }
}