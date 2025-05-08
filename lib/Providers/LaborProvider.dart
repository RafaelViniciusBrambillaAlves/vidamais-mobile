import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidamais/models/Labor.dart';

class LaborProvider with ChangeNotifier {
  final List<Labor> _laboratorios = [
    Labor(
      id: 1,
      nome: 'Laboratório Saúde Total',
      exames: ['Hemograma', 'Glicemia', 'Colesterol'],
      unidades: ['Centro', 'Zona Norte', 'Zona Sul'],
      convenios: ['Unimed', 'Bradesco Saúde', 'Amil'],
    ),
    Labor(
      id: 2,
      nome: 'Laboratório Vida e Bem-estar',
      exames: ['Hemograma', 'Glicemia', 'Colesterol', 'Testosterona', 'Creatinina'],
      unidades: ['Centro', 'Zona Norte', 'Zona Sul'],
      convenios: ['Unimed', 'Bradesco Saúde', 'Amil', 'SUS'],
    ),
  ];

  Labor? _selectedLabor;
  final SharedPreferences _prefs;

  List<Labor> _filteredLabs = [];
  String _searchQuery = '';

  LaborProvider(this._prefs) {
    _filteredLabs = _laboratorios;
    _loadSavedLabor();
  }

  List<Labor> get labs => _filteredLabs;

  Labor? get selectedLabor => _selectedLabor;

  Future<void> setLabor(int laborId) async {
    _selectedLabor = _laboratorios.firstWhere((lab) => lab.id == laborId);
    await _prefs.setString('selectedLaborId', laborId.toString());
    notifyListeners();
  }

  Future<void> _loadSavedLabor() async {
    final savedId = _prefs.getString('selectedLaborId');
    if (savedId != null) {
      _selectedLabor = _laboratorios.firstWhere(
        (lab) => lab.id == savedId,
        orElse: () => _laboratorios.first,
      );
    }
    notifyListeners();
  }

  void searchLabs(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredLabs = _laboratorios;
    } else {
      _filteredLabs = _laboratorios.where((lab) =>
        lab.nome.toLowerCase().contains(query.toLowerCase())).toList();
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _prefs.remove('selectedLaborId');
    _selectedLabor = null;
    notifyListeners();
  }
}