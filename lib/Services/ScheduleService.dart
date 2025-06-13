import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vidamais/models/Schedule.dart';

class ScheduleService {

  
  Future<List<Schedule>> getUserSchedules(int userId, int laborId) async {
    // final response = await http.get(
    //   Uri.parse('https://c7ad-2804-14d-8487-9c03-d5fa-2482-ef11-32e3.ngrok-free.app/api/schedule/$userId/$laborId'),
    //   headers: {'Content-Type': 'application/json'},
    // );

    // if (response.statusCode == 200) {
    //   final List<dynamic> data = json.decode(response.body);
    //   return data.map((json) => Schedule.fromJson(json)).toList();
    // } else {
    //   throw Exception('Falha ao carregar agendamentos. Status: ${response.statusCode}');
    // }
    final uri = Uri.http(
      'https://fa08-177-95-133-194.ngrok-free.app', // Host e porta
      '/api/schedule/$userId/$laborId', // Caminho
    );
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Schedule.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar agendamentos. Status: ${response.statusCode}');
    }
  }
}