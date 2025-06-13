import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vidamais/models/Labor.dart';
import 'package:vidamais/models/Result.dart';
import 'package:vidamais/models/Schedule.dart';

class LaborService {
  Future<List<Labor>> getLabors() async {
    //  http.get(
    //   Uri.https('66e2-2804-14d-8487-9c03-1436-1788-2d56-7dbb.ngrok-free.app', '/api/labors'),
    //   headers: {'Content-Type': 'application/json'},
    // );
    final response = await http.get(
      Uri.parse('https://fa08-177-95-133-194.ngrok-free.app' + '/api/labors'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',  // <- faz o ngrok passar adiante
      },
    );


    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((labor) => Labor.fromJson(labor)).toList();
    } else {
      throw Exception('Falha na requisição: ${response.statusCode}');
    }
  }

  Future<Schedule> createSchedule(int userId, Schedule schedule) async {
    try {
      print(schedule);
      await http.post(
        Uri.parse('https://fa08-177-95-133-194.ngrok-free.app' + '/api/schedule'),
        headers: {'Content-Type': 'application/json', 'ngrok-skip-browser-warning': 'true', },
        body: jsonEncode({"userId": userId, "exams": schedule.exams.map((e) => e.id).toList(), "scheduleDate": schedule.date.toUtc().toIso8601String(), "unitId": schedule.unit?.id}), //arruma isso, precisa passar os exames e a data de agentamento, ta com problema no checkbox de exames que não esta marcando, e precisa juntar a data e o horario
      );
  //       "exams": [1, 5, 7],
  //        "scheduleDate": "2025-06-05T10:00:00Z"

      return schedule;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Schedule>> getSchedules(int userId, int laborId) async {
    try {
      final response = await http.get(
        Uri.parse('https://fa08-177-95-133-194.ngrok-free.app' + '/api/schedule/$userId/$laborId'),
        headers: {'Content-Type': 'application/json', 'ngrok-skip-browser-warning': 'true', },
      );


      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        // Aqui: cada `item` já é um Map<String, dynamic>, porque o JSON retornado é um array de objetos.
        return jsonData.where((item) => item is Map<String, dynamic>).map((item) {
          final mapItem = item as Map<String, dynamic>;
          return Schedule.fromJson(mapItem);
        }).toList();

      } else {
        throw Exception('Falha na requisição: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }print('Id do laboratorio: $laborId');

    
  }

  Future<List<Result>> getResults(int userId, int laborId) async {
    try {
    
    print('Id Usuario: $userId'); 
    final response = await http.get(
        Uri.parse('https://fa08-177-95-133-194.ngrok-free.app' + '/api/result/user/$userId/$laborId'),
        headers: {'Content-Type': 'application/json', 'ngrok-skip-browser-warning': 'true', },
      );

    print('Response status: ${response.statusCode}'); 
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      print('test');
      // return jsonData.map((json) => Result.fromJson(json)).toList();

      return jsonData.where((item) => item is Map<String, dynamic>).map((item) {
          final mapItem = item as Map<String, dynamic>;
          return Result.fromJson(mapItem);
        }).toList();
    } else {
      throw Exception('Failed to load results');
    }
    } catch (e) {
      print('Erro em getResults: $e');
      rethrow;
    }
  }

  Future<void> cancelSchedule(int scheduleId) async {
    try {
      final response = await http.patch(
        Uri.parse('https://fa08-177-95-133-194.ngrok-free.app' + '/api/schedule/$scheduleId/cancelar'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        print('Agendamento $scheduleId cancelado com sucesso');
      } else {
        final error = json.decode(response.body);
        throw Exception('Falha ao cancelar: ${error['message'] ?? response.statusCode}');
      }
    } catch (e) {
      print('Erro no cancelamento: $e');
      rethrow;
    }
  }
}