import 'package:flutter/material.dart';
import 'package:vidamais/models/Schedule.dart';
import 'package:vidamais/Services/ScheduleService.dart';

class ScheduleProvider with ChangeNotifier {
  final ScheduleService _service;
  List<Schedule> _schedules = [];
  bool _isLoading = false;
  String? _error;

  ScheduleProvider({required ScheduleService service}) : _service = service;

  List<Schedule> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserSchedules(int userId, int laborId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _schedules = await _service.getUserSchedules(userId, laborId);
    } catch (e) {
      _error = e.toString();
      _schedules = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}