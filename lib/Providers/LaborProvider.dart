import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidamais/Services/LaborService.dart';
import 'package:vidamais/Services/ScheduleService.dart';
import 'package:vidamais/models/Labor.dart';
import 'package:vidamais/models/Result.dart';
import 'package:vidamais/models/Schedule.dart';

class LaborProvider with ChangeNotifier {
  final LaborService _laborService;
  final SharedPreferences _prefs;
  
  List<Labor> _labors = [];
  Labor? _selectedLabor;
  List<Labor> _filteredLabs = [];
  String _searchQuery = '';
  List<Schedule> _schedules = [];
  List<Result> _results = [];

  List<Schedule> get schedules => _schedules;
  List<Result> get results => _results;


  LaborProvider({
    required LaborService laborService,
    required SharedPreferences prefs, required ScheduleService service,
  })  : _laborService = laborService,
        _prefs = prefs {
    _init();
  }

  List<Labor> get labs => _filteredLabs;
  Labor? get selectedLabor => _selectedLabor;

  Future<void> _init() async {
    await _loadLabors();
    await _loadSavedLabor();
  }

  Future<void> _loadLabors() async {
    try {
      _labors = await _laborService.getLabors();
      _applySearchFilter();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar laboratórios: $e');
    }
  }

  Future<void> refreshLabors() async {
    await _loadLabors();
  }

  Future<bool> setLabor(int laborId) async {
    try {
      _selectedLabor = _labors.firstWhere((lab) => lab.id == laborId);
      await _prefs.setInt('selectedLaborId', laborId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Laboratório não encontrado: $e');
      return false;
    }
  }

  Future<void> _loadSavedLabor() async {
    final savedId = _prefs.getInt('selectedLaborId');
    if (savedId != null) {
      try {
        _selectedLabor = _labors.firstWhere((lab) => lab.id == savedId);
      } catch (e) {
        debugPrint('Laboratório salvo não encontrado: $e');
      }
    }
    notifyListeners();
  }

  void searchLabs(String query) {
    _searchQuery = query;
    _applySearchFilter();
    notifyListeners();
  }

  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      _filteredLabs = List.from(_labors);
    } else {
      _filteredLabs = _labors.where((lab) =>
          lab.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
  }

  Future<void> logout() async {
    await _prefs.remove('selectedLaborId');
    _selectedLabor = null;
    notifyListeners();
  }

  Future<List<Result>> loadUserResult(int userId, int laborId) async {
    _results = await _laborService.getResults(userId, laborId);
    notifyListeners();
    return _results;
  }

  Future<List<Schedule>> loadUserSchedules(int userId, int laborId) async {
    _schedules = await _laborService.getSchedules(userId, laborId);
    print(_schedules);
    notifyListeners();
    return _schedules;
  }

  Future<Schedule> createSchedule(int userId, Schedule schedule) async {
    return _laborService.createSchedule(userId, schedule);
  }

  Future<void> cancelSchedule(int scheduleId) async {
    try {
      await _laborService.cancelSchedule(scheduleId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
